# Libraries
library("mongolite")
library("jsonlite")

setwd('C:\\Users\\tzina\\OneDrive\\Documents\\LabAssignment')
# Open a connection to MongoDB
mongo <- mongo(collection = "bikescollection",  db = "demo", url = "mongodb://localhost")
#mongo$remove('{}')

#Sys.setlocale(category = "LC_ALL", locale = "Greek")

# Upload json files from files_list.txt
json_data <- read.table("files_list.txt", header = FALSE, sep="\n")
View(json_data)

# Data Cleansing
DataCleansing <- function(x) {
  
  #Deal with Mileage
  x$ad_data$Mileage <- as.numeric(gsub('[,km]', '', x$ad_data$Mileage))
  
  #Deal with Cubic capacity
  x$ad_data$'Cubic capacity' <- as.numeric(gsub(' cc', '', x$ad_data$'Cubic capacity'))
  
  #Deal with Power
  x$ad_data$Power <- as.numeric(gsub(' bhp', '', x$ad_data$Power))
  
  #Deal with Make/Model
  x$ad_data$`Make/Model`<- (gsub("'.*", "",  x$ad_data$`Make/Model`))
  
  
  #Deal with Registration
  #db.bikescollection.distinct("ad_data.Registration")
  # The minimum year is 1901
  x$ad_data$Registration<-as.numeric(gsub(".*/", "",x$ad_data$Registration))

  x$ad_data$Motoage<- 2021 - x$ad_data$Registration
  
  # Deal with field Price
  if(x$ad_data$Price == 'Askforprice') 
  {
    x$ad_data$Price <- NULL
    x$ad_data$AskForPrice <- TRUE
  }
  else 
  {
    # Remove euro symbol before converting
    x$ad_data$Price <- gsub('\\???','', x$ad_data$Price)
    
    #x$ad_data$Price <- as.numeric(gsub("[.]", "", x$ad_data$Price))
    #DO IT OTHERWISE NAs
    x$ad_data$Price <- as.numeric(gsub("[\200.]", "", x$ad_data$Price))
    
    # Same AveragePrice with the above, but the count is incorrect almost equal to 49900
    x$ad_data$AskForPrice <- FALSE
    
    # If price is less than 50 euros
    if (x$ad_data$Price < 50) 
    {
      x$ad_data$Price <- NULL
      #Add new field Askforprice
      x$ad_data$AskForPrice <- TRUE
    }
  }

  return(x)
}

# Read all json files 
#Create a vector data
data <- c()
for (i in 1:nrow(json_data)) {
  #Save JSON to a variable x
  fJson <- fromJSON(readLines(json_data[i,], encoding="UTF-8"))
  #Clean data with DataCleansing()
  fJson <- DataCleansing(fJson)
  #Convert the x object back to JSON format
  tJson <- toJSON(fJson, auto_unbox = TRUE)
  data <- c(data, tJson)
}


# Insert json objects in MongoDB
mongo$insert(data)

# Check if it has been inserted
mongo$find('{}')

# 2.2 How many bikes are there for sale? (29700 bikes)
#All inserted bikes are for sale, so count() is used
# In MongoDB result could be verified by command: db.bikescollection.count()
mongo$count()

# 2.3 What is the average price of a motorcycle (give a number)? What is the number of listings that were used in order to calculate this average 
# (give a number as well)? Is the number of listings used the same as the answer in 2.2? Why? 
#Answer: No it's not the same as there are Askforprice and NULLs, which have been omitted

# By the use of 'exist' omits Askforprice and NULLs (28533 rows--> Askforprice and NULLs have been omitted)

mongo$aggregate(
'[{
	"$match": {
		"ad_data.Price": {
			"$exists": true
		}
	}
},
{
	"$group": {
		"_id": null,
		"AveragePrice": {
			"$avg": "$ad_data.Price"
		},
		"count": {
			"$sum": 1
		}
	}
}]')

# 2.4 What is the maximum and minimum price of a motorcycle currently available in the market?

mongo$aggregate(
'[{
	"$match": {
		"ad_data.Price": {
			"$exists": true
		}
	}
},
{
	"$group": {
		"_id": null,
		"MinimumPrice": {
			"$min": "$ad_data.Price"
		},
		"MaximumPrice": {
			"$max": "$ad_data.Price"
		}
	}
}]'
)

