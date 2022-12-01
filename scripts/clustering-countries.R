## ---- include=FALSE-------------------------------------------------------------------------------
# set code chunk options
knitr::opts_chunk$set(echo = TRUE, 
                      fig.align = 'center',
                      cache = TRUE)

# allow scrolling for long code
options(width = 200)


## ---- message=FALSE-------------------------------------------------------------------------------
# load packages
library(tidyverse)
library(dendextend)
library(factoextra)
library(mclust)

# read data
countries <- read.csv("../data/country-data.csv")

# use the countries as the row names
df <- countries %>%
  column_to_rownames(var = "country")

# show the first few rows of the dataframe
head(df)


## -------------------------------------------------------------------------------------------------
# best = 4 clusters (not much improvement after 4 clusters)
fviz_nbclust(df, 
             hcut, 
             method = "wss")


## -------------------------------------------------------------------------------------------------
# best = 2 clusters
fviz_nbclust(df, 
             hcut, 
             method = "silhouette")


## -------------------------------------------------------------------------------------------------
library(cluster)
set.seed(123)
gap_stat <- clusGap(df,
                    hcut,
                    K.max = 10, # number of clusters to consider
                    B = 500)    # number of samples to bootstrap

# best = 3 clusters
fviz_gap_stat(gap_stat)


## ---- fig.height=20-------------------------------------------------------------------------------
df %>%
  scale() %>%
  dist() %>%
  hclust() %>%
  as.dendrogram() %>%
  set("labels_cex", 0.4) %>%
  color_branches(k = 2) %>% 
  color_labels(k = 2) %>%
  plot(horiz = TRUE)


## ---- fig.height=20-------------------------------------------------------------------------------
df %>%
  scale() %>%
  dist() %>%
  hclust() %>%
  as.dendrogram() %>%
  set("labels_cex", 0.4) %>%
  color_branches(k = 3) %>% 
  color_labels(k = 3) %>%
  plot(horiz = TRUE)


## ---- fig.height=20-------------------------------------------------------------------------------
df %>%
  scale() %>%
  dist() %>%
  hclust() %>%
  as.dendrogram() %>%
  set("labels_cex", 0.4) %>%
  color_branches(k = 4) %>% 
  color_labels(k = 4) %>%
  plot(horiz = TRUE)


## -------------------------------------------------------------------------------------------------
# perform hierarchical clustering and get k clusters
k_hclust <- function(.df, k) {
  .df %>%
    scale() %>%
    dist() %>%
    hclust() %>%
    cutree(k)
}

# turn the cluster output into a dataframe
clust_to_df <- function(.clust) {
  .clust %>%
    cbind() %>% 
    data.frame() %>%
    rename(cluster = 1) %>%
    mutate(cluster = factor(cluster)) %>%
    rownames_to_column("country")
}

# rename countries to be able to plot them
rename_countries <- function(.df) {
  .df %>%
    mutate(across('country', str_replace, 'Antigua and Barbuda', 'Antigua'),
           across('country', str_replace, 'Congo, Dem. Rep.', 'Democratic Republic of the Congo'),
           across('country', str_replace, 'Congo, Rep.', 'Republic of Congo'),
           across('country', str_replace, 'Cote d\'Ivoire', 'Ivory Coast'),
           across('country', str_replace, 'Kyrgyz Republic', 'Kyrgyzstan'),
           across('country', str_replace, 'Lao', 'Laos'),
           across('country', str_replace, 'Macedonia, FYR', 'North Macedonia'),
           across('country', str_replace, 'Micronesia, Fed. Sts.', 'Micronesia'),
           across('country', str_replace, 'Slovak Republic', 'Slovakia'),
           across('country', str_replace, 'St. Vincent and the Grenadines', 'Saint Vincent'),
           across('country', str_replace, 'United Kingdom', 'UK'),
           across('country', str_replace, 'United States', 'USA')) %>%
    add_row(country = 'Barbuda', cluster = filter(., country == 'Antigua') %>% getElement('cluster')) %>%
    add_row(country = 'Grenadines', cluster = filter(., country == 'Saint Vincent') %>% getElement('cluster'))
}

# plots the clusters onto the world map
plot_map <- function(.df) {
  world <- map_data("world")
  
  world %>%
    left_join(.df, by = c("region" = "country")) %>%
    ggplot() + 
    geom_polygon(aes(x = long, y = lat, fill = cluster, group = group),
                 color = "white") +
    coord_fixed(1.3) +
    theme(legend.position = "top")
}


## -------------------------------------------------------------------------------------------------
# get world data
world <- map_data("world")

# get unique countries in the df and world dataframes
unique_countries_df <- row.names(df) %>% unique() %>% sort()
unique_countries_world <- world$region %>% unique() %>% sort()

# get all countries that occur in df but not in world
setdiff(unique_countries_df, unique_countries_world)


## ---- out.width='150%'----------------------------------------------------------------------------
df %>%
  k_hclust(2) %>%
  clust_to_df() %>%
  rename_countries() %>%
  plot_map()


## ---- out.width='150%'----------------------------------------------------------------------------
df %>%
  k_hclust(3) %>%
  clust_to_df() %>%
  rename_countries() %>%
  plot_map()


## ---- out.width='150%'----------------------------------------------------------------------------
df %>%
  k_hclust(4) %>%
  clust_to_df() %>%
  rename_countries() %>%
  plot_map()


## -------------------------------------------------------------------------------------------------
mb <- Mclust(df)
summary(mb)


## -------------------------------------------------------------------------------------------------
plot(mb, what = "classification")


## -------------------------------------------------------------------------------------------------
plot(mb, what = "BIC")


## ---- out.width='150%'----------------------------------------------------------------------------
mb$classification %>%
  clust_to_df() %>%
  rename_countries() %>%
  plot_map()


## -------------------------------------------------------------------------------------------------
library(dbscan)
str(df)


## -------------------------------------------------------------------------------------------------
df.matrix <- as.matrix(df)
kNNdistplot(df.matrix, k=6)
abline(h=5000, col="red")


## -------------------------------------------------------------------------------------------------
set.seed(1)
db <- dbscan(df, eps = 5000, minPts = 6)
db
summary(db)


## -------------------------------------------------------------------------------------------------
fviz_cluster(db, df, geom = 'point')


## -------------------------------------------------------------------------------------------------
hullplot(df.matrix, db$cluster)


## ---- include=FALSE-------------------------------------------------------------------------------
# plot(db, df, main = "DBScan")


## ---- out.width='150%'----------------------------------------------------------------------------
# add country names to clusters
db_clust <- db$cluster
names(db_clust) <- row.names(df)

# plot map clusters
db_clust %>%
  clust_to_df() %>%
  rename_countries() %>%
  plot_map()

