#install.packages("redux")
library("redux")

#Remote Connection
r <- redux::hiredis(
  redux::redis_config(
    host = "redis-17625.c241.us-east-1-4.ec2.cloud.redislabs.com", 
    port = "17625", 
    password = "root"))

#Local Connection
r <- redux::hiredis(
  redux::redis_config(
    host = "127.0.0.1", 
    port = "6379"))

#Check connection
r$FLUSHALL()

# Load datasets
setwd('C:\\Users\\tzina\\OneDrive\\Documents\\LabAssignment')
modified_listings <- read.csv("modified_listings.csv", header = TRUE, sep=",")
emails_sent <- read.csv("emails_sent.csv", header = TRUE, sep=",")
View(modified_listings)
View(emails_sent)

#1.1: How many users modified their listing on January?
#Tip: Create a BITMAP called "ModificationsJanuary" and use "SETBIT -> 1" for each user that modified their listing. Use BITCOUNT to calculate the answer.

#Create a loop for each i in modified_listings dataframe: If field ModifiedListing = 1 AND MonthID=1 (January) then SET the bit at UserID to 1

for(i in 1:nrow(modified_listings))
{
  if ((modified_listings$ModifiedListing[i] == 1) & (modified_listings$MonthID[i]== 1)) 
  {
    r$SETBIT("ModificationsJanuary",modified_listings$UserID[i],"1")
  }
}
# Count the Users
r$BITCOUNT("ModificationsJanuary")

#1.2: How many users did NOT modify their listing in January?

#From the previous question we use BITOP (Bitwise Comparisons) to find Users with No modifications in January
r$BITOP("NOT","NoModificationsJanuary","ModificationsJanuary")
r$BITCOUNT("NoModificationsJanuary")

# 1.3: How many users received at least one e-mail per month (at least one e-mail in January and at least one e-mail in February and 
#at least one e-mail in March)?

#Create a loop for each i in emails_sent dataframe: If field MonthID = 1 then in EmailsJanuary SET the bit at UserID to 1, 
#else if MonthID = 2 then in EmailsFebruary SET the bit at UserID to 1, else if MonthID = 3 then in EmailsMarch SET the bit at UserID to 1
for(i in 1:nrow(emails_sent))
{
  if (emails_sent$MonthID[i]==1)
  {
    r$SETBIT("EmailsJanuary",emails_sent$UserID[i],"1")
  }
  else if(emails_sent$MonthID[i]==2)
  {
    r$SETBIT("EmailsFebruary",emails_sent$UserID[i],"1")
    
  }
  else 
  {
    r$SETBIT("EmailsMarch",emails_sent$UserID[i],"1")
    
  }
}


# Count the Users of EmailsJanuary
r$BITCOUNT("EmailsJanuary")
# Count the Users of EmailsFebruary
r$BITCOUNT("EmailsFebruary")
# Count the Users of EmailsMarch
r$BITCOUNT("EmailsMarch")


# BITOP (Bitwise Comparisons) is used to find Users with at least 1 mail in January AND February AND March
r$BITOP("AND","JanuaryFebruaryMarch",c("EmailsJanuary","EmailsFebruary" , "EmailsMarch"))
#Count the Users of JanuaryFebruaryMarch
r$BITCOUNT("JanuaryFebruaryMarch")

# 1.4: How many users received an e-mail in January and March but NOT in February?

#We use the BITMAPS of previous question

# BITOP is used to find Users with at least 1 email in January AND March
r$BITOP("AND","EmailsJanuaryMarch",c("EmailsJanuary","EmailsMarch"))
#Count the Users of EmailsJanuaryMarch
r$BITCOUNT("EmailsJanuaryMarch")


# BITOP is used to find Users with NO email in February
r$BITOP("NOT", "NoEmailsFebruary", "EmailsFebruary")
#Count the Users of noEmailsFebruary
r$BITCOUNT("NoEmailsFebruary")

