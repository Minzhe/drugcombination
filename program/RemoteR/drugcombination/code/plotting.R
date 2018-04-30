###                    score_pathway.R                     ###
### ====================================================== ###
# This R script is to score drug pair based on KEGG pathway information

library(ggplot2)
library(grid)



### --------------------------- plot heatmap --------------------------- ###
pair.ggheat <- function(pred.pair) {
      
      p <- ggplot(pred.pair, aes(drugA, drugB)) + geom_tile(aes(fill = DIGRE.score), colour = "white") + scale_fill_gradient(low = "white", high = "steelblue")
      p.title <- ggtitle("Heatmap of predicted DIGRE synergistic scores\n")
      p.theme <- theme(plot.title = element_text(size = 18, lineheight = 0.8, hjust = 0.5, face = "bold"), 
                       axis.text.x = element_text(angle = 45, hjust = 1, colour = "black"), 
                       axis.text.y = element_text(colour = "black"), 
                       axis.title.x = element_text(face = "bold"), 
                       axis.title.y = element_text(face = "bold"))
      p.axis <- scale_x_discrete(labels = abbreviate)
      
      return(p + p.title + p.theme + p.axis)
}


### -------------------------- plot barplot ------------------------------ ###
pair.ggbar <- function(pred.pair) {
      
      rankScore <- pred.pair[with(pred.pair, order(DIGRE.rank)),]
      if (nrow(rankScore) <= 15) {
            num_plot <- nrow(rankScore)
      } else {num_plot <- 15}
      
      rankScore <- data.frame(DrugPair = mapply(function(x,y) 
            paste(x, y, sep = " & "), abbreviate(rankScore$drugA), abbreviate(rankScore$drugB)), 
            Score = rankScore$DIGRE.score, stringsAsFactors = FALSE)[1:num_plot,]
      
      rankScore$DrugPair <- factor(rankScore$DrugPair, levels = rankScore$DrugPair)
      
      p <- ggplot(rankScore, aes(DrugPair, Score)) + geom_bar(stat = "identity", fill = "steelblue")
      p.title <- ggtitle("Top predicted DIGRE synergistic scores\n")
      p.theme <- theme(plot.title = element_text(size = 18, lineheight = 0.8, hjust = 0.5, face = "bold"), 
                       axis.text.x = element_text(size = 12, angle = 45, hjust = 1, colour = "black"), 
                       axis.text.y = element_text(size = 12, colour = "black"), 
                       axis.title.x = element_text(size = 12, face = "bold"), 
                       axis.title.y = element_text(size = 12, face = "bold"), 
                       plot.margin = unit(c(0.5,0.5,0.2,0.2), "cm"))
      
      return(p + p.title + p.theme)
}
