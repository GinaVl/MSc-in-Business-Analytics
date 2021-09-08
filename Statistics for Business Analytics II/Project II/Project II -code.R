#Installs
install.packages("dplyr")
install.packages("readxl")
install.packages("tidyr")
install.packages("tidyverse")
library(dplyr)
library(tidyr)
library(readxl)
library(tidyverse)
library(ggplot2)
library(aod)
library(glmnet)

library('pgmm')
library('nnet')
library('class')
library('e1071')
#library('penalizedLDA')
library('heplots')
library('tree')
library('mclust')
library('caret')


#Import dataset 
county_facts <- read_excel("stat BA II project I.xlsx", sheet = "county_facts")
votes <- read_excel("stat BA II project I.xlsx", sheet = "votes")
dictionary <- read_excel("stat BA II project I.xlsx", sheet = "dictionary")

length(county_facts)
length(votes)
length(dictionary)

#View(county_facts)
#View(votes)
View(dictionary)
dim(county_facts)
dim(votes)

#Rename the columns to be more readable
new_headers <- function(county_facts, dictionary){
  n <- nrow(dictionary)
  for (i in seq(n)){
    column_index <- which(colnames(county_facts)==dictionary[i,1])
    colnames(county_facts)[column_index] <- dictionary[i,2]
  }
  return(county_facts)
}

county_facts_new <- new_headers(county_facts, dictionary)
View(county_facts_new)

#Count NAs for each spreadsheet using apply
sapply(votes, function(x) sum(is.na(x)))

sapply(county_facts, function(x) sum(is.na(x)))

#Manipulate NAs in votes
typeof(votes$fips)
votes$fips[is.na(votes$fips)] <- 0

#Remove NAs in state_abbreviations(null state abbreviation indicates total votes per state)
typeof(county_facts$state_abbreviation)
county_facts <- county_facts %>% filter(state_abbreviation!="")
county_facts$area_name  <- str_replace(county_facts$area_name, " County", "")
colnames(county_facts)[2] <- "county"

#Keep only Democrats with party = Hillary Clinton and Bernie Standers
votes_new <- votes %>% filter(party == "Democrat" & (candidate == "Hillary Clinton" | candidate == "Bernie Sanders"))
View(votes_new)

typeof(votes_new$fips)
typeof(county_facts$fips)

#Trim spaces
county_facts$state_abbreviation <- trimws(county_facts$state_abbreviation)
county_facts$county <- trimws(county_facts$county)
county_facts$fips <- trimws(county_facts$fips)

votes_new$state_abbreviation <- trimws(votes_new$state_abbreviation)
votes_new$county <- trimws(votes_new$county)
votes_new$fips <- trimws(votes_new$fips)

#Create new dataset by merging votes_new with county_facts
elections<- votes_new %>% inner_join(county_facts, by = c("fips"))
#View(elections)

#Check for NAs
sapply(elections, function(x) sum(is.na(x)))

#Remove unnecessary 
elections$state_abbreviation.y <- NULL
elections$county.y <- NULL
colnames(elections)[2] <- "state_abbreviation"
colnames(elections)[3] <- "county"

#Create pivot table by using spread(candidate,votes)-removing fraction_votes
votes_dem <- votes_new%>%select(state,state_abbreviation,county,fips,candidate,votes)%>%group_by(state,state_abbreviation,county,fips)%>%spread(candidate,votes)

votes_dem$state_abbreviation <- trimws(votes_dem$state_abbreviation)
votes_dem$county <- trimws(votes_dem$county)
votes_dem$fips <- trimws(votes_dem$fips)

#Combine datasets county_facts, votes_new
elections_final <- votes_dem %>% inner_join(county_facts, by = c("fips"))
sapply(elections_final, function(x) sum(is.na(x)))

#Remove unnecessary columns
elections_final$state_abbreviation.y <- NULL
elections_final$county.y <- NULL
elections_final$party <- NULL

colnames(elections_final)[2] <- "state_abbreviation"
colnames(elections_final)[3] <- "county"
colnames(elections_final)[5] <- "BernieSanders_Votes"
colnames(elections_final)[6] <- "HillaryClinton_Votes"


#Add new response column Winner
elections_final$Winner <- 0
#View(elections_final)


#If Clinton has votes > Sanders then CoS = 1
elections_final$Winner <- ifelse(elections_final$HillaryClinton_Votes > elections_final$BernieSanders_Votes, 1,
                              ifelse(elections_final$HillaryClinton_Votes < elections_final$BernieSanders_Votes, 0, 'Tie'))

#Remove Ties
ties <- elections_final[elections_final$Winner == "Tie",]
#View(ties)

elections_final<-elections_final[!(elections_final$Winner=="Tie"),]
typeof(elections_final$Winner)
#View(elections_final)

#Set Winner column to factor for classification
elections_final$Winner <- as.factor(elections_final$Winner)

