########################################
####### Multiple Regression ############
########################################
setwd('C:\\Users\\tzina\\OneDrive\\Documents\\LabAssignment')
example61 <- dget("HousePrices.dat")
str(example61) #Understanding the structure
##########################################
### STEP 1: Analysis for each variable ###
##########################################
summary(example61)
require(psych)
index <- sapply(example61, class) == "numeric"
housenum <- example61[,index]
round(t(describe(housenum)),2)
#Visual Analysis for numerical variables
par(mfrow=c(2,3)); n <- nrow(housenum)
hist(housenum[,1], main=names(housenum)[1])
hist(housenum[,2], main=names(housenum)[2])
plot(table(housenum[,3])/n, type='h', xlim=range(housenum[,3])+c(-1,1), main=names(housenum)[3], ylab='Relative frequency')
plot(table(housenum[,4])/n, type='h', xlim=range(housenum[,4])+c(-1,1), main=names(housenum)[4], ylab='Relative frequency')
plot(table(housenum[,5])/n, type='h', xlim=range(housenum[,5])+c(-1,1), main=names(housenum)[5], ylab='Relative frequency')
plot(table(housenum[,6])/n, type='h', xlim=range(housenum[,6])+c(-1,1), main=names(housenum)[6], ylab='Relative frequency')
#Visual Analysis for factors 
housefac <- example61[,!index]
par(mfrow=c(1,1))
barplot(sapply(housefac,table)/n, horiz=T, las=1, col=2:3, ylim=c(0,8), cex.names=1.3)
legend('top', fil=2:3, legend=c('No','Yes'), ncol=2, bty='n',cex=1.5)
#####################################################################
########## STEP 2: Vizualization of bivariate assosiations  #########
#####################################################################
#Pairs of numerical variables
pairs(housenum)
require(corrplot)
corrplot(cor(housenum))#Use ?corrplot to explore other methods
par(mfrow=c(1,5))
#Price (our response) on variables concerning number of...e.g. number of bathrooms
for(j in 2:6){
  plot(housenum[,j], housenum[,1], xlab=names(housenum)[j], ylab='Price',cex.lab=1.5)
  abline(lm(housenum[,1]~housenum[,j]))
}

par(mfrow=c(1,4))
for(j in 3:6){
  boxplot(housenum[,1]~housenum[,j], xlab=names(housenum)[j], ylab='Price',cex.lab=1.5)
  abline(lm(housenum[,1]~housenum[,j]),col=2)
}
#Price (our response) on factor variables 
par(mfrow=c(2,3))
for(j in 1:6){
  boxplot(housenum[,1]~housefac[,j], xlab=names(housefac)[j], ylab='Price',cex.lab=2.0)
}
#####################################################
###### STEP 3: Correlations #########################
#####################################################
round(cor(housenum), 2) #Correlations valid on the numerical variables 
#Diagonal is always one since every variables is perfectly correlated with itself!
par(mfrow = c(1,1))
corrplot(cor(housenum), method = "number") 
cor(housenum$price, housenum$lotsize, method = "pearson")
#####################################################
##### STEP 4: Fitting the regression model ##########
#####################################################
model2 <- lm(price ~., data = housenum)
model1 <- lm(price ~.-bathrooms, data = housenum)
summary(model1) #Interpret the coefficients 
model0 <- lm(price ~ 1, data = housenum) #Constant model 
summary(model0)
model1 <- lm(price ~.-bathrooms, data = housenum)
anova(model0, model1)
summary(model1) #Interpret the coefficients 

#----------------------------------------------------------------------------------
# model with no intercept
#----------------------------------------------------------------------------------
model3 <- lm(price~.-bathrooms-1,data=housenum)
summary(model3)
#----------------------------------------------------------------------------------
# model with centered covariates
#----------------------------------------------------------------------------------
housenum3 <- as.data.frame(scale(housenum, center = TRUE, scale = F))
housenum3$price<-housenum$price

sapply(housenum3,mean)
sapply(housenum3,sd)
round(sapply(housenum3,mean),5)
round(sapply(housenum3,sd),2)
model4<-lm(price~.-bathrooms, data=housenum3)

#Adding factors
model6<-lm(price~., data=example61) #FULL MODEL
anova(model1, model2, model6)
#Trying to remove the constant with categorical covariates in the model 
model7<-lm(price~.-1, data=example61)
summary(model7)
true.r2 <- 1-sum(model7$res^2)/((n-1)*var(example61$price))
true.r2
#Working with the design matrix 
X <- model.matrix(model6)
model8 <- lm(example61$price ~ X[,-1]-1)

