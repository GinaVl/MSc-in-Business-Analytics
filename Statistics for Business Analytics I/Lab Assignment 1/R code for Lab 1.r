#import data
require(foreign)
setwd('C:\\Users\\tzina\\OneDrive\\Documents\\LAB FILES-20201125')

#read data frame
salary <- read.spss("salary.sav", to.data.frame = T)

#view data frame
str(salary)
View(salary)

#describe data frame
library(psych)
describe(salary)
round(t(describe(salary)),2)

#keep only the numeric data of the data frame
index <- sapply(salary, class) == "numeric"
sal_num <- salary[index]
head(sal_num)

#delete id column (1st column)
sal_num <- sal_num[,-1]
head(sal_num)

#Testing for Normality 
for(i in 1:ncol(sal_num)){
  print(shapiro.test(sal_num[,i]))
}
sapply(sal_num, shapiro.test)

# Simple Hypothesis Test for the mean 
require(nortest)
x1 <- rnorm(100)
t.test(x1)
shapiro.test(x1)
lillie.test(x1)
###################################################
####### Hypothesis Testing for one sample #########
###################################################
y<-salary
#Considering the log difference between current and beginning salary
logdiff <- log(y$salnow/y$salbeg)
library('nortest')
lillie.test(logdiff) #Normality rejected
shapiro.test(logdiff) #Normality rejected
length(logdiff)
mean(logdiff) 
median(logdiff) #Reasonably close agreement between mean and variance 
t.test(logdiff, mu=0)
t.test(logdiff, mu=0.7)
qqnorm(logdiff); qqline(logdiff)
# Consider the difference 
diff<- y$salnow - y$salbeg
library('nortest')
lillie.test(diff)
shapiro.test(diff)
mean(diff)
median(diff)
wilcox.test(diff, mu=0)
wilcox.test(diff, mu=6000)
#Example from a Gamma 
x <- rgamma(20, 1, 1)
par(mfrow = c(1,2))
hist(x)
qqnorm(x); qqline(x)
wilcox.test(x, mu = 1)
par(mfrow = c(1,1))
#Greece Population example 
world95 <- read.spss("02world95.sav", to.data.frame = T)
x <- world95$populatn
shapiro.test(x)
lillie.test(x)
length(x) # n > 150
mean(x); median(x) #Mean >> Median (Use Wilcox Test!)
wilcox.test(x, mu = 10000)
#Using a transformation 
index <- as.numeric(world95$region) == 1 #Consider the OECD countries
x1 <- world95$populatn[index]
shapiro.test(x1) #Normality not ok 
lillie.test(x1) #Normality not ok 
#Take a transformation
x2 <- log(world95$populatn[index], 10) 
shapiro.test(x2) #Normality OK
lillie.test(x2) #Normality OK
t.test(x2, mu = 4)
######################################################
#### Hypothesis Testing for two dependent Samples ####
######################################################
world95 <- read.spss("02world95.sav", to.data.frame = T)
require(psych)
x<-world95$lifeexpm-world95$lifeexpf
mean(x); median(x) 
skew(x); skew(x,type=2)/sqrt(6/length(x))
kurtosi(x); kurtosi(x,type=2)/sqrt(24/length(x))
par(mfrow=c(1,2))
hist(x)
qqnorm(x)
qqline(x)
boxplot(x)
length(x)
#ks.test(logdiff,'pnorm')
library('nortest')
shapiro.test(x)
wilcox.test(world95$lifeexpm,world95$lifeexpf, paired=T)
wilcox.test(x)
########################################################
### Hypothesis Testing for two independent Samples #####
########################################################
groupA <- c(70 ,93 ,82 ,90 ,77 ,86 ,79 ,84 ,98 ,73 ,81 ,85)
groupB <-c(89 ,78 ,94 ,83 ,88 ,80 ,91 ,92 ,87 ,97)
n1<-length(groupA)
n2<-length(groupB)
dataset1 <- data.frame( grades=c(groupA, groupB),  method=factor( rep(1:2, c(n1,n2)), labels=c('A','B') ) ) 
#Test for normality for each group 
by(dataset1$grades, dataset1$method, lillie.test) #Normality ok!
by(dataset1$grades, dataset1$method, shapiro.test) #Normality ok !
#Test for the equality of variances in each group 
var.test(dataset1$grades ~ dataset1$method) #Equal variances 
t.test(dataset1$grades ~ dataset1$method, var.equal = T)
#Error Bar code 
myerrorbar<-function(x,y, horizontal=F){
  a<-0.05
  sdata <- split(x,y)
  means <- sapply( sdata,mean )
  sds <- sapply( split(x,y), sd )
  ns <- table(y)
  LB <- means + qnorm( a/2 ) * sds /sqrt(ns)
  UB <- means + qnorm( 1-a/2 ) * sds /sqrt(ns)
  nlev <- nlevels(y)
  if (horizontal) { errbar( levels(y), means, UB, LB ) 
  } else {
    errbar( 1:nlev, means, UB, LB, xlim=c(0,nlev+1), axes=F, xlab='' ) 
    axis(2)
    axis(1, at=0:(nlev+1), labels=c('',levels(y),''))	
  }
  
}
require(Hmisc)
par(mfrow = c(1,1))
myerrorbar( dataset1$grades, dataset1$method )
#Violation of an assumption 
x <- with(world95, split(density, region))
lillie.test(x$OECD)
lillie.test(x$East) 
shapiro.test(x$OECD) #Assumption Violated
shapiro.test(x$East)
qqnorm(x$OECD)
qqline(x$OECD)
qqnorm(x$East)
qqline(x$East)
wilcox.test(x$OECD, x$East)
boxplot(x$OECD, x$East, names=levels(world95$region)[1:2])
########################################
######## ANOVA #########################
########################################
grades<-c(86,79,81,70,84,90,76,88,82,89,82,68,73,71,81)
method<-rep(1:3,rep(5,3))
method<-factor(method, labels=paste('Method', LETTERS[1:3]) )
ex4.7<-data.frame( grades=grades, method=method )
ex4.7
#Conducting ANOVA
anova1 <- aov(grades~method, data=ex4.7 )
anova2 <- oneway.test( grades~method, data=ex4.7 )
summary(anova1)
# ----------------------------------------- 
# Normality of the residuals
# ----------------------------------------- 
library(nortest)
lillie.test(anova1$residuals)
shapiro.test(anova1$residuals)
qqnorm(anova1$residuals)
qqline(anova1$residuals)
# ----------------------------------------- 
# Homogeneity of variances
# ----------------------------------------- 
bartlett.test(grades~method, data=ex4.7)
fligner.test(grades~method, data=ex4.7)
library(car)
leveneTest(grades~method, data=ex4.7)
# ----------------------------------------- 
# example 4-8 - world95
# -----------------------------------------
cur.formula <-as.formula('log_pop~region')
dataset<-world95
res.anova<-aov(cur.formula,data=dataset)
library(nortest)
lillie.test(res.anova$res)
shapiro.test(res.anova$res)
bartlett.test(cur.formula,data=dataset)
fligner.test(cur.formula,data=dataset)
summary(res.anova)
library(car)
leveneTest(cur.formula,data=dataset)
qqnorm(res.anova$residuals)
qqline(res.anova$residuals)
library(Hmisc)
x<-world95$log_pop
y<-world95$region
myerrorbar( x, y ) # see command4_two_samples.txt
anova.assumptions<-function( formula, data, plot=TRUE ){ 
  
  cur.formula <-as.formula(formula)
  dataset<-data
  res.anova<-aov(cur.formula,data=dataset)
  
  res1<-list()
  p<-c()
  p[1]<-lillie.test(res.anova$res)$p.value
  p[2]<-shapiro.test(res.anova$res)$p.value
  res1$normality.pvalues<-p
  names(res1$normality.pvalues)<-c( 'KS with Lilliefors correction', 'SW test')
  
  if (plot){ qqnorm(res.anova$residuals); qqline(res.anova$residuals) }
  
  p<-c()
  p[1]<-bartlett.test(cur.formula,data=dataset)$p.value
  p[2]<-fligner.test(cur.formula,data=dataset)$p.value
  library(car)
  p[3]<-leveneTest(cur.formula,data=dataset)$Pr[1]
  res1$homoscedasticity.pvalues<-p
  names(res1$homoscedasticity.pvalues)<-c('Bartlett test', 'Fligner-Killeen test', "Levene's test")
  return(res1)
}

