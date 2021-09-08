#!/usr/bin/env python
# coding: utf-8

import pandas as pd


authors_2016 = pd.read_csv("authors_2016.csv",
                  #error_bad_lines=False,
                  names=["YEAR", "PAPER_TITLE", "PLACE_PRESENTED", "AUTHORS_LIST"])
authors_2016.head(5)
authors_2016.shape


authors_2017 = pd.read_csv("authors_2017.csv",
                  #error_bad_lines=False,
                  names=["YEAR", "PAPER_TITLE", "PLACE_PRESENTED", "AUTHORS_LIST"])
authors_2017.head(5)
authors_2017.shape


authors_2018 = pd.read_csv("authors_2018.csv",
                  #error_bad_lines=False,
                  names=["YEAR", "PAPER_TITLE", "PLACE_PRESENTED", "AUTHORS_LIST"])
authors_2018.head(5)
authors_2018.shape


authors_2019 = pd.read_csv("authors_2019.csv",
                  #error_bad_lines=False,
                  names=["YEAR", "PAPER_TITLE", "PLACE_PRESENTED", "AUTHORS_LIST"])
authors_2019.head(5)
authors_2019.shape


authors_2020 = pd.read_csv("authors_2020.csv",
                  #error_bad_lines=False,
                  names=["YEAR", "PAPER_TITLE", "PLACE_PRESENTED", "AUTHORS_LIST"])
authors_2020.head(5)
authors_2020.shape

# Summarize the na
authors_2018.isna().sum()


#Remove NAs from datasets
authors_2016 = authors_2016.dropna()
authors_2017 = authors_2017.dropna()
authors_2018 = authors_2018.dropna()
authors_2019 = authors_2019.dropna()
authors_2020 = authors_2020.dropna()


# Create lists per year including only AUTHORS_LIST
data_2016 = authors_2016.AUTHORS_LIST
data_2016 = list(data_2016)

data_2017 = authors_2017.AUTHORS_LIST
data_2017 = list(data_2017)

data_2018 = authors_2018.AUTHORS_LIST
data_2018 = list(data_2018)

data_2019 = authors_2019.AUTHORS_LIST
data_2019 = list(data_2019)

data_2020 = authors_2020.AUTHORS_LIST
data_2020 = list(data_2020)


# Slipt lists
data_2016_split = [i.split(',') for i in data_2016]
data_2017_split = [i.split(',') for i in data_2017]
data_2018_split = [i.split(',') for i in data_2018]
data_2019_split = [i.split(',') for i in data_2019]
data_2020_split = [i.split(',') for i in data_2020]


#Calculate the counts per pair
#https://www.py4u.net/discuss/153632
import collections
import itertools

#2016
count_2016 = collections.defaultdict(int)
for i in data_2016_split:
    i.sort()
    for pair in itertools.combinations(i, 2):
        count_2016[pair] += 1

#2017
count_2017 = collections.defaultdict(int)
for i in data_2017_split:
    i.sort()
    for pair in itertools.combinations(i, 2):
        count_2017[pair] += 1
        
#2018
count_2018 = collections.defaultdict(int)
for i in data_2018_split:
    i.sort()
    for pair in itertools.combinations(i, 2):
        count_2018[pair] += 1
        
#2019
count_2019 = collections.defaultdict(int)
for i in data_2019_split:
    i.sort()
    for pair in itertools.combinations(i, 2):
        count_2019[pair] += 1

#2020
count_2020 = collections.defaultdict(int)
for i in data_2020_split:
    i.sort()
    for pair in itertools.combinations(i, 2):
        count_2020[pair] += 1


# Constuct final datasets
authors_2016_final = pd.DataFrame.from_records(list(dict(count_2016).items()), columns=['Authors','Weight'])
authors_2017_final = pd.DataFrame.from_records(list(dict(count_2017).items()), columns=['Authors','Weight'])
authors_2018_final = pd.DataFrame.from_records(list(dict(count_2018).items()), columns=['Authors','Weight'])
authors_2019_final = pd.DataFrame.from_records(list(dict(count_2019).items()), columns=['Authors','Weight'])
authors_2020_final = pd.DataFrame.from_records(list(dict(count_2020).items()), columns=['Authors','Weight'])


# Split Authors column 
authors_2016_final = pd.concat([authors_2016_final.Authors.apply(lambda x: pd.Series(str(x).split(","))), authors_2016_final["Weight"]], axis=1)
authors_2017_final = pd.concat([authors_2017_final.Authors.apply(lambda x: pd.Series(str(x).split(","))), authors_2017_final["Weight"]], axis=1)
authors_2018_final = pd.concat([authors_2018_final.Authors.apply(lambda x: pd.Series(str(x).split(","))), authors_2018_final["Weight"]], axis=1)
authors_2019_final = pd.concat([authors_2019_final.Authors.apply(lambda x: pd.Series(str(x).split(","))), authors_2019_final["Weight"]], axis=1)
authors_2020_final = pd.concat([authors_2020_final.Authors.apply(lambda x: pd.Series(str(x).split(","))), authors_2020_final["Weight"]], axis=1)


# Manipulate From and To columns

#2016
authors_2016_final.columns=['From','To','Weight']
authors_2016_final["From"] = authors_2016_final["From"].str[2:]
authors_2016_final["From"] = authors_2016_final["From"].str[:-1]
authors_2016_final["To"] = authors_2016_final["To"].str[2:]
authors_2016_final["To"] = authors_2016_final["To"].str[:-2]


#2017
authors_2017_final.columns=['From','To','Weight']
authors_2017_final["From"] = authors_2017_final["From"].str[2:]
authors_2017_final["From"] = authors_2017_final["From"].str[:-1]
authors_2017_final["To"] = authors_2017_final["To"].str[2:]
authors_2017_final["To"] = authors_2017_final["To"].str[:-2]


#2018
authors_2018_final.columns=['From','To','Weight']
authors_2018_final["From"] = authors_2018_final["From"].str[2:]
authors_2018_final["From"] = authors_2018_final["From"].str[:-1]
authors_2018_final["To"] = authors_2018_final["To"].str[2:]
authors_2018_final["To"] = authors_2018_final["To"].str[:-2]


#2019
authors_2019_final.columns=['From','To','Weight']
authors_2019_final["From"] = authors_2019_final["From"].str[2:]
authors_2019_final["From"] = authors_2019_final["From"].str[:-1]
authors_2019_final["To"] = authors_2019_final["To"].str[2:]
authors_2019_final["To"] = authors_2019_final["To"].str[:-2]


#2020
authors_2020_final.columns=['From','To','Weight']
authors_2020_final["From"] = authors_2020_final["From"].str[2:]
authors_2020_final["From"] = authors_2020_final["From"].str[:-1]
authors_2020_final["To"] = authors_2020_final["To"].str[2:]
authors_2020_final["To"] = authors_2020_final["To"].str[:-2]


# Export final datasets to .csv
authors_2016_final.to_csv(r'C:\\Users\\XXXX\\authors_2016_final.csv')
authors_2017_final.to_csv(r'C:\\Users\\XXXX\\authors_2017_final.csv')
authors_2018_final.to_csv(r'C:\\Users\\XXXX\\authors_2018_final.csv')
authors_2019_final.to_csv(r'C:\\Users\\XXXX\\authors_2019_final.csv')
authors_2020_final.to_csv(r'C:\\Users\\XXXX\\authors_2020_final.csv')