#Removing the constant and the bedrooms 
model8<-lm(example61$price~X[,-c(1,3)]-1)
summary(model8)
round(summary(model8)$coef, 2)
true.r2 <- 1-sum(model8$res^2)/((n-1)*var(example61$price))

###################################################
###### Checking the assumptions ###################
###################################################
plot(model8, which = 2) #Normality of the residuals
#Costant variance 
Stud.residuals <- rstudent(model8)
yhat <- fitted(model8)
par(mfrow=c(1,2))
plot(yhat, Stud.residuals)
abline(h=c(-2,2), col=2, lty=2)
plot(yhat, Stud.residuals^2)
abline(h=4, col=2, lty=2)
# ------------------
library(car)
ncvTest(model8)
# ------------------
yhat.quantiles<-cut(yhat, breaks=quantile(yhat, probs=seq(0,1,0.25)), dig.lab=6)
table(yhat.quantiles)
leveneTest(rstudent(model8)~yhat.quantiles)
boxplot(rstudent(model8)~yhat.quantiles)

# ------------------
# non linearity
# ------------------
library(car)
residualPlot(model8, type='rstudent')
residualPlots(model8, plot=F, type = "rstudent")

# -------------------
# Independence 
# -------------------
plot(rstudent(model8), type='l')
library(randtests); runs.test(model8$res)
library(lmtest);dwtest(model8)
library(car); durbinWatsonTest(model8)

# ------------------
# Log
# ------------------
# model 1 only with lotsize
# ------------------
par(mfrow=c(1,2))
plot(lm(price~lotsize,data=example61),2, main='Price')
plot(lm(log(price)~lotsize,data=example61),2, main='log of price')

logmodel<-lm(log(price)~lotsize,data=example61)
par(mfrow=c(2,2))
plot( logmodel, 2 )
plot( logmodel, 3 )
residualPlot(logmodel, type='rstudent')
plot(rstudent(logmodel), type='l')

ncvTest(logmodel)
residualPlots(logmodel, plot=F)

# ------------------
# model 2 only with poly-lotsize
# ------------------
par(mfrow=c(1,2))
plot(lm(price~poly(lotsize,5),data=example61),2, main='Price')
plot(lm(log(price)~poly(lotsize,5),data=example61),2, main='log of price')

logmodel<-lm(log(price)~poly(lotsize,5),data=example61)
par(mfrow=c(2,2))
plot( logmodel, 2 )
plot( logmodel, 3 )
residualPlot(logmodel, type='rstudent')
plot(rstudent(logmodel), type='l')

ncvTest(logmodel)
residualPlots(logmodel, plot=F)
# ------------------
# model 3 poly-lotsize-5 + the rest of covariates
# ------------------
par(mfrow=c(1,2))
plot(lm(price~.+poly(lotsize,5),data=example61),2, main='Price')
plot(lm(log(price)~.+poly(lotsize,5),data=example61),2, main='log of price')

logmodel<-lm(log(price)~.+poly(lotsize,5),data=example61)
par(mfrow=c(2,2))
plot( logmodel, 2 )
plot( logmodel, 3 )
residualPlot(logmodel, type='rstudent')
plot(rstudent(logmodel), type='l')

ncvTest(logmodel)
residualPlots(logmodel, plot=F)
# ------------------
# finding which covariate destroys normality
# ------------------

for (k in 3:12){ 
  p1<- shapiro.test(rstudent( lm( log(price)~.+poly(lotsize,5),data=example61[,-k] )))$p.value
  p2 <- lillie.test(rstudent( lm( log(price)~.+poly(lotsize,5),data=example61[,-k] )))$p.value 
  print( round(c(k, p1, p2 ),3) )
}

logmodel<-lm(log(price)~.+poly(lotsize,5)-stories,data=example61)
par(mfrow=c(2,2))
plot( logmodel, 2 )
plot( logmodel, 3 )
residualPlot(logmodel, type='rstudent')
plot(rstudent(logmodel), type='l')

ncvTest(logmodel)
residualPlots(logmodel, plot=F)


# ------------------
# model 4 poly(lotsize,5)+poly(garage,2) + all remaining - stories 
# ------------------


par(mfrow=c(1,2))
plot(lm(price~.+poly(lotsize,5)+poly(garage,2)-stories,data=example61),2, main='Price')
plot(lm(log(price)~.+poly(lotsize,5)+poly(garage,2)-stories,data=example61),2, main='log of price')

