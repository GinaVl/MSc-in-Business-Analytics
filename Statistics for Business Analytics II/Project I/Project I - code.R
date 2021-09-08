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
library(viridis)
library(hrbrthemes)
library(aod)
library(glmnet)

#Import dataset 
setwd('C:\\Users\\tzina\\OneDrive\\Documents\\LabAssignment')
county_facts <- read_excel("stat BA II project I.xlsx", sheet = "county_facts")
votes <- read_excel("stat BA II project I.xlsx", sheet = "votes")
dictionary <- read_excel("stat BA II project I.xlsx", sheet = "dictionary")

length(county_facts)
length(votes)
length(dictionary)

View(county_facts)
View(votes)
dim(county_facts)
dim(votes)

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
View(elections)

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


#Add new response column CoS(~Clinton over Sanders)
elections_final$CoS <- 0

#If Clinton has votes > Sanders then CoS = 1
elections_final$CoS <- ifelse(elections_final$HillaryClinton_Votes > elections_final$BernieSanders_Votes, 1,
                              ifelse(elections_final$HillaryClinton_Votes < elections_final$BernieSanders_Votes, 0, 'Tie'))

#Remove Ties
ties <- elections_final[elections_final$CoS == "Tie",]
View(ties)

elections_final<-elections_final[!(elections_final$CoS=="Tie"),]
typeof(elections_final$CoS)
View(elections_final)
########################################################################################################
#Explanatory Data Analysis
ggplot(elections, aes(fill=candidate, y=fraction_votes, x=state_abbreviation)) + 
  geom_bar(position="stack", stat="identity") +
  scale_fill_viridis(discrete = T) +
  ggtitle("Votes Ratio per State") +
  theme_ipsum() +
  xlab("") + ylab("")

#Histograms
par(mfrow=c(3,3))

hist(elections_final$SEX255214, main = "Histogram of Female people", xlab = "percent, 2014",col="slateblue4")
hist(elections_final$HSD310213, main = "Histogram of People per household", xlab = "2009-2013",col="slateblue4")
hist(elections_final$VET605213, main = "Histogram of Veterans", xlab = "2009-2013",col="slateblue4")

hist(elections_final$AGE135214, main = "Histogram of People under 5 years", xlab = "percent, 2014",col="slateblue4")
hist(elections_final$AGE295214, main = "Histogram of People under 18 years", xlab = "percent, 2014",col="slateblue4")
hist(elections_final$AGE775214, main = "Histogram of People 65 years and over", xlab = "percent, 2014",col="slateblue4")

hist(elections_final$POP715213, main = "Histogram of People Living in same house 1 year & over", xlab = "percent, 2009-2013",col="slateblue4")
hist(elections_final$POP645213, main = "Histogram of Foreign born people", xlab = "percent, 2009-2013",col="slateblue4")
hist(elections_final$POP815213, main = "Histogram of Language other than English spoken at home", xlab = "percent, 2009-2013",col="slateblue4")

#Boxplots
require(gridExtra)
library("cowplot")

ba <- ggplot(data=elections_final,aes(CoS,RHI225214)) + geom_boxplot(aes(fill=CoS)) + stat_boxplot(geom = "errorbar") + 
ggtitle("Black or African American alone, percent, 2014") + scale_x_discrete(name = "Candidate", labels = c("Bernie Sanders", "Hillary Clinton")) + 
xlab("Candidate") + ylab("") + guides(fill=F) + theme_bw()

bf <- ggplot(data=elections_final,aes(CoS,SBO315207)) + geom_boxplot(aes(fill=CoS)) + stat_boxplot(geom = "errorbar") + 
ggtitle("Black-owned firms, percent, 2007 ") + scale_x_discrete(name = "Candidate", labels = c("Bernie Sanders", "Hillary Clinton")) + 
xlab("Candidate") + ylab("") + guides(fill=F) + theme_bw()

bp <- ggplot(data=elections_final,aes(CoS,PVY020213)) + geom_boxplot(aes(fill=CoS)) + stat_boxplot(geom = "errorbar") + 
ggtitle("People below poverty level, percent, 2009-2013") + scale_x_discrete(name = "Candidate", labels = c("Bernie Sanders", "Hillary Clinton")) + 
xlab("Candidate") + ylab("") + guides(fill=F) + theme_bw()

mt <- ggplot(data=elections_final,aes(CoS,EDU635213)) + geom_boxplot(aes(fill=CoS)) + stat_boxplot(geom = "errorbar") + 
  ggtitle("High school graduate or higher, percent of persons age 25+, 2009-2013") + scale_x_discrete(name = "Candidate", labels = c("Bernie Sanders", "Hillary Clinton")) + 
  xlab("Candidate") + ylab("") + guides(fill=F) + theme_bw()