# ----------------------------------------- 
# multiple comparison tests
# ----------------------------------------- 


#------------------------------------------
# Tukey LSD 
# ----------------------------------------- 

res.multiple<-TukeyHSD(res.anova, conf.level = 0.95)
res.multiple

# oma changes the margins in terms of lines of text (bottom, left, top, right)
par(oma=c(1,7,1,1))
plot(res.multiple,las=1)
# ------------------------------------------
# pairwise.t.test
# ----------------------------------------- 
x<-world95$log_pop
y<-world95$region
pairwise.t.test(x,y,p.adjust.method = p.adjust.methods[1] )
for(k in 1:length(p.adjust.methods)){
  print( pairwise.t.test(x,y,p.adjust.method = p.adjust.methods[k] ) )
}
# ----------------------------------------- 
# example 4-9 - world95
# ----------------------------------------- 
anova49<-aov(lifeexpf~region,data=world95)
library(nortest)
lillie.test(anova49$res)
shapiro.test(anova49$res)
bartlett.test(lifeexpf~region,data=world95)
fligner.test(lifeexpf~region,data=world95)
library(car)
leveneTest(lifeexpf~region,data=world95)
library(nortest)
anova.assumptions( lifeexpf~region,data=world95 )
boxplot(lifeexpf~region,data=world95)
boxres<-boxplot(lifeexpf~region,data=world95, plot=F) 
out.index <- which( world95$lifeexpf %in% boxres$out )
text( boxres$group, boxres$out, labels=world95$country[out.index], pos=4 )
pairwise.wilcox.test( world95$lifeexpf, world95$region )
# ----------------------------------------- 
library(nortest)
cur.formula <-as.formula('lifeexpf~region')
dataset<- world95
res.anova<-aov(cur.formula,data=dataset)
anova49<-res.anova
library(nortest)
lillie.test(res.anova$res)
shapiro.test(res.anova$res)
bartlett.test(cur.formula,data=dataset)
fligner.test(cur.formula,data=dataset)
library(car)
leveneTest(cur.formula,data=dataset)
library(nortest)
anova.assumptions( cur.formula, data=dataset )
boxplot(cur.formula,data=dataset)
boxres<-boxplot(cur.formula,data=dataset, plot=F) 
out.index <- which( world95$lifeexpf %in% boxres$out )
text( boxres$group, boxres$out, labels=world95$country[out.index], pos=4 )
kruskal.test(lifeexpf~region,data=world95)
# ----------------------------------------- 
# example 4-10 - world95
# ----------------------------------------- 
anova410<-aov(urban~region,data=world95)
library(nortest)
lillie.test(anova410$res)
shapiro.test(anova410$res)
bartlett.test(urban~region,data=world95)
fligner.test(urban~region,data=world95)
library(car)
leveneTest(urban~region,data=world95)
library(nortest)
anova.assumptions( urban~region,data=world95 )
oneway.test(urban~region,data=world95, var.equal = FALSE)
kruskal.test(urban~region,data=world95)
par(mfrow=c(2,1))
library(Hmisc)
myerrorbar( world95$urban, world95$region ) # see command4_two_samples.txt
boxplot(urban~region,data=world95)
boxres<-boxplot(urban~region,data=world95, plot=F) 
out.index <- which( world95$urban %in% boxres$out )
text( boxres$group, boxres$out, labels=world95$country[out.index], pos=4 )
pairwise.t.test( world95$urban, world95$region, pool.sd=F )
# ----------------------------------------- 
# t-test & anova
# ----------------------------------------- 
t.test(grades~method, data=dataset1,var.eq=T)
summary(aov(grades~method, data=dataset1))