#If price lower than 50 then Askforprice, regarding the information we get from Car.gr
#Robo 3T to show distinct values of prices: db.bikescollection.distinct("ad_data.Price")


# 2.5 How many listings have a price that is identified as negotiable? (1348 results)

mongo$aggregate(
'[{
	"$match": {
		"metadata.model": {
			"$regex": "Negotiable",
			"$options": "i"
		}
	}
},
{
	"$group": {
		"_id": null,
		"count": {
			"$sum": 1
		}
	}
}]')

#Robo 3T to show:  db.bikescollection.find({ "metadata.model" : { "$regex" : /Negotiable/ }  }) ---1348 results

# 2.6 For each Brand, what percentage of its listings is listed as negotiable?

Negotiable_Grouping_Brand <- mongo$aggregate(
'[{
	"$match": {
		"metadata.model": {
			"$regex": "Negotiable",
			"$options": "i"
		}
	}
},
{
	"$group": {
		"_id": "$metadata.brand",
		"Count_Negotiable": {
			"$sum": 1
		}
	}
}]')

View(Negotiable_Grouping_Brand)

Total_Grouping_Brand <- mongo$aggregate(
'[{
	"$group": {
		"_id": "$metadata.brand",
		"Count_Total": {
			"$sum": 1
		}
	}
}]')

View(Total_Grouping_Brand)


final <- merge(Negotiable_Grouping_Brand, Total_Grouping_Brand, by = "_id")
View(final)

for(i in 1:length(final)){
  final$Negotiable_Percentage_Per_Brand <- round((final$Count_Negotiable/final$Count_Total) * 100,2)
}

View(final)

# 2.7 What is the motorcycle brand with the highest average price?

mongo$aggregate(
'[{
	"$match": {
		"ad_data.Price": {
			"$exists": true
		}
	}
},
{
	"$group": {
		"_id": "$metadata.brand",
		"AveragePrice": {
			"$avg": "$ad_data.Price"
		},
		"count": {
			"$sum": 1
		}
	}
},
{
	"$sort": {
		"AveragePrice": -1
	}
},
{
	"$limit": 1
}]')

# 2.8 What are the TOP 10 models with the highest average age? (Round age by one decimal number)
#Group by model, calculate AVG Age and then Sort.

Top_Models <- mongo$aggregate(
'[{
	"$group": {
		"_id": "$ad_data.Make/Model",
		"AveragegAge": {
			"$avg": "$ad_data.Motoage"
		}
	}
},
{
	"$sort": {
		"AveragegAge": -1
	}
},
{
	"$limit": 10
}]')

View(Top_Models)

#View(Top_Models$`_id`)
#Replace the below characters at gsub with greek word Allo
Top_Models$`_id`<- gsub('???????? ','', Top_Models$`_id`)
View(Top_Models)

# 2.9 How many bikes have "ABS" as an extra?

mongo$aggregate(
'[{
	"$match": {
		"extras": {
			"$regex": "ABS",
			"$options": "i"
		}
	}
},
{
	"$group": {
		"_id": null,
		"count": {
			"$sum": 1
		}
	}
}]')

# 2.10 What is the average Mileage of bikes that have "ABS" AND "Led lights" as an extra?

mongo$aggregate(
'[{
	"$match": {
		"extras": "ABS",
		"extras": "Led lights"
	}
},
{
	"$group": {
		"_id": null,
		"AverageMilage": {
			"$avg": "$ad_data.Mileage"
		},
		"count": {
			"$sum": 1
		}
	}
}]')

# 2.11 What are the TOP 3 colors per bike category?

mongo$aggregate(
'[{
	"$group": {
		"_id": {
			"brand": "$metadata.brand",
			"color": "$ad_data.Color"
		},
		"CountPerColor": {
			"$sum": 1
		}
	}
},
{
	"$sort": {
		"CountPerColor": -1
	}
},
{
	"$group": {
		"_id": "$_id.brand",
		"TopColors": {
			"$push": {
				"color": "$_id.color"
			}
		}
	}
},
{
	"$project": {
		"TopColors": {
			"$slice": ["$TopColors",3]
		}
	}
}]')