# BITOP is used to find Users with emails in January and March but no in February
r$BITOP("AND","EmailsJanuaryMarchNoFebruary",c("EmailsJanuaryMarch","NoEmailsFebruary"))
#Count the Users of EmailsJanuaryMarchNoFebruary
r$BITCOUNT("EmailsJanuaryMarchNoFebruary")

# 1.5: How many users received an e-mail in January that they did not open but they updated their listing anyway?

#Create a loop for each i in emails_sent dataframe: If fied MonthID = 1 and field EmailOpened = 0 (not opened), 
# then in EmailNotOpenedJanuary SET the bit at UserID to 1
for(i in 1:nrow(emails_sent))
{
  if ((emails_sent$MonthID[i]==1) & (emails_sent$EmailOpened[i]==0))
  {
    r$SETBIT("EmailNotOpenedJanuary",emails_sent$UserID[i],"1")
  }
}

# Count the users of EmailNotOpenedJanuary
r$BITCOUNT("EmailNotOpenedJanuary")


# BITOP is used to find Users with modifications in January without opening their emails
r$BITOP("AND","EmailsOpenedJanuary",c("ModificationsJanuary","EmailNotOpenedJanuary"))
# Count users of EmailsOpenedJanuary
r$BITCOUNT("EmailsOpenedJanuary")

# 1.6: How many users received an e-mail in January that they did not open but they updated their listing anyway on January 
# OR they received an e-mail in February that they did not open but they updated their listing anyway on February 
# OR they received an e-mail in March that they did not open but they updated their listing anyway on March?

#The same methodology as question 1.5 will be used

######February#########
for(i in 1:nrow(modified_listings))
{
  if ((modified_listings$ModifiedListing[i] == 1) & (modified_listings$MonthID[i]== 2)) 
  {
    r$SETBIT("ModificationsFebruary",modified_listings$UserID[i],"1")
    
  }
}
# Count the Users
r$BITCOUNT("ModificationsFebruary")

for(i in 1:nrow(emails_sent))
{
  if ((emails_sent$MonthID[i]==2) & (emails_sent$EmailOpened[i]==0))
  {
    r$SETBIT("EmailNotOpenedFebruary",emails_sent$UserID[i],"1")
  }
}

# Count the user of EmailNotOpenedJanuary
r$BITCOUNT("EmailNotOpenedFebruary")

# BITOP is used to find Users with modifications in January without opening their emails
r$BITOP("AND","EmailsOpenedFebruary",c("ModificationsFebruary","EmailNotOpenedFebruary"))

#######March##########
for(i in 1:nrow(modified_listings))
{
  if ((modified_listings$ModifiedListing[i] ==1) & (modified_listings$MonthID[i]==3)) 
  {
    r$SETBIT("ModificationsMarch",modified_listings$UserID[i],"1")
    
  }
}
# Count the Users
r$BITCOUNT("ModificationsMarch")

for(i in 1:nrow(emails_sent))
{
  if ((emails_sent$MonthID[i]==3) & (emails_sent$EmailOpened[i]==0))
  {
    r$SETBIT("EmailNotOpenedMarch",emails_sent$UserID[i],"1")
  }
}

# Count the user of EmailNotOpenedJanuary
r$BITCOUNT("EmailNotOpenedMarch")

# BITOP is used to find Users with modifications in January without opening their emails
r$BITOP("AND","EmailsOpenedMarch",c("ModificationsMarch","EmailNotOpenedMarch"))

#Combine the aformentioned calculations with the result of question 1.5
r$BITOP("OR","EmailsOpened",c("EmailsOpenedJanuary","EmailsOpenedFebruary","EmailsOpenedMarch"))
#Count users of EmailsOpened
r$BITCOUNT("EmailsOpened")


# 1.7 Does it make any sense to keep sending e-mails with recommendations to sellers?
#Does this strategy really work? How would you describe this in terms a business person would understand?

