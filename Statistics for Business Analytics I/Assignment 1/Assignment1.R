#install packages
install.packages("robotstxt")
install.packages("rvest")

#importing libraries
library(robotstxt)
library(rvest)

# ADD HERE A SHORT DESCRIPTION OF WHAT THE WHOLE CODE DOES
# Check whether scraping is allowed from this webpage (returns TRUE)
# ATTENTION: PUT THE WHOLE URL IN ONE LINE WHEN RUNNING THE CODE

paths_allowed("https://www.metacritic.com/publication/washington-post?filter=movies&num_items=100&sort_options=date&page=0")

# Define character element "main.page", to be used recursively for defining
# multiple pages from metacritic.com
# ATTENTION: PUT THE WHOLE URL IN ONE LINE WHEN RUNNING THE CODE

main.page <- "https://www.metacritic.com/publication/washington-post?filter=movies&num_items=100&sort_options=date&page="

for (i in 0:27){ # This is a "for" loop.
  # This means that all the lines until the closure of }
  # will be repeated for different values of object i
  # thus, on the first run i=0, second run i=1,... last run i=27
  

  #Step.page concatenates pages.More specific at the 1st run (i=0) returns main.page, 
  #at the 2nd run(i=1) returns the content of main.page (i=0) and the content of page=1.This happens 28 times where at the end 
  #main.page = https://www.metacritic.com/publication/washington-post?filter=movies&num_items=100&sort_options=date&page=27, 
  #including the content of all the above pages.
  step.page <- paste(main.page,i,sep="") 
  webdata <-read_html(step.page) # OK
  
  #Creates a vector named "title", which includes the title of each movie
  title <-c(webdata %>% html_nodes("div.review_product") %>% html_nodes("a") %>%
              html_text()) 
  
  #Creates a vector named "metascore", which includes the public's review
  metascore <- c(webdata %>% html_nodes("li.review_product_score.brief_metascore") %>%
                   html_nodes("span.metascore_w") %>% html_text())
  
  #Creates a vector named "critic", which includes the critic's review from Washington Post
  critic <- c(webdata %>% html_nodes("li.review_product_score.brief_critscore") %>%
                html_nodes("span.metascore_w") %>% html_text()) 
  
  #Creates a vector named "date", which includes the posted date of the review
  date <- c(webdata %>% html_nodes("li.review_action.post_date") %>% html_text()) 
  
  if (length(date)<100 ){for (j in length(date):100){ date[j] <- date[length(date)]}} #OK
  
  #Returns a substring (of vector "date") including day (eg.DD=21) and assigns it to variable a
  a <- substr(date,12,13) 
  #Returns a substring (of vector "date") including month (eg.MM=Apr) and assigns it to variable b
  b <- substr(date,8,10)  
  #Returns a substring (of vector "date") including year (eg.YYYY=2011) and assigns it to variable d
  d <- substr(date,16,19) 
  
  #Takes the sequence of date and modify it respectively to date format DD/MM/YYYY
  date2 <- apply(cbind(a,b,d),1,paste,collapse="/") 
  #Converts date2 to the new format YYYY-MM-DD (by using class Date)
  date3 <- as.Date(date2,"%d/%b/%Y") 
  
  #Creates a dataframe, which is a collection of title,metascore,critic and date3 vectors
  df = data.frame(title,metascore,critic,date3) 
  
  #Gives specific names to the columns of the dataframe
  colnames(df) <- c("title", "metascore", "critic","date") 
  
  #Converts the character factor "metascore" to a numeric factor(would be helpful for Question 3a)
  df$metascore <- as.numeric(as.character(df$metascore)) 
  
  #Converts the character factor "critic" to a numeric factor (would be helpful for Question 3a)
  df$critic <- as.numeric(as.character(df$critic))
  
  #Returns a logical vector indicating which cases are complete,removing these with missing values or incomplete cases.
  df <- df[complete.cases(df), ] 
  
  if (i==0){ #OK
    df.tot <- df} #OK
  #for each i from greater than 0(eg. i=1,2,..27)
  if (i>0){ 
    #Union dataframes by row 
    df.tot <- rbind(df.tot,df) } 
}

