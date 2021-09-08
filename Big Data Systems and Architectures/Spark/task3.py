#Import and initialize findspark
import findspark
findspark.init()

#Import the following
from pyspark import SparkContext
from pyspark.sql import SQLContext
from pyspark.sql import SparkSession
from pyspark.sql.dataframe import DataFrame
from pyspark.sql.readwriter import DataFrameReader
from pyspark.sql.types import IntegerType, Row, StringType
from pyspark.sql.window import Window
from pyspark.sql.functions import col,percent_rank,count,avg,expr,desc,round,when,isnan

#Import ML
import pyspark.mllib
import pyspark.mllib.regression
from pyspark.ml.feature import StringIndexer
from pyspark.sql.types import DoubleType
import pyspark.sql.functions as F
from pyspark.sql import types as T

#Import Linear Regression
from pyspark.ml.evaluation import RegressionEvaluator
from pyspark.ml.regression import LinearRegression
from pyspark.ml.tuning import ParamGridBuilder, TrainValidationSplit
from pyspark.mllib.linalg import DenseVector
from pyspark.ml.feature import OneHotEncoder
from pyspark.ml.feature import VectorAssembler
from pyspark.ml import Pipeline


#Create a new a temporary view to read the data
spark = SparkSession.builder.appName("FlightsAssignment").getOrCreate()
spark

#Load the data to a variable named 'flights_data'
flights_data = spark.read\
                    .option("header","true")\
                    .option("inferSchema","true")\
                    .csv("671009038_T_ONTIME_REPORTING.csv")
	
#Clear dataset from null values in DEP_DELAY column
flights_data=flights_data.filter(flights_data.DEP_DELAY.isNotNull())

#Keep only the following four columns
flights_data = flights_data.select("DEP_DELAY","ORIGIN","CARRIER","DEP_TIME")
flights_data.show(10)

#Count unique values of ORIGIN 
flights_data.select("ORIGIN").distinct().count()

#Count unique values of CARRIER 
flights_data.select("CARRIER").distinct().count()

#Check types
flights_data.dtypes

#Change the type of DEP_TIME to string
flights_data = flights_data.withColumn("DEP_TIME",flights_data["DEP_TIME"].cast(T.StringType()))

# converted DEP_TIME
flights_data.dtypes

#Fill with zeros if length = 3 digits 
flights_data = flights_data.withColumn('DEP_TIME', F.format_string("%04d", F.col('DEP_TIME').cast("int"))) 
flights_data.show(10)

#Convert it type to string
flights_data = flights_data.withColumn("DEP_TIME",flights_data["DEP_TIME"].cast(T.StringType()))
print(flights_data.dtypes)

# create new column with only two digts
flights_data = flights_data.withColumn("DEP_TIME_HOUR", flights_data.DEP_TIME.substr(1,2))
flights_data.show()

flights_data.dtypes

flights_data.select("DEP_TIME_HOUR").distinct().count()  

#Replace if the hour=24 to 00
flights_data = flights_data.withColumn("DEP_TIME_HOUR", F.regexp_replace("DEP_TIME_HOUR", "24", "00"))

# see the distinct values
flights_data.select("DEP_TIME_HOUR").distinct().show()


#Handle outliers at ORIGIN and CARRIER columns
#ORIGIN
percentiles_ap = flights_data.groupBy("ORIGIN").count()\
                .select("ORIGIN","count", percent_rank().over(Window.partitionBy().orderBy("count")).alias("percent_rank_ap"))
                
percentiles_ap.show()

flights_percentiles_ap = flights_data.alias('flights').join(percentiles_ap.alias('percentiles'), col('percentiles.ORIGIN') == col('flights.ORIGIN'))\
            .select([col('flights.'+xx) for xx in flights_data.columns] + [col('percentiles.percent_rank_ap')])

flights_percentiles_ap.show()

#remove outliers (aka < 0.01) and store the rest on a new dataframe
flights_data = flights_percentiles_ap.where("percent_rank_ap > 0.01")

#CARRIER
#calculate percentiles
percentiles_aw = flights_data.groupBy("CARRIER").count()\
                .select("CARRIER","count", percent_rank().over(Window.partitionBy().orderBy("count")).alias("percent_rank_aw"))
                
percentiles_aw.show()

#join percentiles_aw to initial dataset
flights_percentiles_aw = flights_data.alias('flights').join(percentiles_aw.alias('percentiles'), col('percentiles.CARRIER') == col('flights.CARRIER'))\
            .select([col('flights.'+xx) for xx in flights_data.columns] + [col('percentiles.percent_rank_aw')])

flights_percentiles_aw.show()


#remove outliers (aka < 0.01) and store the rest on a new dataframe
flights_data = flights_percentiles_aw.where("percent_rank_aw > 0.01")

# string indexer ORIGIN

indexer = StringIndexer()\
.setInputCol("ORIGIN")\
.setOutputCol("ORIGIN_INDEXED")

# one hot encoder ORIGIN
encoder = OneHotEncoder(dropLast=False)\
.setInputCols(["ORIGIN_INDEXED"])\
.setOutputCols(["ORIGIN_ENCODED"])


# string indexer CARRIER

indexer2 = StringIndexer()\
.setInputCol("CARRIER")\
.setOutputCol("CARRIER_INDEXED")

# one hot encoder CARRIER
encoder2 = OneHotEncoder(dropLast=False)\
.setInputCols(["CARRIER_INDEXED"])\
.setOutputCols(["CARRIER_ENCODED"])


# string indexer DEP_TIME_HOUR

indexer3 = StringIndexer()\
.setInputCol("DEP_TIME_HOUR")\
.setOutputCol("DEP_TIME_HOUR_INDEXED")


# one hot encoder DEP_TIME_HOUR
encoder3 = OneHotEncoder(dropLast=False)\
.setInputCols(["DEP_TIME_HOUR_INDEXED"])\
.setOutputCols(["DEP_TIME_HOUR_ENCODED"])


# vector_assembler
vector_assembler = VectorAssembler()\
.setInputCols(["ORIGIN_ENCODED", "CARRIER_ENCODED", "DEP_TIME_HOUR_ENCODED"])\
.setOutputCol("FEATURES")

# Make the pipeline  
pipe = Pipeline(stages=[indexer, encoder, indexer2, encoder2, indexer3, encoder3, vector_assembler])


# Fit and transform the data
piped_data = pipe.fit(flights_data).transform(flights_data)


# Split the data into training and test sets
training, test = piped_data.randomSplit([.7, .3])

lr = LinearRegression(featuresCol ='FEATURES', labelCol ='DEP_DELAY')
#lr = LinearRegression(featuresCol ='FEATURES', labelCol ='DEP_DELAY',regParam=0.7, elasticNetParam=0.8)

#Fit the train and show the summary of the model
lrModel = lr.fit(training)
summary = lrModel.summary
summary.rootMeanSquaredError

#Make predictions on test dataset
predictions = lrModel.transform(test)
predictions.show()

lr_predictions = lrModel.transform(test)
lr_predictions.select("prediction","DEP_DELAY","FEATURES").show(10)

lr_evaluator = RegressionEvaluator(predictionCol="prediction", \
                 labelCol="DEP_DELAY",metricName="r2")
print("R Squared (R2) on test data = %g" % lr_evaluator.evaluate(lr_predictions))

test_result = lrModel.evaluate(test)
print("Root Mean Squared Error (RMSE) on test data = %g" % test_result.rootMeanSquaredError)

#Pandas
#pip install pandas
test.describe().toPandas()[["summary","DEP_DELAY"]]
