#install packages
install.packages("dplyr")
install.packages("ggplot2")
install.packages("cowplot")

#import libraries
library(dplyr)
library(ggplot2)
library(cowplot)

#Question 1
#Load the data of Drugs in an object named Drugs
Drugs <- read.table('C:\\Users\\tzina\\OneDrive\\Documents\\Drugs.txt',header = TRUE, sep = ',')

#Remove FLAG_CODES variable from the dataset
Drugs$FLAG_CODES <- NULL

#Question 2
# Count the number of countries of the dataset
length(unique(Drugs$LOCATION))

# Make a table with the countries' acronyms and the number of datapoints (years) per country
countries <- table(Drugs$LOCATION)
View(countries)

# Sort the above table of countries in ascending order
sorted_countries <- sort(countries, decreasing = FALSE)
View(sorted_countries)


#Question 3
# Make the sorted table of countries a data.frame
sorted_countries <- as.data.frame(sorted_countries)

# View the quantiles of the sorted countries
quantile(sorted_countries$Freq)

# We need the countries with datapoints on the top 25% of the distribution (aka 75% and above).
# More specifically the countries with Freq > 41.5.
quantile <- sorted_countries[sorted_countries$Freq > quantile(sorted_countries$Freq, probs = 1 - 25/100),]
View(quantile)

# Make the selection of countries belong on the above quantile.
subset <- subset(Drugs, Drugs$LOCATION %in% quantile$Var1)
View(subset)

#Question 4
# create a graph with 4 plots using data od Q3
# Each plot should depict the development of the drug spending for all countries in the reduced dataset, over the
# available years. Each graph should depict one of the metrics (metrics = variables measuring drug
# spending in different ways, thus4 metrics= 4 graphs). In each graph, a separate line should represent
# a country. The legend should show which line represents each country. The main title of each plot
# should mention "Drug spending in XX (type of metric)".

plotA <- ggplot(subset) + geom_line(aes(x=TIME ,y=PC_HEALTHXP, color = LOCATION )) +xlim(range(subset$TIME)) +ylim(range(subset$PC_HEALTHXP))+ggtitle('Drug spending in PC_HEALTHXP')
plotB <- ggplot(subset) + geom_line(aes(x=TIME ,y=PC_GDP,      color = LOCATION )) +xlim(range(subset$TIME)) +ylim(range(subset$PC_GDP))     +ggtitle('Drug spending in PC_GDP')
plotC <- ggplot(subset) + geom_line(aes(x=TIME ,y=USD_CAP,     color = LOCATION )) +xlim(range(subset$TIME)) +ylim(range(subset$USD_CAP))    +ggtitle('Drug spending in USD_CAP')
plotD <- ggplot(subset) + geom_line(aes(x=TIME ,y=TOTAL_SPEND, color = LOCATION )) +xlim(range(subset$TIME)) +ylim(range(subset$TOTAL_SPEND))+ggtitle('Drug spending in TOTAL_SPEND')

plot_grid(plotA, plotB, plotC, plotD, 
          nrow = 2,
          ncol = 2,
          labels = "AUTO")


#Question 5
# Create an element with the data of Belgium
Data <- subset(Drugs, Drugs$LOCATION %in% 'BEL')
View(Data)

# Create a vector with the range (in years) of available data points for Belgium, with two elements, the
# minimum and maximum years
Years <-c(min(Data$TIME), max(Data$TIME))


# Create an element with the number of available data points for Belgium
Data.points <- subset(sorted_countries$Freq, sorted_countries$Var1 %in% 'BEL')

# Find the differences of expenditures regarding the year and the year before 
d1 <- diff(Data$PC_HEALTHXP, lag = 1)
d2 <- diff(Data$PC_GDP, lag = 1)
d3 <- diff(Data$USD_CAP, lag = 1)
d4 <- diff(Data$TOTAL_SPEND, lag = 1)

# Find the YearlyProbability of each variable as a fraction of the length of positive d calculated above / length of all variable
YearlyProb1 <- length(d1[which(d1>0)])/length(Data$PC_HEALTHXP)
YearlyProb2 <- length(d2[which(d2>0)])/length(Data$PC_GDP)
YearlyProb3 <- length(d3[which(d3>0)])/length(Data$USD_CAP)
YearlyProb4 <- length(d4[which(d4>0)])/length(Data$TOTAL_SPEND)

# Create a vector with all YearlyProbs
YearlyProb <- c(YearlyProb1, YearlyProb2, YearlyProb3, YearlyProb4)

# Return the dbinom(x, size, prob) of each variable.(rounded)
# Where x= at least 4 out of 5 years, which means that we have to calculate the increase of drug expenditure in at least 4 of the 5 (where x >= 4), 
# size = 5 next years, prob = YearlyProb calculated above.
FiveYeProb1 <- dbinom(4, size=5, YearlyProb1) + dbinom(5, size=5, YearlyProb1)
FiveYeProb2 <- dbinom(4, size=5, YearlyProb2) + dbinom(5, size=5, YearlyProb2)
FiveYeProb3 <- dbinom(4, size=5, YearlyProb3) + dbinom(5, size=5, YearlyProb3)
FiveYeProb4 <- dbinom(4, size=5, YearlyProb4) + dbinom(5, size=5, YearlyProb4)