#Users modified their listings per month
for(i in 1:nrow(modified_listings))
{
  if ((modified_listings$ModifiedListing[i] == 1) & (modified_listings$MonthID[i]== 1)) 
  {
    r$SETBIT("ModificationsJanuary",modified_listings$UserID[i],"1")
  }
  else if((modified_listings$ModifiedListing[i] == 1) & (modified_listings$MonthID[i]== 2)) 
  {
    r$SETBIT("ModificationsFebruary",modified_listings$UserID[i],"1")
    
  }
  else if((modified_listings$ModifiedListing[i] == 1) & (modified_listings$MonthID[i]== 3)) 
  {
    r$SETBIT("ModificationsMarch",modified_listings$UserID[i],"1")
    
  }
}

r$BITCOUNT("ModificationsJanuary")
r$BITCOUNT("ModificationsFebruary")
r$BITCOUNT("ModificationsMarch")


r$BITOP("NOT", "NoModificationsJanuary", "ModificationsJanuary")
r$BITCOUNT("NoModificationsJanuary")

r$BITOP("NOT", "NoModificationsFebruary", "ModificationsFebruary")
r$BITCOUNT("NoModificationsFebruary")

r$BITOP("NOT", "NoModificationsMarch", "ModificationsMarch")
r$BITCOUNT("NoModificationsMarch")

#Users opened their emails per month
r$BITOP("NOT", "EmailOpenedJanuary", "EmailNotOpenedJanuary")
r$BITCOUNT("EmailOpenedJanuary")
r$BITCOUNT("EmailNotOpenedJanuary")


r$BITOP("NOT", "EmailOpenedFebruary", "EmailNotOpenedFebruary")
r$BITCOUNT("EmailOpenedFebruary")
r$BITCOUNT("EmailNotOpenedFebruary")

r$BITOP("NOT", "EmailOpenedMarch", "EmailNotOpenedMarch")
r$BITCOUNT("EmailOpenedMarch")
r$BITCOUNT("EmailNotOpenedMarch")


#Combine the aformentioned calculations
r$BITOP("AND","EmailsOpenedAndModifiedJanuary",c("EmailOpenedJanuary","ModificationsJanuary"))
r$BITOP("AND","EmailsOpenedAndNoModifiedJanuary",c("EmailOpenedJanuary","NoModificationsJanuary"))
#Count users of January
r$BITCOUNT("EmailsOpenedAndModifiedJanuary")
r$BITCOUNT("EmailsOpenedAndNoModifiedJanuary")

#Combine the aformentioned calculations
r$BITOP("AND","EmailsOpenedAndModifiedFebruary",c("EmailOpenedFebruary","ModificationsFebruary"))
r$BITOP("AND","EmailsOpenedAndNoModifiedFebruary",c("EmailOpenedJanuary","NoModificationsFebruary"))
#Count users of January
r$BITCOUNT("EmailsOpenedAndModifiedFebruary")
r$BITCOUNT("EmailsOpenedAndNoModifiedFebruary")

#Combine the aformentioned calculations
r$BITOP("AND","EmailsOpenedAndModifiedMarch",c("EmailOpenedMarch","ModificationsMarch"))
r$BITOP("AND","EmailsOpenedAndNoModifiedMarch",c("EmailOpenedMarch","NoModificationsMarch"))
#Count users of January
r$BITCOUNT("EmailsOpenedAndModifiedMarch")
r$BITCOUNT("EmailsOpenedAndNoModifiedMarch")


r$BITCOUNT("EmailsOpenedAndModifiedJanuary") / r$BITCOUNT("EmailOpenedJanuary") * 100
#(7162/14297)*100

r$BITCOUNT("EmailsOpenedAndModifiedFebruary") / r$BITCOUNT("EmailOpenedFebruary") * 100
#(7185/14290)*100

r$BITCOUNT("EmailsOpenedAndModifiedMarch") / r$BITCOUNT("EmailOpenedMarch") * 100
#(7173/14395)*100