#Remove factor variables
elections_num <- elections_final
elections_num <- elections_num[, -c(1:6)]
View(elections_num)


dim(elections_num)#52 variables
str(elections_num)


#####################
### Correlations ####
#####################

library(corrplot)
elctions_correlations <- elections_num
#elctions_correlations$Winner <- as.numeric(as.character(elctions_correlations$Winner))

elctions_correlations <- data.frame(
  elections_num$RHI225214,
  elections_num$RHI425214,
  elections_num$RHI825214,
  elections_num$RHI525214,
  elections_num$EDU635213,
  elections_num$EDU685213,
  as.numeric(as.character(elections_num$Winner)))

colnames(elctions_correlations) = c("Black or African American", "Asian", "White alone, not Hispanic or Latino","Native Hawaiian and Other Pacific Islander","High school graduate or higher",
                                    "Bachelor's degree or higher", "Winner")


#corrplot(cor(elctions_correlations), method="circle")


round(cor(elctions_correlations), 2) 
corrplot(cor(elctions_correlations), method="ellipse",  type = "lower")


#####################
### Split Dataset ###
#####################

#Convert dataset to a dataframe
elections_num<- as.data.frame(elections_num)

n <- dim(elections_num)[1]

# k=10-fold cross-validation
k <- 6

pointers <- sample(1:n)	#random permutation of the rows

for (i in 1:k){
  index <- pointers[ ((i-1)*(n/k)+1):(i*(n/k))]	
  train <- elections_num[-index, ]
  train[,'Winner'] <- as.factor(train[,'Winner'])
  test <- elections_num[index, ]
}

dim(train)


dim(test)
View(test)

#Select Variables in basic model by using Stepwise
basic_model = glm(Winner~., data = train, family = binomial(link = "logit"))

#AIC
#step(basic_model, direction = "both")
aic_model <- step(basic_model, direction='both')
summary(aic_model)


#BIC
n = nrow(train)
bic_model <- step(basic_model, direction = "both", k=log(n))
summary(bic_model)


#From AIC keep only the significant statistically
model_after_aic <- glm(formula = Winner~PST045214+PST120214+POP010210+AGE135214+AGE295214+AGE775214+RHI125214+RHI225214+RHI325214+RHI425214+RHI525214+
               RHI825214+EDU635213+EDU685213+VET605213+HSG445213+HSG096213+HSG495213+INC910213+BZA010213+NES010213+WTN220207+RTN130207+POP060210, 
               data = elections_num, family = binomial(link = "logit"))

summary(model_after_aic)



###########################
### Logistic Regression ###
###########################
set.seed(2822001)

probabilities <- predict(model_after_aic, test, type = "response")
predicted_classes <- ifelse(probabilities > 0.5, 0, 1)
predicted_classes

# Assessing the predictive ability of the model
fitted_results <- predict(model_after_aic, test ,type='response')
fitted_results <- ifelse(fitted_results > 0.5,1,0)
fitted_results

#Accuracy
mean(predicted_classes == test$Winner)
lr_accuracy <- 1-mean(fitted_results != test$Winner)
accuracy <- confusionMatrix(table(fitted_results,test$Winner))
accuracy
#Accuracy = 0.80
lr_accuracy

###########
### SVM ###
###########

#Needs normalization

svm_model <- svm(Winner ~. , data = train)
svm_predictions <- predict(svm_model, test)
svm_predictions

#Calculates a cross-tabulation of observed and predicted classes with associated statistics
#Accuracy = 0.77
svm_accurarcy <- confusionMatrix(svm_predictions,test$Winner)
svm_accurarcy

###################
### Naive Bayes ###
###################

nb_model<- naiveBayes(Winner~. , data=train)
nb_model<- naiveBayes(y = train$Winner, x = train[1:(ncol(train)-1)])

nb_predictions <- predict(nb_model, test)
nb_predictions <- predict(nb_model, newdata=test[1:(ncol(test)-1)])
nb_predictions

#Accuracy = 0.66

nb_accurarcy <- confusionMatrix(nb_predictions,test$Winner)
nb_accurarcy

#####################
### Decision Tree ###
#####################
library(rpart)
library("rpart.plot")

#Train the decision tree
dt_model <- rpart(Winner~. , data=train)
dt_model

rpart.plot(dt_model, type=1)
rpart.rules(dt_model, style="tall")

dt_results <- as.data.frame(predict(dt_model, newdata=test, type="class"))
dt_table <- table(dt_results[,1], test$Winner)

dt_predictions <- predict(dt_model, test, type="class")

confMat <- table(test$Winner,dt_predictions)
accuracy <- sum(diag(confMat))/sum(confMat)
accuracy

dt_accuracy <- confusionMatrix(dt_predictions,test$Winner)
#Accuracy = 0.75
dt_accuracy


########################
### Model Comparison ###
########################