# Create a vector with all FiveYeProbs.
FiveYeProb <- c(FiveYeProb1, FiveYeProb2, FiveYeProb3, FiveYeProb4)


# Create a list with all the above elements
list <- list(Data, Years, Data.points, YearlyProb, FiveYeProb)
print(list)

#Question 6
calculate_probability <- function(DATA = NULL,METRIC='pc.gdp',nofY=5)
{
  #Import the dataset
  Drugs <- read.table('C:\\Users\\tzina\\OneDrive\\Documents\\Drugs.txt',header = TRUE, sep = ',')
  
  #Remove FLAG_CODES variable from the dataset
  Drugs$FLAG_CODES <- NULL
  
  if(DATA %in% Drugs$LOCATION)
  {
    #Create a subset of the aforementioned Location (DATA) and make it a dataframe
    subset <- subset(Drugs, Drugs$LOCATION %in% DATA)
    subset <- as.data.frame(subset)
    
    
    # Calculate the Data.points of the aforementioned Location (DATA) and make it a dataframe
    Data.points <- table(subset$LOCATION)
    Data.points <- as.data.frame(Data.points)
    Data.points <- Data.points$Freq
    
    # Calculate the minYear and maxYear of the dataframe
    minYear <- min(subset$TIME)
    maxYear <- max(subset$TIME)
    
    # Calculate the YearlyProb and FiveYeProb depend on the METRIC value
    if(METRIC == 'pc.tot')
    {
      d <- diff(subset$PC_HEALTHXP,lag = 1)
      YearlyProb <- length(d[which(d>0)])/length(subset$PC_HEALTHXP)
      FiveYeProb <- dbinom(nofY-1, size=nofY, YearlyProb) + dbinom(nofY, size=nofY, YearlyProb)
    }  
    else if(METRIC == 'pc.gdp')
    {
      d <- diff(subset$PC_GDP,lag = 1)
      YearlyProb <- length(d[which(d>0)])/length(subset$PC_GDP)
      FiveYeProb <- dbinom(nofY-1, size=nofY, YearlyProb) + dbinom(nofY, size=nofY, YearlyProb)
    }
    else if(METRIC == 'per.ca')
    {
      d <- diff(subset$USD_CAP,lag = 1)
      YearlyProb <- length(d[which(d>0)])/length(subset$USD_CAP)
      FiveYeProb <- dbinom(nofY-1, size=nofY, YearlyProb) + dbinom(nofY, size=nofY, YearlyProb)
    }
    else if(METRIC == 'total')
    {
      d <- diff(subset$TOTAL_SPEND,lag = 1)
      YearlyProb <- length(d[which(d>0)])/length(subset$TOTAL_SPEND)
      FiveYeProb <- dbinom(nofY-1, size=nofY, YearlyProb) + dbinom(nofY, size=nofY, YearlyProb)
    }
    else 
    {
      print('Please provide a valid METRIC argument!')
    }
    
    # Outcome of the function
    if (Data.points[1] >= 10)
    {
      if(METRIC == 'pc.tot' || METRIC == 'pc.gdp' || METRIC == 'per.ca' || METRIC == 'total')
      {
        paste('Based on',Data.points ,'datapoints from years', minYear,'to',maxYear,'the probability that',DATA,'will increase its drug expenditure, in terms of',METRIC,'in at least',(nofY-1),'years in the period',(maxYear+1),'to',
              (maxYear+1+nofY) ,'is the estimated probability',FiveYeProb)
      }
      else
      {
        print('Unable to calculate  with invalid METRIC argument!')
      }
    }
    else
    {
      paste ('Unable to calculate probability (n< 10)')
    }
  }
  else
  {
    print('Please provide a valid DATA argument in order to continue!')
  }
}


# Use the function to calculate the estimated probability of country FIN where data.points > 10
calculate_probability(DATA = 'FIN',METRIC= 'pc.gdp',nofY=5)

# Use the function to calculate the estimated probability of country RUS where data.points < 10
calculate_probability(DATA = 'RUS',METRIC= 'pc.gdp',nofY=5)

#  Use the function to calculate the estimated probability of country FRA with another METRIC and nofY
calculate_probability(DATA = 'FRA',METRIC= 'per.ca',nofY=7)

#  Use the function to calculate the estimated probability of country POL with dummy METRIC and nofY
calculate_probability(DATA = 'POL',METRIC= 'ttt',nofY=7)

#  Use the function to calculate the estimated probability of country POL with dummy METRIC and nofY
calculate_probability(DATA = 'GRE',METRIC= 'ttt',nofY=7)
