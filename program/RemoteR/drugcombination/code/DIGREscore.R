### ======================================================================================================== ###
###                                               DIGREscore.R                                               ###
### ======================================================================================================== ###
# This R function is to calculate pair synergistic score based
# on DIGRE algorithm.


### Scoring drug pair synergistic score	
DIGREscore <- function(geneExpDiff, doseRes, CGP.mat, GP.mat, fold = 0.60, verbose = TRUE) {
      
      if (verbose) {
            cat("Start scoring compound pairs by DIGRE model ...\n------------------------------------------------------\n")    
      }
      
      ### Estimate similarities between two drugs
      ## generate drug pairs
      drugName <- colnames(geneExpDiff)
      drugPair <- combn(drugName, 2)
      
      ## construct similarity score table
      sim.score.mat <- matrix(NA, nrow = ncol(drugPair), ncol = 10, dimnames = list(1:ncol(drugPair), c("drugA", "drugB", "Similarity", "mPositive", "mNegative", "mFalse", "iPositive", "iNegative", "iFalse", "Score")))
      sim.score.mat <- data.frame(sim.score.mat)
      
      ## loop through all drug pairs
      for (i in 1:ncol(drugPair)) {
            drugA <- drugPair[1,i]
            drugB <- drugPair[2,i]
            sim.score.mat[i, "drugA"] <- drugA
            sim.score.mat[i, "drugB"] <- drugB
            
            ## calculate (drugA, drugB) and (drugB, drugA) respectively
            sim.score.pair <- matrix(NA, nrow = 2, ncol = 10, dimnames = list(1:2, c("drugA", "drugB", "Similarity", "mPositive", "mNegative", "mFalse", "iPositive", "iNegative", "iFalse", "Score")))
            sim.score.pair <- data.frame(sim.score.pair)
            for (j in 1:2) {
                  if (j == 1) tempPair <- c(drugA, drugB)
                  if (j == 2) tempPair <- c(drugB, drugA)
                  sim.score.pair[j,"drugA"] <- tempPair[1]
                  sim.score.pair[j,"drugB"] <- tempPair[2]
                  geneExpDiff.pair <- geneExpDiff[,tempPair]
                  
                  # compare to fold change cut off
                  geneExpDiff.pair[geneExpDiff.pair > fold] <- 1
                  geneExpDiff.pair[geneExpDiff.pair < -fold] <- -1
                  geneExpDiff.pair[abs(geneExpDiff.pair) <= fold] <- 0
                  
                  # marginal relationship: effect on same gene in CGP
                  mSim.pair <- mSim.score(geneExpDiff.pair = geneExpDiff.pair, CGP.mat = CGP.mat)
                  sim.score.pair[j,"mPositive"] <- mSim.pair$mPos
                  sim.score.pair[j,"mNegative"] <- mSim.pair$mNeg
                  sim.score.pair[j,"mFalse"] <- mSim.pair$mNon
                  
                  # interaction relationship: effect of upstream gene in GP
                  iSim.pair <- iSim.score(geneExpDiff.pair = geneExpDiff.pair, CGP.mat = CGP.mat, GP.mat = GP.mat)
                  sim.score.pair[j,"iPositive"] <- iSim.pair$iPos
                  sim.score.pair[j,"iNegative"] <- iSim.pair$iNeg
                  sim.score.pair[j,"iFalse"] <- iSim.pair$iNon
                  
                  # calculate the ratio
                  denom <- iSim.pair$countB.updown
                  if (denom > 0) {
                        ratio <- (mSim.pair$mSim + iSim.pair$iSim) / denom
                  } else {ratio <- 0}
                  if (ratio == 0) {
                        ratio <- 0.01
                  }
                  # adjust ratio to avoid same ratio for different drug pair (use geneExp data before fold change curation)
                  max.diff <- max(abs(geneExpDiff[row.names(geneExpDiff)%in%row.names(CGP.mat),tempPair]))
                  # cat(tempPair, ratio, max.diff, "\n", sep ="\t")
                  ratio <- ratio * max.diff
                  
                  if (class(doseRes) == "character" && doseRes == "noDose") {
                        sim.score.pair[j,"Similarity"] <- round(ratio, 5)
                  } else {
                        # calculate residual effect
                        fA <- doseRes[1,tempPair[1]]
                        fB <- doseRes[1,tempPair[2]]
                        f2B <- doseRes[2,tempPair[2]]
                        effect <- 1-(1-fA)*(1-ratio*f2B)*(1-(1-ratio)*fB)
                        effect <- effect-(1-(1-fA)*(1-fB))
                        sim.score.pair[j,"Similarity"] <- round(ratio, 5)
                        sim.score.pair[j,"Score"] <- round(effect, 5)
                  }
                  
            }
           sim.score.mat[i,-(1:2)] <- colMeans(sim.score.pair[,-(1:2)])
      }
      if (class(doseRes) == "character" && doseRes == "noDose") {
            sim.score.mat$Score <- NULL
            pair.rank <- data.frame(sim.score.mat[,c("drugA", "drugB", "Similarity")], Rank = rank(-sim.score.mat$Similarity))
            colnames(pair.rank)[3] <- "Score"
      } else {
            pair.rank <- data.frame(sim.score.mat[,c("drugA", "drugB", "Score")], Rank = rank(-sim.score.mat$Score))
      }
      
      if (verbose) {
            cat("Done scoring.\n")  
      }
      
      return(list(scoreRank = pair.rank, rawTable = sim.score.mat))

} # function
    
    