# Compare accuracy
names <- c("Logistic Regression", "Decision Tree", "Naive Bayes")
accuracies <- c(0.80, 0.75, 0.66)

barplot(accuracies,
        main = "Classifier's Accuracy",
        xlab = "Percentages",
        ylab = "Classifier",
        names.arg = names,
        col = "skyblue1",
        horiz = TRUE)

library(ggplot2)
library(plotly)

#Adjusted Rand Index
adjustedRI = c(
  adjustedRandIndex(fitted_results, train$Winner ),
  adjustedRandIndex(dt_predictions, train$Winner ),
  adjustedRandIndex(nb_predictions, train$Winner ))

names(adjustedRI) = c('Logistic Regression', 'Decision Tree','Naive Bayes')

p <- plot_ly(
  x= adjustedRI[order(adjustedRI, decreasing = T)],
  y =  names(adjustedRI[order(adjustedRI, decreasing = T)]),
  name = "SF Zoo",
  type = "bar"
)

p

###################
### Clustering ####
###################
library(factoextra)
library(NbClust)
library(FunCluster)

View(elections_num)
#Remove demographic variables
elections_economic <- elections_num
elections_economic <- select(elections_num, -c("PST045214","PST040210","PST120214","POP010210",
                             "AGE135214","AGE295214","AGE775214","SEX255214",
                             "RHI125214", "RHI225214","RHI325214","RHI425214",
                             "RHI525214","RHI625214","RHI725214","RHI825214",
                             "POP715213","POP645213","POP815213","EDU635213",
                             "EDU685213","VET605213"))

View(elections_economic)
View(dictionary)

#Define the clustering data omitting response variable
cluster_data <- elections_economic[1:(ncol(elections_economic)-1)]
cluster_data

library('pgmm')

## Hierarchical Clustering
cmatrix <- scale(cluster_data,scale = TRUE, center = TRUE)
head(cmatrix)

#Distance
d <- dist(cmatrix, method = "euclidean")
pfit <- hclust(d, method = "ward.D")
plot(pfit, labels = FALSE)
rect.hclust(pfit, k=2, border="red")
#To extract the members of each cluster from the pfit object
cutree(pfit, k = 2)

#Cluster dedrogram
#fviz_dend(pfit, cex = 0.5, k = 2, color_labels_by_k = TRUE)

#silhouette
sil <- hcut(cmatrix, hc_func = "hclust",  hc_method = "ward.D")
sil

#performs both the clustering and the cut.
fviz_cluster(sil, cmatrix, ellipse.type = "norm")+ theme_minimal()

#k = 2 clusters
fviz_nbclust(cmatrix, kmeans, method = "silhouette")+
  labs(subtitle = "Silhouette method")
silhouette(sil_width)

#Bootstrap
suppressMessages(library(fpc))
k_estimated <- 2
cboot_hclust <- clusterboot(cmatrix, clustermethod = hclustCBI,
                            method = "ward.D", k = k_estimated,
                            count = FALSE)
hcl_cboot_groups <- cboot_hclust$result$partition
cboot_hclust$bootmean
cboot_hclust$bootbrd

###################
##### K Means #####
###################

# picking K for kmeans
clustering_ch <- kmeansruns(cmatrix, krange = 1:10, criterion = "ch")
clustering_ch$bestk
#k = 2

clustering_asw <- kmeansruns(cmatrix, krange = 1:10, criterion = "asw")
clustering_asw$bestk
#k = 2

k.means <- kmeans(cmatrix,2)

fviz_cluster(k.means,cmatrix, ellipse.type = "norm")+ theme_minimal()

sil = silhouette(k.means$cluster,dist(cmatrix),method = 'manhattan')
fviz_silhouette(sil)


#Create a new dataframe that keeps all the economic variables and the response.
(elections_economic[k.means$cluster==1,]$Winner)==1
(elections_economic[k.means$cluster==1,]$Winner)==0

#First cluster
sum(((elections_economic[k.means$cluster==1,]$Winner)==1))
sum(((elections_economic[k.means$cluster==1,]$Winner)==0))

#Second cluster
sum(((elections_economic[k.means$cluster==2,]$Winner)==1))
sum(((elections_economic[k.means$cluster==2,]$Winner)==0))

## Plot the method
suppressMessages(library(reshape2))
criteria <- data.frame(k = 1:10, ch = scale(clustering_ch$crit), 
                       asw = scale(clustering_asw$crit))
criteria <- melt(criteria, id.vars = c("k"), 
                 variable.name = "measure", 
                 value.name = "score")

ggplot(criteria, aes(x = k, y = score, col = measure)) + 
  geom_point(aes(shape = measure)) + 
  geom_line(aes(linetype = measure)) + 
  scale_x_continuous(breaks = 1:10, labels = 1:10) + 
  scale_color_brewer(palette = "Set1") + 
  theme_minimal()
