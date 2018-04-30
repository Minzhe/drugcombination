####################################################################################
###                              IUPUI_CCBB.R                                    ###
####################################################################################
# Gene expression-based drug combination effect model


IUPUI_CCBB <- function(geneExp, lowIC.drug, verbose = 1) {
      geneExp <- collapseProbe(geneExp)
      diffGene <- diffGene.ANOVA(geneExp = geneExp, verbose = verbose)
      core.diffGene <- select.score.gene(diffGene = diffGene, lowIC.drug = lowIC.drug, verbose = verbose)
      score.mat <- inter.score(core.diffGene = core.diffGene, verbose = verbose)
      return(score.mat)
}


###############################  function  ####################################
collapseProbe <- function(geneExp) {
      cat("Collapse multiple probes to genes ...\n")
      geneExp$Genename <- sapply(strsplit(geneExp$Genename, " ", fixed = TRUE), "[[", 1)
      drugNames <- colnames(geneExp)[-1]
      geneExp <- aggregate(geneExp[,-1], by = list(Genename = geneExp$Genename), FUN = max)
      colnames(geneExp)[-1] <- drugNames
      return(geneExp)
}

diffGene.ANOVA <- function(geneExp, verbose) {
      
      # ----- construct differential genes table ----- #
      probe.names <- geneExp$Genename
      drug.names <- unique(colnames(geneExp)[-1])
      drug.names <- drug.names[!drug.names %in% "Neg_control"]
      diffGene <- matrix(NA, nrow = length(probe.names), ncol = length(drug.names), dimnames = list(NULL, drug.names))
      
      # -------------- ANOVA --------------- #
      negExp <- geneExp[,colnames(geneExp) == "Neg_control"]
      
      if (verbose >= 1) cat("Doing anova analysis to find out sensitive probes ...\n")
      ### iterate through all drugs
      for (i in 1:length(drug.names)) {
            tmp.drug <- drug.names[i]
            tmpExp <- geneExp[,colnames(geneExp) == tmp.drug]
            
            ## iterate through all probes
            tmp.diffGene <- foreach (j = 1:length(probe.names), .combine = "c") %dopar% {
                  tmp.negExp <- as.numeric(negExp[j,])
                  tmpExp.probe <- as.numeric(tmpExp[j,])
                  data <- data.frame(X = c(tmp.negExp, tmpExp.probe), group = factor(c(rep(0, length(tmp.negExp)), rep(1, length(tmpExp.probe)))))
                  
                  ## fit model
                  fit <- aov(X ~ group, data)
                  fit.anova <- anova(fit)
                  p.value <- fit.anova$`Pr(>F)`[1]
                  
                  if (p.value < 0.05) {
                        if (verbose == 2) cat("Probe: ", probe.names[j], " Drug: ", drug.names[i], " is significant!\n", sep = "")
                        if (mean(tmpExp.probe) > mean(tmp.negExp)) {
                              diffGene.sig <- 1
                        } else if (mean(tmpExp.probe) < mean(tmp.negExp)) {
                              diffGene.sig <- -1
                        }
                  } else {
                        diffGene.sig <- 0
                  }
                  return(diffGene.sig)
            }
            diffGene[,i] <- tmp.diffGene
            cat("Done drug ", drug.names[i], ".\n", sep = "")
      }
      return(diffGene)
}

select.score.gene <- function(diffGene, lowIC.drug, verbose) {
      if (verbose >= 1) cat("Selecting core gene sets ...\n")
      if (lowIC.drug == "all") {
            return(diffGene)
      } else {
            lowIC.diffGene <- diffGene[,colnames(diffGene) %in% lowIC.drug]
            sensi.probe.idx <- apply(lowIC.diffGene, 1, any)
            core.diffGene <- diffGene[sensi.probe.idx,]
            return(core.diffGene)
      }
}

inter.score <- function(core.diffGene, verbose) {
      drug.list <- colnames(core.diffGene)
      score.mat <- t(combn(drug.list, 2))
      score.mat <- data.frame(cbind(score.mat, syn = NA, antag = NA, sensi = NA, score = NA), stringsAsFactors = FALSE)
      colnames(score.mat)[c(1,2)] <- c("drugA", "drugB")
      
      cat("Calculating interaction score ...\n")
      registerDoParallel(cores=detectCores())
      syn.ant.sensi <- foreach (i = 1:nrow(score.mat), .combine = "rbind") %dopar% {
            drug.A <- score.mat[i,1]
            drug.B <- score.mat[i,2]
            drug.A.Exp <- core.diffGene[, colnames(core.diffGene) == drug.A]
            drug.B.Exp <- core.diffGene[, colnames(core.diffGene) == drug.B]
            syn <- sum((drug.A.Exp * drug.B.Exp) == 1)
            antag <- sum((drug.A.Exp * drug.B.Exp) == -1)
            sensi <- sum(mapply(any, as.logical(drug.A.Exp), as.logical(drug.B.Exp)))
            return(c(syn, antag, sensi))
      }
      score.mat[,3:5] <- apply(syn.ant.sensi, 2, as.numeric)
      score.mat$score <- round((score.mat$syn - score.mat$antag) / nrow(core.diffGene), 4)
      score.mat <- score.mat[with(score.mat, order(-score, -sensi)),]
      score.mat$Rank <- 1:nrow(score.mat)
      
      return(score.mat)
}