#install packages
install.packages("DBI")
install.packages("RMySQL")

#import libraries
library(DBI)
library(RMySQL)
library(knitr)

#setup db connection
driver <- dbDriver("MySQL")
connect <- dbConnect(driver, user= "root", password="root", dbname="crc_fleet", host="localhost", port=3306)

#create a list with months
months = list()


for(i in 1:12)
{
  select <- paste("SELECT sum(amount) FROM reservations WHERE year(pickup_date)=2015 AND month(pickup_date)=", i, ";", sep = "")
  sendquery <- dbSendQuery(connect, select)
  data <- fetch(sendquery, n=1)
  dbClearResult(sendquery)
  data$month <- i
  months[[i]] <- data
}

#create a table with columns Month and Total Amount of current month
TotalAmount = do.call(rbind, months); names (TotalAmount) <-c("CurrentAmount","Month")
View(TotalAmount)


PreviousAmount <- 0
NextAmount <- sum(TotalAmount$CurrentAmount)
Totals <- list()
Totals <- NULL

for(i in 1:12)
{
  
  CurrentMonth <- TotalAmount[i,1]
  NextAmount <- NextAmount - CurrentMonth
  Totals[[i]] <-c(i, PreviousAmount, CurrentMonth, NextAmount)
  PreviousAmount <- PreviousAmount + TotalAmount[[i, 1]]
}

Totals <- data.frame(do.call(rbind, Totals)); names(Totals) <- c("Month","Previous Months","Current Month", "Next Months");

print(Totals)