#Converts the Type of vector title to character
df.tot$title <- as.character(df.tot$title) 

View(df.tot)

#2. Provides a short description of the df.tot data frame(objects and variables)
str(df.tot)

#3. Create four new variables  directly included in the data frame:
#3a.The ratio of public score / critics score for each movie (ratio)
df.tot$ratio <- df.tot$metascore/df.tot$critic

#3b.The percentile of each metascore value (perc.meta) (hint: rank())
df.tot$perc.meta <- rank(df.tot$metascore)/length(df.tot$metascore)

#3c.The percentile of each critic value (perc.critic)
df.tot$perc.critic <- rank(df.tot$critic)/length(df.tot$critic)

#3d.The year each film was reviewed
df.tot$year <- apply(cbind(substr(df.tot$date,1,4)),1,paste)

#4.Returns the film that has the highest metascore
df.tot$title[which(df.tot$metascore == max(df.tot$metascore))]

#5.Produce a boxplot of the (perc.meta) variable for each year observed in the dataset
boxplot(df.tot$perc.meta ~ df.tot$year, data = df.tot, 
        xlab = "Year",
        ylab = "Percetile of Metascore", 
        main = "Boxplot",
        col = c("cadetblue")
)

#Draws an horizontal line y=0.5
abline(h=0.5)

#As we observe at the graph, the line y=0.5 indicates the median value of Perc.Meta.
#From 2010 to 2015 we can conclude that there is a reduction of yearly Perc.Meta medians regarding y=0.5.
#We can also, add that the public reviews are lower than the median (y=0.5)
#On the other hand, from 2015 to 2020 there is a relative increase of yearly Perc.Meta medians regarding y=0.5,
#including a constant deviation from 2017 to 2019.
#In this period of time, public reviews are greater than the median.

#6. Some of the ratio values are infinity. Explain why this is happening and create a new data frame, named df.tot2, which does not include these observations

#create new data frame as dat.tot
df.tot2 <- df.tot

#Ratio is the fraction of metascore/critic.In our dataframe there are critics (denominator) with value 0.
#As we know from mathematics, division by zero is undefined. As a result, the fraction metascore/0 gives us Inf values at ratio.
#The below command returns rows, where ratio is Inf.
df.tot2[is.infinite(df.tot2$ratio), ]

#Remove those rows from our new dataframe
df.tot2 <- df.tot2[!is.infinite(df.tot2$ratio),]

#view the new data frame
View(df.tot2)

#7. Create a matrix with two columns, one with the metascore and
#one with the critic. Calculate a vector that includes the average of the two, by using the apply() function.

#Create the matrix 
matrix <- cbind(df.tot2$metascore, df.tot2$critic)
colnames(matrix) <- c("metascore", "critic")
View(matrix)

#Vector that includes the average of two (per row) using apply(),

df.tot2$average <- apply(matrix, 1, mean)

#8. Work with the df.tot2 data frame. Create a scatterplot with date on the x-axis and perc.meta on
#the y-axis. Main title should be "Metascores percentiles" and the axes named accordingly. Colour
#the dots according to whether the observation has a metascore>50 or not. Add a vertical dashed
#line for metascore=50. Make the y-axis labels to be perpendicular to the axis.

#Create the basic plot
plot(x = df.tot2$date,y = df.tot2$perc.meta,
     xlab = "Date",
     ylab = "Perc.Metascore",	 
     main = "Metascore Percentiles",
     pch=18,
     col='cornflowerblue',
     #Make the y-axis labels to be perpendicular to the axis.
     las = 2
)

#Color the dots yellow if metascore > 50
points(df.tot2$date[df.tot2$metascore>50],
       df.tot2$perc.meta[df.tot2$metascore>50],
       pch=18,
       col='yellow'
)

#Add vertical dashed line form metascore=50->where perc.meta= 0.2341613
abline(h=0.2341613, col="blue4", lwd=2, lty=2)

#9. Comment on the above graph, taking into account the possible range of values for metascore (0-100)
#Metascore indicates the public reviews. From the graph, 
#we can conclude that there is a greater variety of public reviews at the range of values 50 and above.
