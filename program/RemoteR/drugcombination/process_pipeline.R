### ======================================================================================= ###
###                                     process_pipline.R                                   ###
### ======================================================================================= ###
# This R script is a pipline to analyze drug pair synergy

suppressMessages(library(argparse))
suppressMessages(library(preprocessCore))
suppressMessages(library(org.Hs.eg.db))
suppressMessages(library(KEGGgraph))
suppressMessages(library(ggplot2))
suppressMessages(library(grid))
suppressMessages(library(doParallel))
cores <- detectCores()
if (cores >= 4) registerDoParallel(cores = cores - 1)


### 0. Parse comandline argument
##################################
parser <- ArgumentParser(description = "This pipline is to analyze drug pair syngergy using DIGREM model.")
parser$add_argument("jobID", type = "character", help = "Passing the job ID")
parser$add_argument("-p", "--pathway", type = "integer", default = 1, help =  "Specify the pathway information to use: 1 for consctructed KEGG pathway information, 2 de novo construction of gene network with own dataset. Default is 1.")

pipArgs <- parser$parse_args()
jobID <- pipArgs$jobID
pathway <- pipArgs$pathway

# concatenate input file path
dose.path <- paste("data/doseRes", jobID, ".csv", sep = "")
geneExp.path <- paste("data/GeneExpr", jobID, ".csv", sep = "")
geneNet.path <- paste("data/geneNet", jobID, ".csv", sep = "")
# concatenate ouput file path
rank.path <- paste("report/pred.pairRank", jobID, ".csv", sep = "")
p.heat.path <- paste("report/score_heatmap", jobID, ".jpeg", sep = "")
p.bar.path <- paste("report/score_rank", jobID, ".jpeg", sep = "")
# concatenate status file path
log.path <- paste("report/log", jobID, ".txt", sep = "")
stat.path <- paste("report/status", jobID, ".txt", sep = "")

# check input parameter
inputErr <- c()
if (!file.exists(geneExp.path)) inputErr <- c(inputErr, "\nDrug treated gene expression data not found!")
if (!pathway %in% c(1,2)) {
      inputErr <- c(inputErr, "\nPathway parameter not understood. -p must be either 1 or 2.")
} else if (pathway == 2 & !file.exists(geneNet.path)) {
      inputErr <- c(inputErr, "\nSet -p to be 2, but gene interaction file not found!")
}
if (!is.null(inputErr)) stop(inputErr)




### 1. Start tracking status
################################################################
if (!dir.exists("report/")) {
      dir.create("report/")
      file.create(log.path)
} else if (!file.exists(log.path)) {
      file.create(log.path)
}
f <- file(log.path, open = "wt")
sink(f, type = "message")


### 2. Load functions and data
################################################################
suppressMessages(source("code/doseRes.R"))
suppressMessages(source("code/profileGeneExp.R"))
suppressMessages(source("code/DIGREscore.R"))
suppressMessages(source("code/plotting.R"))
suppressMessages(source("code/constGeneNet.R"))
suppressMessages(source("code/IUPUI/IUPUI.R"))
suppressMessages(source("code/GeneSetSyn/GeneSet.delta.z.R"))
suppressMessages(source("code/GeneSetSyn/GeneSet.permute.dist.R"))
suppressMessages(source("code/GeneSetSyn/GeneSet.score.R"))
suppressMessages(source("code/GeneSetSyn/GeneSetEnrich.R"))
load("data/CGP.mat.RData")
load("data/KEGGnet.mat.RData")
load("data/GeneSet.RData")


### 3. Read and parse data
################################################################
# read dose response data
if (file.exists(dose.path)) {
      doseRes <- readDoseRes.csv(dose.path)
} else {
      doseRes <- "noDose"
}

# prepare drug treated gene expression data
geneExpDiff <- profileGeneExp(geneExp.path)

# parse gene interaction data if uploaded
if (pathway == 2) {
      geneNet.mat <- constGeneNet(geneNet.path)
}


### 4.1 Analyze drug pair synergy using DIGRE
#################################################################
cat("=====================================\n        Calling DIGRE methods\n=====================================\n")
if (pathway == 1) {
      res.DIGRE <- DIGREscore(geneExpDiff = geneExpDiff, doseRes = doseRes, CGP.mat = CGP.mat, GP.mat = KEGGnet.mat, fold = 0.6)
} else if (pathway == 2) {
      res.DIGRE <- DIGREscore(geneExpDiff = geneExpDiff, doseRes = doseRes, CGP.mat = CGP.mat, GP.mat = geneNet.mat, fold = 0.6)
}
res.rank <- res.DIGRE$scoreRank
colnames(res.rank)[3] <- "DIGRE.score"


### 4.2 Analyze drug pair synergy using IUPUI
##################################################################
cat("=====================================\n        Calling IUPUI methods\n=====================================\n")
geneExp <- readGeneExp(geneExp.path)
drugNames <- colnames(geneExp)[-1]
drugNames <- drugNames[drugNames != "Neg_control"]
if (all(table(drugNames) >= 3)) {
      IUPUI.rank <- IUPUI_CCBB(geneExp = geneExp, lowIC.drug = "all", verbose = 1)
      IUPUI.rank <- IUPUI.rank[,c(1,2,6)]
      colnames(IUPUI.rank)[3] <- "IUPUI.score"
      res.rank <- merge(res.rank, IUPUI.rank, by = c("drugA", "drugB"))
}


### 4.3 Analyze drug pair synergy using GeneSetEnrichment
##################################################################
cat("=====================================\n        Calling Gene set methods\n=====================================\n")
if (length(drugNames) >= 16) {
      GeneSet.rank <- GeneSetEnrich.score(geneExp = geneExp, n.permu = 8, geneSets = geneSet)
      GeneSet.rank <- GeneSet.rank[,c(1,2,5)]
      res.rank <- merge(res.rank, GeneSet.rank, by = c("drugA", "drugB"))
}
res.rank <- res.rank[,c(1,2,3,5,6,4)]
colnames(res.rank)[c(5,6)] <- c("GS.score", "DIGRE.rank")
write.csv(res.rank, rank.path, row.names = FALSE)


### 5. Make plots
################################################################
# plot heatmap
p.heat <- pair.ggheat(pred.pair = res.rank)
ggsave(p.heat, filename =  p.heat.path, width = 8, height = 6)

# plot barplot
p.bar <- pair.ggbar(pred.pair = res.rank)
ggsave(p.bar, filename = p.bar.path, width = 8, height = 7)





### 6. Check error
################################################################
sink(type = "message")
close(f)

Lines <- readLines(log.path)
Err <- any(grepl("Error", Lines))
if (Err) {
      write("Fail", file = stat.path)
} else {
      write("Success", file = stat.path)
}