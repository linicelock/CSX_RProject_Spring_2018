#An Introduction To Deep Learning 
#Chapter 4 Code Examples 

#Clear the workspace 
rm(list = ls())

#Loading the required packages
#install.packages(c('nnet', 'pROC'))
require(nnet)      
require(pROC)

#Summary Statistics Function 
#We will use this later to evaluate our model performance 
summaryStatistics <- function(array){
  Mean <- mean(array)
  Std <- sd(array)
  Min <- min(array)
  Max <- max(array)
  Range <- Max - Min 
  output <- data.frame("Mean" = Mean, "Std Dev" = Std, "Min" =  Min,"Max" = Max, "Range" = Range)
  return(output)
}

#Load Data 
#Modifying Data From Iris Data Set 
#Upload the necessary data
data  <- read.csv("./SpeedDating.csv", header = TRUE, stringsAsFactors = TRUE)

#Data Preprocessing
#Creating Repsponse Variable
second_date  <- ifelse(data[,1] + data[,2] == 2, 1, 0)
data  <- cbind(second_date,data)

#Transforming Charcter Vectors into Numerical vectors for feature selection
data$RaceM <- as.factor(data$RaceM)
data$RaceF <- as.factor(data$RaceF)
data$RaceM <- as.numeric(data$RaceM)
data$RaceF <- as.numeric(data$RaceF)
#Removing NA Values 
data <- data[complete.cases(data), ]

#Performing Variable Selection 
pca_data <- prcomp(data, scale = TRUE)
stdev_data <- summary(pca_data)$importance[2,]
data <- data[, which(stdev_data >= .04)]


singleLayerPerceptron <- function(max_iter = 3000, tol = .001){
  
  #Initializing weights and other parameters 
  x_train <- data[, 2:ncol(data)]
  y_train <- data[,1]
  weights <- matrix(rnorm(ncol(x_train)))
  cost <- 0
  iter <- 1
  converged <- FALSE
  AUC <- c()
  
    while(converged == FALSE){
      
      #Cross Validating Data 
      rows <- sample(1:200, 200, replace = FALSE)
      x_train <- as.matrix(x_train[rows, 1:ncol(x_train)])
      y_train <- y_train[rows]
      
      #Single Layer Perceptron 
      #Our Log Odds Threshold hear is the Average Log Odds
      weighted_sum <- 1/(1 + exp(-(x_train%*%weights)))
      y_h <- ifelse(weighted_sum <= mean(weighted_sum), 1, 0)
      error <- 1 - roc(as.factor(y_h), y_train)$auc
      AUC <- append(AUC, roc(as.factor(y_h), y_train)$auc)
      
      #Weight Updates using Gradient Descent 
      #Error Statistic := 1 - AUC 
      if (abs(cost - error) > tol || iter < max_iter){
        
        cost <- error 
        iter <-  iter + 1
    
        gradient <- matrix(ncol = ncol(weights), nrow = nrow(weights))
        for(i in 1:nrow(gradient)){
          gradient[i,1] <- (1/length(y_h))*(0.01*error)*(weights[i,1])
        }
    
        #Updating weights based on gradient with respect to each weight
        for (i in 1:nrow(weights)){
          weights[i,1] <- weights[i,1] - gradient[i,1]
        }
  
      } else {
        
        converged <- TRUE
  
      }
      
    }
  
  #Performance Statistics
  cat("The AUC of the Trained Model is ", roc(as.factor(y_h), y_train)$auc)
  cat("\nTotal number of iterations: ", iter)
  curve <- roc(as.factor(y_h), y_train)
  plot(curve, main = "ROC Curve for Single Layer Perceptron")
  cat("\nSummary Statistics of AUC over", iter, "iterations\n")
  summaryStatistics(AUC)
  
}

singleLayerPerceptron()