logmodel<-lm(log(price)~.+poly(lotsize,5)+poly(garage,2)-stories, data=example61)
par(mfrow=c(2,2))
plot( logmodel, 2 )
plot( logmodel, 3 )
residualPlot(logmodel, type='rstudent')
plot(rstudent(logmodel), type='l')

ncvTest(logmodel)
residualPlots(logmodel, plot=F)

shapiro.test(rstudent(logmodel))
lillie.test(rstudent(logmodel))

###################################
##### Variable Selection ##########
###################################
simex62 <- dget("simex62.dat")
##############################################
### Stepwise Procedures for variable selection
##############################################
mfull <- lm(y~.,data=simex62)
step(mfull, direction='both') #Stepwise 
mfull <- lm(y~.,data=simex62)
step(mfull, direction='back') #Backward 
mfull <- lm(y~.,data=simex62) 
mnull <- lm(y~1,data=simex62)
step(mnull, scope=list(lower=mnull,upper=mfull), direction='forward') #Forward
step(mnull, scope=list(lower=mnull,upper=mfull), direction='both')
summary(step(mfull, direction='both')) #Summary of the model selected by stepwise

#Using Leaps 
require(leaps)
plot(regsubsets(y ~ ., data = simex62, nvmax = 15, nbest = 1))

#Using BAS 
require(BAS)
bas.results <- bas.lm(y ~ ., data = simex62, prior = "BIC")
image(bas.results)

bas.results <- bas.lm(y ~ .,data = simex62, prior = "AIC") #Cannot seperate between models 

#################################
####### Multi Collinearity ######
#################################
#Using VIF 
require(car)
round(vif(mfull),1)
vif(step(mfull, direction = "backward"))
mstep <- step(mfull, direction = "backward")
vif(update(mstep,.~. - X1)) #VIF fixed 

#------------------------
# Other simulated Example 
#------------------------
x2 <- rnorm(100)
x3 <- rnorm(100)
x4 <- rnorm(100)
x5 <- rnorm(100)
x6 <- rnorm(100)
x7 <- rnorm(100)
x1<- x2+x3+x4
y<- 4 + x2 - 3*x4 + 5*x6 + rnorm(100,0,0.5)
example8.2<-data.frame(y=y,x1=x1,x2=x2,x3=x3,x4=x4,x5=x5,x6=x6,x7=x7)
summary(lm(y~.,data=example8.2))
dput(example8.2, file = "sim2dat.txt")
#The upper summary illustrates that the program decided to remove a variable (NA)
#due to perfect linear relationship 

#Change the relationship from perfectly linear to very high 
example8.2$x1 <- x2+x3+x4 + rnorm(100,0,0.1)
example8.2$x1 <- x2+x3+x4 + rnorm(100,0,0.1)
lm(y~.,data=example8.2) #Fixed
summary(lm(y~.,data=example8.2))$s
model2 <- lm(y~.,data=example8.2)
model2 <- lm(y~.,data=example8.2)
vif(model2) #Remove x1 first 
model3 <- step(model2, direction = "both")
vif(model3)

#Using Generalized VIF for categorical variables with more than 2 levels 
require(foreign)
temp <- read.spss("example8-1.sav", to.data.frame = T)
head(temp)
tmodel1 <- lm(price ~ ., data = temp)
temp2 <- as.data.frame(cbind(temp$price, model.matrix(tmodel1)[,-1]))
names(temp2)[1] <- "price"
tmodel2 <- lm(price ~ ., data =temp2)
vif(tmodel1)

#Another GVIF example 
test <- simex62
test$new <- as.factor(rep(1:4, 25))
mfull <- lm(y ~ ., data = test)
round(vif(mfull), 1)
##############################################################
############ LASSO using the elastic net #####################
##############################################################
require(glmnet)
X <- model.matrix(mfull)[,-1]
lasso <- glmnet(X, simex62$y)
plot(lasso, xvar = "lambda", label = T)
#Use cross validation to find a reasonable value for lambda 
lasso1 <- cv.glmnet(X, simex62$y, alpha = 1)
lasso1$lambda
lasso1$lambda.min
lasso1$lambda.1se
plot(lasso1)
coef(lasso1, s = "lambda.min")
coef(lasso1, s = "lambda.1se")
plot(lasso1$glmnet.fit, xvar = "lambda")
abline(v=log(c(lasso1$lambda.min, lasso1$lambda.1se)), lty =2)
