############################################################################
###                          Gene Set Enrichment                         ###
############################################################################
# Function using gene set enrichment score.

library(doParallel)
source("code/GeneSetSyn/GeneSet.delta.z.R")
source("code/GeneSetSyn/GeneSet.permute.dist.R")
source("code/GeneSetSyn/GeneSet.score.R")


GeneSetEnrich.score <- function(geneExp, n.permu, geneSets) {
      
      geneExp.cp <- geneExp
      
      ### ------------ clean input gene expression data ------------- ###
      cat("------------------ Normalize data ------------------\n", sep = "")
      geneExp.diff <- delta.z(geneExp)
      row.names(geneExp.diff) <- geneExp.diff$Gene
      geneExp.diff$Gene <- NULL
      
      ### -------------------- score table ----------------------- ###
      drugName <- colnames(geneExp.diff)
      drugPair <- combn(drugName, 2)
      score.table <- data.frame(matrix(0, nrow = ncol(drugPair), ncol = 6, dimnames = list(1:ncol(drugPair), c("drugA", "drugB", "co.gene.score", "co.GS.score", "co.gene.GS.score", "Rank"))))
      ### fill drug names
      score.table$drugA <- drugPair[1,]
      score.table$drugB <- drugPair[2,]
      
      ### --------------------- co-genes ------------------------ ###
      cat("----- Calculate co-gene scores -----\n", sep = "")
      emp.dist.co.gene <- permute.dist.co.gene(geneExp = geneExp.cp, n = n.permu, verbose = FALSE)
      quantile.05 <- quantile(emp.dist.co.gene, c(.05, .95))
      lowerbound <- quantile.05[1]
      upperbound <- quantile.05[2]
      geneExp.diff.sig <- geneExp.diff
      geneExp.diff.sig[geneExp.diff.sig >= lowerbound & geneExp.diff.sig <= upperbound] <- 0    # this first
      geneExp.diff.sig[geneExp.diff.sig > 0] <- 1
      geneExp.diff.sig[geneExp.diff.sig < 0] <- -1
      ### calculate co-gene score for each drug pair
      for (i in 1:nrow(score.table)) {
            tmp.drugA <- score.table$drugA[i]
            tmp.drugB <- score.table$drugB[i]
            geneExp.diff.pair <- geneExp.diff.sig[, colnames(geneExp.diff.sig) %in% c(tmp.drugA, tmp.drugB)]
            co.gene.score <- co.gene(geneExp.diff.pair)
            score.table$co.gene.score[i] <- co.gene.score
      }
      # ### co-gene rank
      # score.table$Rank <- rank(-score.table$co.gene.score)
      # pcIndex(gStd.data = gStd.data, predRank.data = score.table) # c.index = 0.589
      
      ### ---------------------------- co-GS ---------------------------- ###
      cat("----- Calculate co-GS scores -----\n", sep = "")
      
      enrich.table <- enrich.score.mat(geneExp.mat = geneExp.diff, geneSet.list = geneSets)
      ### get empirical distribution for each gene set
      emp.dist.co.GS <- permute.dist.co.GS(geneExp = geneExp.cp, geneSet.list = geneSets, n = n.permu)
      co.GS.ecdf <- ecdf(emp.dist.co.GS)
      ### calculate quantile
      enrich.table.p.down <- apply(enrich.table, 2, co.GS.ecdf)
      enrich.table.p.up <- 1 - enrich.table.p.down
      ### Benjamini-Hochberg adjustment p-value
      # enrich.table.p.down <- apply(enrich.table.p.down, 2, FUN = function(x) p.adjust(x, method = "BH"))
      # enrich.table.p.up <- apply(enrich.table.p.up, 2, FUN = function(x) p.adjust(x, method = "BH"))
      enrich.table.diff <- enrich.table.p.up
      enrich.table.diff[,] <- 0
      ### find enriched gene set
      enrich.table.diff[enrich.table.p.down < 0.05] <- -1
      enrich.table.diff[enrich.table.p.up < 0.05] <- 1
      
      ### calculate co-gene score for each drug pair
      for (i in 1:nrow(score.table)) {
            tmp.drugA <- score.table$drugA[i]
            tmp.drugB <- score.table$drugB[i]
            enrich.table.diff.pair <- enrich.table.diff[, colnames(enrich.table.diff) %in% c(tmp.drugA, tmp.drugB)]
            co.GS.score <- co.GS(enrich.table.diff.pair)
            score.table$co.GS.score[i] <- co.GS.score
      }
      # ### co-GS rank
      # score.table$Rank <- rank(-score.table$co.GS.score)
      # pcIndex(gStd.data = gStd.data, predRank.data = score.table) # c.index = 0.580

      
      
      ### -------------------------- co.gene.GS ------------------------------ ###
      cat("-------- Calculate co-gene/GS score -------\n", sep = "")
      co.gene.GS.score <- foreach (i = 1:nrow(score.table), .combine = "c") %dopar% {
            tmp.drugA <- score.table$drugA[i]
            tmp.drugB <- score.table$drugB[i]
            geneExp.diff.pair <- geneExp.diff.sig[, colnames(geneExp.diff) %in% c(tmp.drugA, tmp.drugB)]
            ### select co-enriched gene sets
            idx.A <- enrich.table.diff[, colnames(enrich.table.diff) == tmp.drugA]
            idx.B <- enrich.table.diff[, colnames(enrich.table.diff) == tmp.drugB]
            idx <- which(idx.A & idx.B)
            if (length(idx) == 0) {
                  tmp.score <- 0
            } else {
                  tmp.geneSets <- geneSets[idx]
                  ### calculate normalized co-gene score
                  source("code/GeneSetSyn/GeneSet.score.R")
                  tmp.score <- co.gene.GS(geneExp.diff.pair, tmp.geneSets)
            }
            return(tmp.score)
      }
      score.table$co.gene.GS.score <- co.gene.GS.score
      
      # ### co-gene/GS rank
      score.table$Rank <- rank(-score.table$co.gene.GS.score)
      cat("Done scoring, rank based on co-gene/GS scores.\n", sep = "")
      # pcIndex(gStd.data = gStd.data, predRank.data = score.table) # c.index = 0.600
      
      return(score.table)
      
}

