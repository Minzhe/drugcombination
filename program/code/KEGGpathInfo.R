###                       KEGGpathInfo.R                       ###
### ====================================================== ###
# This R script is to constrcut Cell Grwoth Pathway (CGP) and Global Pathway (GP) information from KEGG


rm(list=ls())

library(org.Hs.eg.db)
library(KEGGgraph)
library(preprocessCore)

setwd(path.expand("~/public_html/drugcombination/program/"))

# setwd("/home/yiwei/Documents/projects/drugcombination/program")

####################################################
###  1. Make the bigGraph from pathway folder
####################################################

path <- paste(getwd(), "/data/KEGG_pathway_info/pathway/", sep = "")
xmls <- list.files(path = path, pattern = ".xml")
xmls <- paste(path, xmls, sep = "")

pathway <- list()
for(i in 1:length(xmls)) {
      temppath <- xmls[i]
      pathway[i] <- parseKGML2Graph(temppath, expandGenes=TRUE)
}

bigGraph <- mergeKEGGgraphs(pathway)
bigGraphnodes <- nodes(bigGraph)
length(bigGraphnodes) # 835

rm(list=ls()[!ls()%in%c("bigGraph","bigGraphnodes")]) # keep only bigGraph, bigGraphnodes 

####################################################
###  2. Make the bigGraph from globalpathway folder
####################################################

path <- paste(getwd(), "/data/KEGG_pathway_info/globalpathway/", sep = "")

xmls <- list.files(path = path, pattern = ".xml") # 36 global pathways
xmls <- paste(path, xmls, sep = "")

pathway <- list()
for(i in 1:length(xmls)) {
      temppath <- xmls[i]
      pathway[i] <- parseKGML2Graph(temppath, expandGenes=TRUE)
}

bigGraph2 <- mergeKEGGgraphs(pathway)
bigGraphnodes2 <- nodes(bigGraph2)
length(bigGraphnodes2) # 2539

rm(pathway, temppath, xmls, path)

# bigGraph<-bigGraph2
# bigGraphnodes<-bigGraphnodes2


###################################################################################################
###################################################################################################

##################################
###  1. Construct the CGP: r->c
##################################

g0 <- bigGraph; n0 <- bigGraphnodes

P <- length(n0)
CGP.mat <- matrix(0, nrow = P, ncol = P)
colnames(CGP.mat) <- rownames(CGP.mat) <- n0
edges <- getKEGGedgeData(g0)

for (i in 1:length(edges)) {
      act <- edges[[i]]@subtype[[1]]@name
      if (act == "activation" | act == "expression") {
            val <- 1
      } else if(act == "inhibition"){
            val <- -1
      } else {
            val <- 0
      }
      
      if (val != 0) {
            tmp <- strsplit(names(edges[i]), "~")[[1]]
            rid <- which(tmp[1] == n0)
            cid <- which(tmp[2] == n0)
            if(rid == cid) print(tmp)
            CGP.mat[rid, cid] <- val
      }
}

##################################
###  2. Construct the GP: r->c
##################################

g0 <- bigGraph2; n0 <- bigGraphnodes2

P <- length(n0)
GP.mat <- matrix(0, nrow = P, ncol = P)
colnames(GP.mat) <- rownames(GP.mat) <- n0
edges <- getKEGGedgeData(g0)

for(i in 1:length(edges)){

      if (length(edges[[i]]@subtype) > 0) act <- edges[[i]]@subtype[[1]]@name
      if (length(edges[[i]]@subtype) == 0) { 
            val <- 0
            next
      }
          
      if (act == "activation" | act == "expression") {
            val <- 1
      } else if (act == "inhibition") {
            val <- -1
      } else {
            val=0
      }
  
      if (val != 0) {
      tmp <- strsplit(names(edges[i]), "~")[[1]]
      rid <- which(tmp[1] == n0)
      cid <- which(tmp[2] == n0)
      if(rid == cid) cat(i,tmp,"\n")
      GP.mat[rid,cid] <- val
      }
}


### save image
setwd("data/")
save(CGP.mat,GP.mat,file="pathInfo.Rdata")

