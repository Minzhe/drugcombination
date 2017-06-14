###                        doseRes.R                       ###
### ====================================================== ###
# This R function is to read dose response curve data

readDoseRes.csv <- function(file) {
      
      cat("Reading drug dose response data ...\n")
      cat("------------\n")
      
      doseRes <- read.csv(file = file, row.names = 1, check.names = FALSE)
      
      cat("Done parsing drug treated gene expression data.\n\n")
      return(doseRes)
}