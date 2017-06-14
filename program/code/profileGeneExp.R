###                     profileGeneExp.R                   ###
### ====================================================== ###
# This R function is to profile drug treated gene expression data



profileGeneExp <- function(file) {
      
      cat("Start parsing drug treated gene expression data ...\n")
      cat("------------\n")
      
      ### Read data
      geneExp <- read.csv(file, header = FALSE, check.names = FALSE, stringsAsFactors = FALSE)
      
      ### Average duplicated drug data
      geneExp.mat <- geneExp.aveDrug(geneExp)
      
      ### Normalize data
      geneExp.mat <- normGeneExp(geneExp.mat)
      
      ### Subtract nagtive control effect
      geneExp.mat <- geneExp.diffCtl(geneExp.mat)
      
      ### Convert probe level to gene level
      geneExp.profile <- prob2gene(geneExp.mat)
      
      cat("Done parsing drug treated gene expression data.\n\n")
      return(geneExp.profile)
      
}


### Average duplicated drug data in gene expression file
geneExp.aveDrug <- function(geneExp) {
      
      cat("Checking drug name ...\n")
      ### Check duplicated drugs
      if (any(duplicated(as.character(geneExp[1,-1])))) {
            cat("Duplicated drug name found, average duplicated data.\n")
      }
      
      ### Print drug list
      drugName <- sort(unique(as.character(geneExp[1,-1])))
      if (!("Neg_control" %in% drugName)) {
            stop("Error: Negative control not found. Plase involve Neg_control column in the file.\n")
      }
      cat("Drug list you provided:\n")
      idx <- 1
      for (i in 1:length(drugName)) {
            if (drugName[i] != "Neg_control") {
                  cat(idx, ". ", drugName[i], "\n", sep = "")
                  idx <- idx + 1
            }
      }
      
      ### Average dupliacte drug data (if any)
      geneExp.mat <- data.frame(matrix(NA, nrow = nrow(geneExp)-1, ncol = length(drugName)+1))
      colnames(geneExp.mat) <- c("Gene", drugName)
      geneExp.mat$Gene <- geneExp[-1,1]
      
      for (i in 1:length(drugName)) {
            tmpDrug.data <- geneExp[-1, geneExp[1,] == drugName[i]]
            tmpDrug.data <- apply(as.data.frame(tmpDrug.data), 2, as.numeric)
            tmpDrug.mean <- apply(tmpDrug.data, 1, mean)
            geneExp.mat[drugName[i]] <- tmpDrug.mean
      }
      
      return(geneExp.mat)
}


### Quantile normalize gene expression data
normGeneExp <- function(geneExp) {
      
      cat("Normalizing data ...\n")
      drugName <- colnames(geneExp)[-1]; geneName <- geneExp[,1]
      geneExp.mat <- normalize.quantiles(as.matrix(geneExp[,-1]))
      colnames(geneExp.mat) <- drugName
      geneExp.mat <- data.frame(Gene = geneName, geneExp.mat, stringsAsFactors = FALSE, check.names = FALSE)
      
      return(geneExp.mat)
}


### Subtract nagtive control effect
geneExp.diffCtl <- function(geneExp) {
      
      cat("Measuring gene expression difference ...\n")
      neg_control <- geneExp[,"Neg_control"]
      for (i in 2:ncol(geneExp)) {
            geneExp[,i] <- geneExp[,i] - neg_control
      }
      
      ### delete Neg_control column
      geneExp$Neg_control <- NULL
      
      return(geneExp)
}


### Conver probe level to gene level
prob2gene <- function(geneExp) {
      
      cat("Collapse multiple probes to genes ...\n")
      
      geneName <- sapply(strsplit(geneExp$Gene, " ", fixed = TRUE), "[[", 1)
      geneExp$Gene <- geneName
      
      geneExp.mean <- aggregate(geneExp[,-1], by = list(Gene = geneExp$Gene), FUN = mean)
      geneExp.max <- aggregate(geneExp[,-1], by = list(Gene = geneExp$Gene), FUN = max)
      geneExp.min <- aggregate(geneExp[,-1], by = list(Gene = geneExp$Gene), FUN = min)
      
      geneExp.profile <- list(geneExp.mean = geneExp.mean, geneExp.max = geneExp.max, geneExp.min = geneExp.min)
      return(geneExp.profile$geneExp.max)
}