### Marginal similarity: effect on same gene in CGP
mSim.score <- function(geneExpDiff.pair, CGP.mat) {
      
      # filter genes in CGP
      geneExpDiff.pair <- geneExpDiff.pair[row.names(geneExpDiff.pair) %in% row.names(CGP.mat),]
      
      # marginal relationship
      mPos <- sum(rowSums(geneExpDiff.pair) == 2)
      mNeg <- sum(rowSums(geneExpDiff.pair) == -2)
      mNon <- sum(apply(geneExpDiff.pair, 1, prod) == -1)
      mSim <- mPos + mNeg - mNon
      mPara <- list(mPos = mPos, mNeg = mNeg, mNon = mNon, mSim = mSim)
      
      return(mPara)
}


### Interaction relationship: effect of upstream gene in GP
iSim.score <- function(geneExpDiff.pair, CGP.mat, GP.mat) {
      
      # filter genes 
      idx <- (row.names(geneExpDiff.pair) %in% row.names(CGP.mat)) & (row.names(geneExpDiff.pair) %in% row.names(GP.mat))
      geneExpDiff.pair <- geneExpDiff.pair[idx,]
      idx <- row.names(GP.mat) %in% row.names(geneExpDiff.pair)
      sGP.mat <- GP.mat[idx,idx]
      
      # sort genes before comparsion
      geneExpDiff.pair <- geneExpDiff.pair[order(row.names(geneExpDiff.pair)),]
      sGP.mat <- sGP.mat[order(row.names(sGP.mat)), order(colnames(sGP.mat))]
      
      # calculate interation relationship
      geneExp.drugA <- geneExpDiff.pair[,1]
      geneExp.drugB <- geneExpDiff.pair[,2]
      
      int.mat <- outer(geneExp.drugA, geneExp.drugB, FUN = "*")
      diag(sGP.mat) <- diag(int.mat) <- 0
      
      iPos <- sum(sGP.mat + int.mat == 2)
      iNeg <- sum(sGP.mat + int.mat == -2)
      iNon <- sum(sGP.mat * int.mat == -1)
      # iSim <- iPos + iNeg - iNon
      iSim <- iPos + iNeg
      
      # count all up- and down-regulated genes induced by drug B (used as denominator for normalization in the next step)
      countB.updown <- sum(abs(geneExp.drugB) > 0)
      iPara <- list(iPos = iPos, iNeg = iNeg, iNon = iNon, iSim = iSim, countB.updown = countB.updown)
      
      return(iPara)
}

