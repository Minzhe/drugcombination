# ====================================== #
#        permute distribution            #
# ====================================== #
# Permutate gene expression data matrix.
# Input is the orginal gene expression profile,
# return the combined n time permutated vector.

### ----------------- permute co.gene ------------------ ###
### combined vector with n permutation
permute.dist.co.gene <- function(geneExp, n, verbose = FALSE) {
     
      ### get permutated vector
      permute.v <- foreach (i = 1:n, .combine = "c") %dopar% {
            ### ~~~~~~~~~~~~ function ~~~~~~~~~~~~~ ###
            permute.mat <- function(mat) {
                  v <- sample(unlist(mat, use.names = FALSE))
                  mat <- matrix(v, nrow = nrow(mat), ncol = ncol(mat))
                  return(mat)
            }
            source("code/GeneSetSyn/GeneSet.delta.z.R")
            ### ~~~~~~~~~~~~ function ~~~~~~~~~~~~~ ###
            if (verbose) cat("Permuting #.", i, "\n", sep = "")
            tmp.permute.mat <- geneExp
            tmp.permute.mat[,-1] <- permute.mat(geneExp[,-1])
            tmp.permute.mat <- delta.z(tmp.permute.mat, verbose = verbose)
            return(as.numeric(unlist(tmp.permute.mat[,-1])))
      }
      return(permute.v)
}

### --------------------- permute co.GS -------------------------- ###
permute.dist.co.GS <- function(geneExp, geneSet.list, n, verbose = TRUE) {
      
      permute.mat.list <- list()
      ### get permutated enrichment score for each gene set
      permute.mat.list <- foreach (i = 1:n) %dopar% {
            ### ~~~~~~~~~~~~ function ~~~~~~~~~~~~~ ###
            permute.mat <- function(mat) {
                  v <- sample(unlist(mat, use.names = FALSE))
                  mat <- matrix(v, nrow = nrow(mat), ncol = ncol(mat))
                  return(mat)
            }
            source("code/GeneSetSyn/GeneSet.delta.z.R")
            source("code/GeneSetSyn/GeneSet.score.R")
            ### ~~~~~~~~~~~~ function ~~~~~~~~~~~~~ ###
            if (verbose == TRUE) cat("Permuting #.", i, "\n", sep = "")
            tmp.permute.mat <- geneExp
            tmp.permute.mat[,-1] <- permute.mat(geneExp[,-1])
            tmp.permute.mat <- delta.z(tmp.permute.mat, verbose = FALSE)
            row.names(tmp.permute.mat) <- tmp.permute.mat$Gene
            tmp.permute.mat$Gene <- NULL
            
            ### get enrichment score for each gene set
            return(enrich.score.mat(tmp.permute.mat, geneSet.list, verbose = FALSE))
      }
      ### combine n permutation together
      permute.co.GS.v <- unlist(do.call("cbind", permute.mat.list))
      return(permute.co.GS.v)
}