####################################
#### Two Categorical Variables #####
####################################
masticha <- read.table(file.choose(), header = T)
tab1 <- table(masticha$gender, masticha$a4_drinks)
tab1
prop.table(tab1) #Total Table Proportions 
prop.table(tab1, 1)  #Row Proportions 
prop.table(tab1, 2) #Column Proportions 
#Implementing Chi squared test
prop.test(tab1) #Chi Squared Test
chisq.test(tab1) #Chi Squared with Yates continuity correction
#Alternative Way to present the table 
summary(xtabs(~gender + a4_drinks, data = masticha))
chisq.test(tab1, correct = F)
chisq.test(tab1)
chisq.test(tab1, correct = F, simulate.p.value = T)
#Use the Fisher Exact test
fisher.test(tab1)
#Using CrossTable 
require(gmodels)
CrossTable(masticha$gender, masticha$a4_drinks)
CrossTable(masticha$gender, masticha$a4_drinks, digits = 1, format = "SPSS")
CrossTable(masticha$gender, masticha$a4_drinks, digits = 1, format = "SPSS", prop.r = T,
           prop.c = F, prop.t = F, prop.chisq = F, chisq = T, fisher = T, mcnemar = F)
#Using Sjplot 
require(sjPlot)
sjt.xtab(masticha$gender, masticha$a4_drinks, show.cell.prc = F, show.col.prc = F, show.exp = F)
sjp.xtab(masticha$gender, masticha$a4_drinks)

