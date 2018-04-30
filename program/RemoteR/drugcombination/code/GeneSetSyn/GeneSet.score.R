# =================================== #
#           score.fun                 #
# =================================== #
# Function to calculate co-gene, co-GS, co-gene/GS score.


### ------------------- co.gene.score ------------------------ ###

co.gene <- function(geneExp.diff.pair) {
      com.genes <- sum(abs(rowSums(geneExp.diff.pair)) == 2)
      con.genes <- sum(apply(geneExp.diff.pair, 1, prod) == -1)
      tot.genes <- sum(rowSums(abs(geneExp.diff.pair)) != 0)
      co.gene.score <- (com.genes - con.genes) / tot.genes
      return(co.gene.score)
}

### ---------------------- co-GS --------------------------- ###

co.GS <- function(geneExp.diff.pair) {
      com.Sets <- sum(rowSums(abs(geneExp.diff.pair)) == 2)
      tot.Sets <- sum(rowSums(abs(geneExp.diff.pair)) != 0)
      co.GS.score <- com.Sets / tot.Sets
      return(co.GS.score)
}


### Gene set enrichment score for matrix
enrich.score.mat <- function(geneExp.mat, geneSet.list, verbose = TRUE) {
      
      # ### first scale each column to make same distribution
      # rowNames <- row.names(geneExp.mat)
      # geneExp.mat <- apply(geneExp.mat, 2, scale)
      # row.names(geneExp.mat) <- rowNames
      
      ### enrichment score
      geneSet.names <- sapply(geneSet.list, "[[", 1)
      enrich.score.mat <- data.frame(matrix(NA, nrow = length(geneSet.names), ncol = ncol(geneExp.mat), dimnames = list(geneSet.names, colnames(geneExp.mat))), check.names = FALSE)
      for (i in 1:ncol(enrich.score.mat)) {
            if (verbose == TRUE) cat("Calculating enrichment score for drug: ", colnames(enrich.score.mat)[i], "\n", sep = "")
            geneExp.diff.drug <- geneExp.mat[,i]
            names(geneExp.diff.drug) <- row.names(geneExp.mat)
            tmp.s <- c()
            for (j in 1:nrow(enrich.score.mat)) {
                  setGenes <- geneSet.list[[j]][[2]]
                  tmp.s <- c(tmp.s, enrich.score(geneExp.diff.drug, setGenes))
            }
            enrich.score.mat[,i] <- tmp.s
      }
      
      return(enrich.score.mat)
}

### gene set enrichment score
enrich.score <- function(geneExp.diff.drug, setGenes) {
      geneExp.diff.drug <- geneExp.diff.drug[names(geneExp.diff.drug) %in% setGenes]
      enrich.score <- sum(geneExp.diff.drug) / length(setGenes)
      return(enrich.score)
}

### -------------------------- co-gene/GS score ---------------------------- ###
co.gene.GS <- function(geneExp.diff.pair, geneSet.list) {
      
      co.gene.coeff <- c()
      for (i in 1:length(geneSet.list)) {
            tmp.geneList <- geneSet.list[[i]][[2]]
            coeff <- co.gene.norm(geneExp.diff.pair, tmp.geneList)
            co.gene.coeff <- c(co.gene.coeff, coeff)
      }
      return(mean(co.gene.coeff))
}

### normalized co-gene score
co.gene.norm <- function(geneExp.diff.pair, geneList) {
      geneExp.diff.pair <- geneExp.diff.pair[row.names(geneExp.diff.pair) %in% geneList,]
      com <- sum(abs(rowSums(geneExp.diff.pair)) == 2)
      con <- sum(apply(geneExp.diff.pair, 1, prod) == -1)
      return((com - con) / length(geneList))
}