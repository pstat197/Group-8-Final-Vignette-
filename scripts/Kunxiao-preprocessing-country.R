##Preprocessing
library(tidyverse)
##Create and save the dataframe
raw_data <- read.csv("data/country-data.csv")
save(raw_data,file = 'data/raw_data.RData')
load('data/raw_data.RData')
View(raw_data)
##Choose health as the response variable 
#Divide health variable to four levels: high, medium-low, 
#                                       medium, medium-high, low
quantiles <- quantile(raw_data$health, c(0.2, 0.4, 0.6, 0.8, 1))
data <- raw_data %>%
  mutate(health_level = case_when(health <= quantiles[[1]] ~ "Low",
                                  health <=quantiles[[2]] & health > quantiles[[1]] ~ "Medium-Low",
                                  health <=quantiles[[3]] & health > quantiles[[2]] ~ "Medium",
                                  health <=quantiles[[4]] & health > quantiles[[3]] ~ "Medium-High",
                                  health >quantiles[[4]] ~ "High")) %>%
  mutate(health_level=factor(health_level,levels=c("Low","Medium-Low","Medium","Medium-High","High"))) %>%
  select(-4) ##Drop the original health after generating health-levels