#Using MASS
require(MASS)
loglm(~ 1 + 2, tab1)

#Another Example 
masticha.all <- read.spss("03_masticha_all.sav", to.data.frame = T)
index<-6:9
pvalues<-matrix(nrow=4,ncol=3)
for (i in 1:4){
  var<-index[i]
  tab <- table( masticha.all$φύλο, masticha.all[,var] )	
  pvalues[i,1]<-chisq.test(tab, correct=F)$p.value
  pvalues[i,2]<-summary(loglm( ~ 1+2, tab))$tests[1,3]
  pvalues[i,3]<-fisher.test(tab)$p.value
  
}
colnames(pvalues) <- c("Chisq", "LRT", "Fisher's")
rownames(pvalues) <- c("Alcoholic drinks", "Bakery products", "Sweets", "Cosmetics")
round(pvalues, 3)

#Using variables with more categories 
x <- masticha$reason
y <- masticha$residence
sjt.xtab(x, y)
CrossTable(x,y, fisher = T, chisq = T)
mean(chisq.test(x,y)$expected < 5)
mean(chisq.test(x,y)$expected < 1)

#Testing for equality of proportions for dependent samples 
tabex4.13b <- as.table( matrix(c(794, 150, 86, 570),2,2, byrow=TRUE) )
rownames(tabex4.13b)<-c( 'Approve', 'Disapprove' )
colnames(tabex4.13b)<-c( 'Approve', 'Disapprove' )
names(dimnames(tabex4.13b)) <- c('First Survey','Second Survey')
require(gmodels)
CrossTable(tabex4.13b, prop.r = T, prop.c = T, prop.t = T, prop.chisq = F, fisher = T
           ,format = "SPSS")
chisq.test(tabex4.13b)
mcnemar.test(tabex4.13b)
#Changing the table into a data frame 
tabex4.13b <- as.table(matrix(c(794, 150, 86, 570), 2, 2, byrow = T))
rownames(tabex4.13b) <- c("Approve", "Disapprove")
colnames(tabex4.13b) <- c("Approve", "Disapprove")
names(dimnames(tabex4.13b)) <- c("First Survey", "Second Survey")
ex4.13b <- as.data.frame(tabex4.13b)
