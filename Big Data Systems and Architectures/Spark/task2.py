#Import and initialize findspark
import findspark
findspark.init()

#Import the following libraries
from pyspark import SparkContext
from pyspark.sql import SparkSession
from pyspark.sql import SQLContext
from pyspark.sql.dataframe import DataFrame
from pyspark.sql.readwriter import DataFrameReader
from pyspark.sql.types import IntegerType, Row, StringType
from pyspark.sql.window import Window
from pyspark.sql.functions import col,percent_rank,count,avg,expr,desc,round

#Create a new a temporary view to read the data
spark = SparkSession.builder.appName("FlightsAssignment").getOrCreate()
spark

#Load the data to a variable named 'flights_data'
flights_data = spark.read\
                    .option("header","true")\
                    .option("inferSchema","true")\
                    .csv("671009038_T_ONTIME_REPORTING.csv")
					
					
#Show the first 5 rows of the data
flights_data.show(5)

#Count the data before cleaning
flights_data.count()


#Calculate the percentiles for ORIGIN
percentiles_ap = flights_data.groupBy("ORIGIN").count()\
                .select("ORIGIN","count", percent_rank().over(Window.partitionBy().orderBy("count")).alias("percent_rank_ap"))
                
percentiles_ap.show(5)

#Join percentiles to initial dataset
flights_percentiles_ap = flights_data.alias('flights').join(percentiles_ap.alias('percentiles'), col('percentiles.ORIGIN') == col('flights.ORIGIN'))\
            .select([col('flights.'+xx) for xx in flights_data.columns] + [col('percentiles.percent_rank_ap')])

flights_percentiles_ap.show()


#Remove outliers (aka < 0.01) and store the rest on a new dataframe
flights_data = flights_percentiles_ap.where("percent_rank_ap > 0.01")

#Count the data after removing airplane outliers
flights_data.count()


#Calculate the avg delay per airport(aka ORIGIN) in desc order
avgDelayPerAirport = flights_data\
               .groupBy("ORIGIN")\
               .agg(round(avg(("DEP_DELAY")),2).alias("AverageDelay"))\
               .sort(desc("AverageDelay"))
avgDelayPerAirport.show()

#Store the above results to a .csv
avgDelayPerAirport.limit(100).coalesce(1)\
       .write.csv("task2-ap-avg")

#Calculate the median delay per airport(aka ORIGIN) in desc order   
medDelayPerAirport = flights_data\
                .groupBy("ORIGIN")\
                .agg(expr('percentile_approx(DEP_DELAY, 0.5)').alias("MedianDelay"))\
                .sort(desc("MedianDelay"))
medDelayPerAirport.show()

#Store the above results to a .csv
medDelayPerAirport.limit(100).coalesce(1)\
       .write.csv("task2-ap-med")
	   
#Calculate percentiles for CARRRIER - airway
percentiles_aw = flights_data.groupBy("CARRIER").count()\
                .select("CARRIER","count", percent_rank().over(Window.partitionBy().orderBy("count")).alias("percent_rank_aw"))
                
percentiles_aw.show()

#Join percentiles_aw to initial dataset
flights_percentiles_aw = flights_data.alias('flights').join(percentiles_aw.alias('percentiles'), col('percentiles.CARRIER') == col('flights.CARRIER'))\
            .select([col('flights.'+xx) for xx in flights_data.columns] + [col('percentiles.percent_rank_aw')])

flights_percentiles_aw.show()

#Remove outliers (aka < 0.01) and store the rest on a new dataframe
flights_data = flights_percentiles_aw.where("percent_rank_aw > 0.01")

#Count the data after removing airway outliers
flights_data.count()

#Calculate the avg delay per airway(aka CARRIER) in desc order 
avgDelayPerAirway = flights_data\
               .groupBy("CARRIER")\
               .agg(round(avg(("DEP_DELAY")),2).alias("AverageDelay"))\
               .sort(desc("AverageDelay"))
avgDelayPerAirway.show()

#Store the above results to a .csv
avgDelayPerAirway.limit(100).coalesce(1)\
       .write.csv("task2-aw-avg")

#Calculate the median delay per airway(aka ORIGIN) in desc order 	   
medDelayPerAirway = flights_data\
                .groupBy("CARRIER")\
                .agg(expr('percentile_approx(DEP_DELAY, 0.5)').alias("MedianDelay"))\
                .sort(desc("MedianDelay"))
medDelayPerAirway.show()

#Store the above results to a .csv
medDelayPerAirway.limit(100).coalesce(1)\
       .write.csv("task2-aw-med")
