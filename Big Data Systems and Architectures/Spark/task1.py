#Install the following
#pip install numpy
#pip install spark
#pip install pyspark
#pip install findspark

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

#Import the following to use SQL commands
import pyspark.sql.functions as F
from pyspark.sql.functions import avg,expr, col, desc,round

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

#Print the schema of the data, to see the type (eg.float, string) of each variable
flights_data.printSchema()


#Calculate and show the average delays
AvgDelay = flights_data\
                .agg(round(avg(("DEP_DELAY")),2).alias("AverageDepartureDelay"), 
                     round(avg(("ARR_DELAY")),2).alias("AverageArrivalDelay"))
AvgDelay.show()


#We can also run the above with SQL commands
#Convert the dataframe to a table/view
flights_data.createOrReplaceTempView("flights_data")
flights_data

#Calculate and show the average delays with SQL 
AvgDelay_SQL = spark.sql("SELECT ROUND(AVG(DEP_DELAY),2) AS AverageDepartureDelay, ROUND(AVG(ARR_DELAY),2) AS AverageArrivalDelay FROM flights_data")
AvgDelay_SQL.show()
