## Download and install the package
#install.packages("igraph")

###########################################
### 1  'A Song of Ice and Fire' network ###
###########################################

## Load package
library(igraph)

# Load data
asoiaf <- read.csv("asoiaf-all-edges.csv", header = TRUE, sep=",", stringsAsFactors = FALSE)

# View the content of the asoiaf
View(asoiaf)

# Keep only the necessary columns
asoiaf$Type <- NULL
asoiaf$id <- NULL

head(asoiaf)

# Create the graph
g <- graph_from_data_frame(d=asoiaf, directed=FALSE)
print(g, e=TRUE, v=TRUE)

# Check if is weighted
is_weighted(g)

# Plot the graph
plot(g)


#############################
### 2  Network Properties ###
#############################

# View the vertices
V(g)
# 2.1 Count the number of vertices
vcount(g)
gorder(g)

#View the edges
E(g)
# 2.2 Count the number of edges
ecount(g)
gsize(g)

# 2.3 Count the diameter of the graph
diameter(g)
#diameter(g, directed = TRUE, unconnected = TRUE, weights = NULL)

# Show the triangles
triangles(g)

# 2.4 Count the number of triangles
sum(count_triangles(g, vids = V(g)))

# 2.5 The top-10 characters of the g as far as their degree is concerned

# Calculate the degrees of the graph
degrees <- degree(g, v = V(g),loops = TRUE, normalized = FALSE)
degrees

# Sort them in descending order 
degrees <- sort(degrees,decreasing = TRUE)
degrees

# Keep the top 10 
top_10_degrees <- head(degrees, n=10)
top_10_degrees

# 2.6 The  top-10  characters  of  the  g  as  far  as  their  weighted  degree  is concerned

# Calculate the weighted degrees of the graph
weighted_degrees <- strength(g, vids = V(g), loops = TRUE, weights = NULL)
weighted_degrees

# Sort them in descending order 
weighted_degrees <- sort(weighted_degrees,decreasing = TRUE)
weighted_degrees

# Keep the top 10 
top_10_weighted_degrees <- head(weighted_degrees, n=10)
top_10_weighted_degrees


###################
### 3  Subgraph ###
###################

#Different layouts
plot(g, vertex.color="yellow", vertex.label = NA, edge.arrow.width=0.8, edge.arrow.size=0.2, vertex.size=3)
plot(g, layout=layout_with_kk, vertex.color="yellow", vertex.label = NA, edge.arrow.width=0.8, edge.arrow.size=0.2, vertex.size=3)
plot(g, layout=layout.fruchterman.reingold(g), vertex.color="blue", vertex.label = NA, edge.arrow.width=0.8, edge.arrow.size=0.2, vertex.size=3)


#Show the total length of the graph
length(degree(g))

# Subgraph
# Discarding all vertices that have less than 10 connections in the network
subgraph <- delete.vertices(g, V(g)[degree(g, mode = "all")<10])

#Show the total length of the subgraph
length(degree(subgraph))

plot(subgraph, layout=layout.fruchterman.reingold(subgraph), vertex.color="blue", vertex.label = NA, edge.arrow.width=0.8, edge.arrow.size=0.2, vertex.size=3)

# Edge density
edge_density(g, loops = FALSE)
edge_density(subgraph, loops = FALSE)



#####################
### 4  Centrality ###
#####################

# Calculate the closeness centrality
closeness <- closeness(g, vids = V(g), weights = NULL, normalized = FALSE)
closeness

# Sort them in descending order 
closeness <- sort(closeness,decreasing = TRUE)
closeness

# Keep the top 10 
top_15_closeness <- head(closeness, n=15)
top_15_closeness


# Calculate the betweeness centrality
betweeness <- betweenness(g, v = V(g), directed = TRUE, weights = NULL, nobigint = TRUE, normalized = FALSE)
betweeness

# Sort them in descending order 
betweeness <- sort(betweeness,decreasing = TRUE)
betweeness

# Keep the top 10 
top_15_betweeness <- head(betweeness, n=15)
top_15_betweeness

###################################
### 5 Ranking and Visualization ###
###################################

library(magrittr)
library(miniCRAN)


pr <- g %>%
  page.rank(directed = FALSE) %>%
  use_series("vector") %>%
  sort(decreasing = TRUE) %>%
  as.matrix %>%
  set_colnames("page.rank")

page_rank <- as.data.frame(pr)
head(page_rank, 10)


# For plotting purposes the page rank of the characters are resized
page_rank_resizing <- as.numeric(page_rank[,1] * 1000)

plot(g, layout=layout.fruchterman.reingold(g), edge.width = 0.8 , vertex.color="blue", vertex.label = NA, edge.arrow.width=0.5, vertex.size=page_rank_resizing)

