# Unsupervised Learning on Country Data

##Preprocessing
raw_data <- read.csv("Country-data/Country-data.csv")
save(raw_data,file = 'Country-data/raw_data.RData')
load('Country-data/raw_data.RData')