bcs <- ggplot(data=elections_final,aes(CoS,EDU685213)) + geom_boxplot(aes(fill=CoS)) + stat_boxplot(geom = "errorbar") + 
ggtitle("Bachelor's degree or higher, percent of people age 25+, 2009-2013") + scale_x_discrete(name = "Candidate", labels = c("Bernie Sanders", "Hillary Clinton")) + 
xlab("Candidate") + ylab("") + guides(fill=F) + theme_bw()

mi <- ggplot(data=elections_final,aes(CoS,SBO415207)) + geom_boxplot(aes(fill=CoS)) + stat_boxplot(geom = "errorbar") + 
  ggtitle("Hispanic-owned firms, percent, 2007") + scale_x_discrete(name = "Candidate", labels = c("Bernie Sanders", "Hillary Clinton")) + 
  xlab("Candidate") + ylab("") + guides(fill=F) + theme_bw()


plot_grid(ba, bf, bp, bcs, mi, mt,
          labels = c("A", "B", "C", "D", "E", "F"),
          ncol = 3, nrow = 2)
#Map
library(maps)
library(scales)
library(ggmap)
library(mapdata)

usa <- map_data("state")
dim(usa)
View(usa)

format <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  x
}

usa$state <- format(usa$region)
usa$region <- NULL

mapping <- function(x){
  data_map <- elections %>% filter(candidate==x) %>% group_by(state) %>%summarize(Votes=mean(fraction_votes))
  data_map_fin <- inner_join(data_map,usa,by="state")
  
  usa_base <- ggplot(data = usa, mapping = aes(x = long, y = lat, group = group)) + 
    coord_fixed(1.3) + geom_polygon(color = "black", fill = "white") 
  
  fin_map <- usa_base + geom_polygon(data = data_map_fin, aes(fill = Votes), color = "white") 
  
  ditch_the_axes <- theme(
    axis.text = element_blank(),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    panel.border = element_blank(),
    panel.grid = element_blank(),
    axis.title = element_blank()
  )
  
  fin_map + scale_fill_distiller(palette = 7, labels = percent,breaks = pretty_breaks(n = 10)) +
  guides(fill = guide_legend(reverse = TRUE)) + ditch_the_axes + ggtitle(paste0(x," across the USA")) + theme_bw()
}
mapping("Hillary Clinton")
########################################################################################################

#Select variables Lasso and Step
#Create a replica of elections_final removing non socioeconomic variables
elections_num <- elections_final
elections_num$state <- NULL
elections_num$state_abbreviation <- NULL
elections_num$county <- NULL
elections_num$fips <- NULL
elections_num$BernieSanders_Votes <- NULL
elections_num$HillaryClinton_Votes <- NULL
str(elections_num)
elections_num$CoS <- as.factor(elections_num$CoS)
#LASSO
set.seed(2822001)
X <- model.matrix(CoS~., elections_num)
lasso <- glmnet(X, elections_num$CoS, standardize = T, alpha = 1, family = "binomial")
plot(lasso, xvar = "lambda", label = T)

lasso1 <- cv.glmnet(X, elections_num$CoS, standardize=TRUE, alpha = 1, family = "binomial", type.measure='mse')
plot(lasso1)

plot(lasso1$glmnet.fit, xvar = "lambda")
abline(v=log(c(lasso1$lambda.min, lasso1$lambda.1se)), lty =2)
#Return coefficients with values
coeff<-coef(lasso1,s='lambda.1se',exact=TRUE)
index<-which(coeff!=0)
variables<-row.names(coeff)[index]
variables
length(variables)
lasso1$lambda.min#0.0001783874
lasso1$lambda.1se#0.004217952

#STEPWISE
fit_glm <- glm(CoS~PST120214+AGE135214+AGE295214+AGE775214+SEX255214+RHI225214+RHI325214+RHI425214+RHI625214+RHI825214+  
               EDU635213+EDU685213+VET605213+HSG445213+HSG096213+HSG495213+INC910213+BZA115213+SBO215207+SBO415207+LND110210, 
               data = elections_num, family = binomial(link = "logit"))

summary(fit_glm)

maic <- step(fit_glm, direction='both')
summary(maic)

length(elections_num$CoS)
mbic <- step(fit_glm, direction='both',k = log(2769))
summary(mbic)

#VIF
require(car)
#Everything below 10
round(vif(mbic),2)

#Check value of McFadden
library(DescTools)
PseudoR2(mbic,'all')

#Comparison of deviance between final model and null model
with(mbic, null.deviance - deviance)
with(mbic, df.null - df.residual)
with(mbic, pchisq(null.deviance - deviance, + df.null - df.residual, lower.tail = FALSE))
