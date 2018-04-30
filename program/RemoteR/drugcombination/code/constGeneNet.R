###                    constGeneNet.R                      ###
### ====================================================== ###
# This R script is to construct gene network matrix
library(org.Hs.eg.db)
library(KEGGgraph)


constGeneNet <- function(file) {
      cat("Parsing gene network data ...\n")
      cat("-----------------------------\n")
      
      # read gene network file
      geneNet <- read.csv(file, header = TRUE, stringsAsFactors = FALSE)
      
      # convert gene SYMBOL name to KEGG id
      source.gene <- geneNet[,1]
      target.gene <- geneNet[,2]
      geneNet.id <- data.frame(source = source.gene, target = target.gene, stringsAsFactors = FALSE)
      
      # construct gene network matrix
      gene.list <- union(geneNet.id$source, geneNet.id$target)
      geneNet.mat <- matrix(0, length(gene.list), length(gene.list), dimnames = list(gene.list, gene.list))
      
      cat("Total", length(gene.list), "nodes, total", nrow(geneNet.id), "connnection.\n")
      
      # loop through each raw in geneNet.id to impute connected genes in matrix
      for (i in 1:nrow(geneNet.id)) {
            # symmetric matrix
            geneNet.mat[geneNet.id[i,1],geneNet.id[i,2]] <- 1
            geneNet.mat[geneNet.id[i,2],geneNet.id[i,1]] <- 1
      }
      
      # delete self connectivity (if any)
      diag(geneNet.mat) <- 0
      
      cat("Done constructing gene network matrix.\n\n")
      return(geneNet.mat)
      
      # validated for partial correlation, 26496 connection
}