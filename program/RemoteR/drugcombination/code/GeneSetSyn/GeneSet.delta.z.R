#########################################
###        delta.z
#########################################

delta.z <- function(geneExp, verbose = FALSE) {
      
      # ------- scale ------- #
      geneExp[,-1] <- t(apply(geneExp[,-1], 1, FUN = scale))
      
      # ------------ average same drug ---------------- #
      ### Print drug list
      drugName <- sort(unique(colnames(geneExp)[-1]))
      if (!("Neg_control" %in% drugName)) {
            stop("Error: Negative control not found. Plase involve Neg_control column in the file.\n")
      }
      if (verbose) cat("Drug list you provided:\n")
      idx <- 1
      for (i in 1:length(drugName)) {
            if (drugName[i] != "Neg_control") {
                  if (verbose) cat(idx, ". ", drugName[i], "\n", sep = "")
                  idx <- idx + 1
            }
      }
      
      ### Average dupliacte drug data (if any)
      geneExp.mat <- data.frame(matrix(NA, nrow = nrow(geneExp), ncol = length(drugName)+1))
      colnames(geneExp.mat) <- c("Gene", drugName)
      geneExp.mat$Gene <- geneExp[,1]
      
      for (i in 1:length(drugName)) {
            tmpDrug.data <- geneExp[, colnames(geneExp) == drugName[i]]
            tmpDrug.data <- apply(as.data.frame(tmpDrug.data), 2, as.numeric)
            tmpDrug.mean <- apply(tmpDrug.data, 1, mean)
            geneExp.mat[drugName[i]] <- tmpDrug.mean
      }
      
      # ------------- subtract control ---------------- #
      ### subtract negtaive control
      if (verbose) cat("Measuring gene expression difference ...\n")
      neg_control <- geneExp.mat[,"Neg_control"]
      for (i in 2:ncol(geneExp.mat)) {
            geneExp.mat[,i] <- geneExp.mat[,i] - neg_control
      }
      
      ### delete Neg_control column
      geneExp.mat$Neg_control <- NULL
      
      # ------------- collapse to gene ----------------- #
      if (verbose) cat("Collapse multiple probes to genes ...\n")
      
      geneName <- sapply(strsplit(geneExp.mat$Gene, " ", fixed = TRUE), "[[", 1)
      geneExp.mat$Gene <- geneName
      geneExp.max <- aggregate(geneExp.mat[,-1], by = list(Gene = geneExp.mat$Gene), FUN = max)
      
      return(geneExp.max)
}