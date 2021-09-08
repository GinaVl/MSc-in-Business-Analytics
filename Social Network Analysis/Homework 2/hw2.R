## Download and install the package
#install.packages("igraph")

## Load package
library(igraph)
library(ggplot2)
library(gridExtra)

# Load data
authors_2016 <- read.csv("authors_2016_final.csv", header = TRUE, sep=",", stringsAsFactors = FALSE)
View(authors_2016)

authors_2017 <- read.csv("authors_2017_final.csv", header = TRUE, sep=",", stringsAsFactors = FALSE)
View(authors_2017)

authors_2018 <- read.csv("authors_2018_final.csv", header = TRUE, sep=",", stringsAsFactors = FALSE)
View(authors_2018)

authors_2019 <- read.csv("authors_2019_final.csv", header = TRUE, sep=",", stringsAsFactors = FALSE)
View(authors_2019)

authors_2020 <- read.csv("authors_2020_final.csv", header = TRUE, sep=",", stringsAsFactors = FALSE)
View(authors_2020)

# Remove columns
authors_2016$X <- NULL
authors_2017$X <- NULL
authors_2018$X <- NULL
authors_2019$X <- NULL
authors_2020$X <- NULL


# Initialize the graphs 
g_2016 <- graph_from_data_frame(d=authors_2016, directed=FALSE)
g_2016 <- set.edge.attribute(g_2016, "weight", index=E(g_2016), authors_2016[1:nrow(authors_2016),]$Weight)
print(g_2016, e=TRUE, v=TRUE)
is.weighted(g_2016)

g_2017 <- graph_from_data_frame(d=authors_2017, directed=FALSE)
g_2017 <- set.edge.attribute(g_2017, "weight", index=E(g_2017), authors_2017[1:nrow(authors_2017),]$Weight)
print(g_2017, e=TRUE, v=TRUE)

g_2018 <- graph_from_data_frame(d=authors_2018, directed=FALSE)
g_2018 <- set.edge.attribute(g_2018, "weight", index=E(g_2018), authors_2018[1:nrow(authors_2018),]$Weight)
print(g_2018, e=TRUE, v=TRUE)

g_2019 <- graph_from_data_frame(d=authors_2019, directed=FALSE)
g_2019 <- set.edge.attribute(g_2019, "weight", index=E(g_2019), authors_2019[1:nrow(authors_2019),]$Weight)
print(g_2019, e=TRUE, v=TRUE)

g_2020 <- graph_from_data_frame(d=authors_2020, directed=FALSE)
g_2020 <- set.edge.attribute(g_2020, "weight", index=E(g_2020), authors_2020[1:nrow(authors_2020),]$Weight)
print(g_2020, e=TRUE, v=TRUE)


##############################
# 2 Average degree over time #
##############################

# number of vertices  
vertices_2016 <- vcount(g_2016)
vertices_2017 <- vcount(g_2017)
vertices_2018 <- vcount(g_2018)
vertices_2019 <- vcount(g_2019)
vertices_2020 <- vcount(g_2020)

# Years 
year <- c("2016","2017","2018","2019","2020")

# vertices vector
vertices <- c(vertices_2016,vertices_2017,vertices_2018,vertices_2019,vertices_2020)
vertices_df <- data.frame("VerticesNumber"=vertices, "When" = year)

# vertices plot
plot_vertices1<-ggplot(data=vertices_df, aes(x=year,xlab=("Year"),ylab=("Vertices") ,y=vertices, group=1)) +
  geom_line()+
  geom_point()+
  ggtitle("5 Year Evolution of Vertices")
plot_vertices2<-ggplot(data=vertices_df, aes(x=year, y=vertices, fill=year),xlab=("Year"),ylab=("Vertices")) +
  geom_bar(colour="black", stat="identity") +
  guides(fill=FALSE)+ggtitle("5 Year Evolution of Vertices")

grid.arrange(plot_vertices1, plot_vertices2, ncol=2) 


# Number of edges
edges_2016 <- ecount(g_2016)
edges_2017 <- ecount(g_2017)
edges_2018 <- ecount(g_2018)
edges_2019 <- ecount(g_2019)
edges_2020 <- ecount(g_2020)

# edges vector
edges <- c(edges_2016,edges_2017,edges_2018,edges_2019,edges_2020)
edges_df <- data.frame("EdgesNumber"=edges, "When" = year)

# edges plot
plot_edges1<-ggplot(data=edges_df, aes(x=year,xlab=("Year"),ylab=("Edges") ,y=edges, group=1)) +
  geom_line()+
  geom_point()+
  ggtitle("5 Year Evolution of Edges")
plot_edges2<-ggplot(data=edges_df, aes(x=year, y=edges, fill=year),xlab=("Year"),ylab=("Edges")) +
  geom_bar(colour="black", stat="identity") +
  guides(fill=FALSE)+ggtitle("5 Year Evolution of Edges")

grid.arrange(plot_edges1, plot_edges2, ncol=2)


# Diameter
diameter_2016 <- diameter(g_2016)
diameter_2017 <- diameter(g_2017)
diameter_2018 <- diameter(g_2018)
diameter_2019 <- diameter(g_2019)
diameter_2020 <- diameter(g_2020)


# diameter vector 
diameter <- c(diameter_2016,diameter_2017,diameter_2018,diameter_2019,diameter_2020)
diameter_df <- data.frame("Diameter"=diameter, "When" = year)

# diameter plot
plot_diameter1<-ggplot(data=diameter_df, aes(x=year,xlab=("Year"),ylab=("Diameter") ,y=diameter, group=1)) +
  geom_line()+
  geom_point()+
  ggtitle("5 Year Evolution of Diameter")
plot_diameter2<-ggplot(data=diameter_df, aes(x=year, y=diameter, fill=year),xlab=("Year"),ylab=("Diameter")) +
  geom_bar(colour="black", stat="identity") +
  guides(fill=FALSE)+ggtitle("5 Year Evolution of Diameter")

grid.arrange(plot_diameter1, plot_diameter2, ncol=2)

# Average degree
#2*(edges_2016) / vertices_2016
avg_degree_2016 <- round(mean(degree(g_2016, mode="all")),3)
avg_degree_2017 <- round(mean(degree(g_2017, mode="all")),3)
avg_degree_2018 <- round(mean(degree(g_2018, mode="all")),3)
avg_degree_2019 <- round(mean(degree(g_2019, mode="all")),3)
avg_degree_2020 <- round(mean(degree(g_2020, mode="all")),3)

# average degree
avg_degrees <- c(avg_degree_2016,avg_degree_2017,avg_degree_2018,avg_degree_2019,avg_degree_2020)
avg_degrees_df <- data.frame("AverageDegrees"=avg_degrees, "When" = year)

# average degrees plot
plot_avg_deg1<-ggplot(data=avg_degrees_df, aes(x=year,xlab=("Year"),ylab=("Average Degrees") ,y=avg_degrees, group=1)) +
  geom_line()+
  geom_point()+
  ggtitle("5 Year Evolution of Average Degrees")
plot_avg_deg2<-ggplot(data=avg_degrees_df, aes(x=year, y=avg_degrees, fill=year),xlab=("Year"),ylab=("Average Degrees")) +
  geom_bar(colour="black", stat="identity") +
  guides(fill=FALSE)+ggtitle("5 Year Evolution of Average Degrees")

grid.arrange(plot_avg_deg1, plot_avg_deg2, ncol=2)

#####################
# 3 Important nodes #
#####################

# Degree
degrees_2016 <- degree(g_2016, v = V(g_2016),loops = TRUE, normalized = FALSE)
degrees_sorted_2016 <- sort(degrees_2016, decreasing = TRUE)
degrees_top10_2016<- head(degrees_sorted_2016, n=10)
degrees_top10_2016 <- as.data.frame(degrees_top10_2016)
names(degrees_top10_2016)[names(degrees_top10_2016) == "degrees_top10_2016"] <- "Top 10 Authors 2016 (Degree)"
degrees_top10_2016


degrees_2017 <- degree(g_2017, v = V(g_2017),loops = TRUE, normalized = FALSE)
degrees_sorted_2017 <- sort(degrees_2017, decreasing = TRUE)
degrees_top10_2017<- head(degrees_sorted_2017, n=10)
degrees_top10_2017 <- as.data.frame(degrees_top10_2017)
names(degrees_top10_2017)[names(degrees_top10_2017) == "degrees_top10_2017"] <- "Top 10 Authors 2017 (Degree)"
degrees_top10_2017


degrees_2018 <- degree(g_2018, v = V(g_2018),loops = TRUE, normalized = FALSE)
degrees_sorted_2018 <- sort(degrees_2018, decreasing = TRUE)
degrees_top10_2018<- head(degrees_sorted_2018, n=10)
degrees_top10_2018 <- as.data.frame(degrees_top10_2018)
names(degrees_top10_2018)[names(degrees_top10_2018) == "degrees_top10_2018"] <- "Top 10 Authors 2018 (Degree)"
degrees_top10_2018


degrees_2019 <- degree(g_2019, v = V(g_2019),loops = TRUE, normalized = FALSE)
degrees_sorted_2019 <- sort(degrees_2019, decreasing = TRUE)
degrees_top10_2019<- head(degrees_sorted_2019, n=10)
degrees_top10_2019 <- as.data.frame(degrees_top10_2019)
names(degrees_top10_2019)[names(degrees_top10_2019) == "degrees_top10_2019"] <- "Top 10 Authors 2019 (Degree)"
degrees_top10_2019


degrees_2020 <- degree(g_2020, v = V(g_2020),loops = TRUE, normalized = FALSE)
degrees_sorted_2020 <- sort(degrees_2020, decreasing = TRUE)
degrees_top10_2020<- head(degrees_sorted_2020, n=10)
degrees_top10_2020 <- as.data.frame(degrees_top10_2020)
names(degrees_top10_2020)[names(degrees_top10_2020) == "degrees_top10_2020"] <- "Top 10 Authors 2020 (Degree)"
degrees_top10_2020



# Page Rank
library(magrittr)
library(miniCRAN)


page_rank_2016 <- g_2016 %>%
  page.rank(directed = TRUE) %>%
  use_series("vector") %>%
  sort(decreasing = TRUE) %>%
  as.matrix %>%
  set_colnames("page.rank")
top_10_PageRank_2016 <- head(page_rank_2016, n=10)
top_10_PageRank_2016 <- as.data.frame(top_10_PageRank_2016)
names(top_10_PageRank_2016)[names(top_10_PageRank_2016) == "page.rank"] <- "Top 10 Authors 2016 (Page Rank)"
top_10_PageRank_2016

page_rank_2017 <- g_2017 %>%
  page.rank(directed = TRUE) %>%
  use_series("vector") %>%
  sort(decreasing = TRUE) %>%
  as.matrix %>%
  set_colnames("page.rank")
top_10_PageRank_2017 <- head(page_rank_2017, n=10)
top_10_PageRank_2017 <- as.data.frame(top_10_PageRank_2017)
names(top_10_PageRank_2017)[names(top_10_PageRank_2017) == "page.rank"] <- "Top 10 Authors 2017 (Page Rank)"
top_10_PageRank_2017


page_rank_2018 <- g_2018 %>%
  page.rank(directed = TRUE) %>%
  use_series("vector") %>%
  sort(decreasing = TRUE) %>%
  as.matrix %>%
  set_colnames("page.rank")
top_10_PageRank_2018 <- head(page_rank_2018, n=10)
top_10_PageRank_2018 <- as.data.frame(top_10_PageRank_2018)
names(top_10_PageRank_2018)[names(top_10_PageRank_2018) == "page.rank"] <- "Top 10 Authors 2018 (Page Rank)"
top_10_PageRank_2018


page_rank_2019 <- g_2019 %>%
  page.rank(directed = TRUE) %>%
  use_series("vector") %>%
  sort(decreasing = TRUE) %>%
  as.matrix %>%
  set_colnames("page.rank")
top_10_PageRank_2019 <- head(page_rank_2019, n=10)
top_10_PageRank_2019 <- as.data.frame(top_10_PageRank_2019)
names(top_10_PageRank_2019)[names(top_10_PageRank_2019) == "page.rank"] <- "Top 10 Authors 2019 (Page Rank)"
top_10_PageRank_2019


page_rank_2020 <- g_2020 %>%
  page.rank(directed = TRUE) %>%
  use_series("vector") %>%
  sort(decreasing = TRUE) %>%
  as.matrix %>%
  set_colnames("page.rank")
top_10_PageRank_2020 <- head(page_rank_2020, n=10)
top_10_PageRank_2020 <- as.data.frame(top_10_PageRank_2020)
names(top_10_PageRank_2020)[names(top_10_PageRank_2020) == "page.rank"] <- "Top 10 Authors 2020 (Page Rank)"
top_10_PageRank_2020


#################
# 4 Communities #
#################
# First part

# Apply fast greedy clustering
start.time <- Sys.time()
communities_fast_greedy_2016 <- cluster_fast_greedy(g_2016)
communities_fast_greedy_2017 <- cluster_fast_greedy(g_2017)
communities_fast_greedy_2018 <- cluster_fast_greedy(g_2018)
communities_fast_greedy_2019 <- cluster_fast_greedy(g_2019)
communities_fast_greedy_2020 <- cluster_fast_greedy(g_2020)

end.time <- Sys.time()
time_diff <- round(end.time - start.time, 2)
time_diff

# Apply infomap clustering
start.time <- Sys.time()
communities_infomap_2016 <- cluster_infomap(g_2016)
communities_infomap_2017 <- cluster_infomap(g_2017)
communities_infomap_2018 <- cluster_infomap(g_2018)
communities_infomap_2019 <- cluster_infomap(g_2019)
communities_infomap_2020 <- cluster_infomap(g_2020)

end.time <- Sys.time()
time_diff <- round(end.time - start.time, 2)
time_diff

# Apply louvain clustering
start.time <- Sys.time()
communities_louvain_2016 <- cluster_louvain(g_2016)
communities_louvain_2017 <- cluster_louvain(g_2017)
communities_louvain_2018 <- cluster_louvain(g_2018)
communities_louvain_2019 <- cluster_louvain(g_2019)
communities_louvain_2020 <- cluster_louvain(g_2020)

end.time <- Sys.time()
time_diff <- round(end.time - start.time, 2)
time_diff

# Compare clusters for 2016 
compare(communities_fast_greedy_2016, communities_infomap_2016)
compare(communities_fast_greedy_2016, communities_louvain_2016)
compare(communities_louvain_2016, communities_infomap_2016)

# Compare clusters for 2017
compare(communities_fast_greedy_2017, communities_infomap_2017)
compare(communities_fast_greedy_2017, communities_louvain_2017)
compare(communities_louvain_2017, communities_infomap_2017)

# Compare clusters for 2018
compare(communities_fast_greedy_2018, communities_infomap_2018)
compare(communities_fast_greedy_2018, communities_louvain_2018)
compare(communities_louvain_2018, communities_infomap_2018)

# Compare clusters for 2019
compare(communities_fast_greedy_2019, communities_infomap_2019)
compare(communities_fast_greedy_2019, communities_louvain_2019)
compare(communities_louvain_2019, communities_infomap_2019)

# Compare clusters for 2020
compare(communities_fast_greedy_2020, communities_infomap_2020)
compare(communities_fast_greedy_2020, communities_louvain_2020)
compare(communities_louvain_2020, communities_infomap_2020)


# Second part

# frequencies - 1 - top 10 communities
library("plyr")
# INTERSECTION - find common authors at louvain cluster of all years  
common_authors_lv<-Reduce(intersect, list(communities_louvain_2016$names, communities_louvain_2017$names, 
                                         communities_louvain_2018$names, communities_louvain_2019$names,communities_louvain_2020$names))


common_authors_lv
length(common_authors_lv)

# membership - louvain algorithm 
membership_lv_2016 <- as.matrix(membership(communities_louvain_2016))
membership_lv_2017 <- as.matrix(membership(communities_louvain_2017))
membership_lv_2018 <- as.matrix(membership(communities_louvain_2018))
membership_lv_2019 <- as.matrix(membership(communities_louvain_2019))
membership_lv_2020 <- as.matrix(membership(communities_louvain_2020))

# 2016
df_members_2016 = as.data.frame((membership_lv_2016))
df_members_2016$Author <- rownames(df_members_2016)
rownames(df_members_2016) <- 1:nrow(df_members_2016)

# 2017
df_members_2017 = as.data.frame((membership_lv_2017))
df_members_2017$Author <- rownames(df_members_2017)
rownames(df_members_2017) <- 1:nrow(df_members_2017)

# 2018
df_members_2018 = as.data.frame((membership_lv_2018))
df_members_2018$Author <- rownames(df_members_2018)
rownames(df_members_2018) <- 1:nrow(df_members_2018)

# 2019
df_members_2019 = as.data.frame((membership_lv_2019))
df_members_2019$Author <- rownames(df_members_2019)
rownames(df_members_2019) <- 1:nrow(df_members_2019)

# 2020
df_members_2020 = as.data.frame((membership_lv_2020))
df_members_2020$Author <- rownames(df_members_2020)
rownames(df_members_2020) <- 1:nrow(df_members_2020)

# Find out the community - cluster that "Shaoping Ma" belongs

df_members_2016$V1[which(df_members_2016$Author == "Shaoping Ma")]
df_members_2017$V1[which(df_members_2017$Author == "Shaoping Ma")]
df_members_2018$V1[which(df_members_2018$Author == "Shaoping Ma")]
df_members_2019$V1[which(df_members_2019$Author == "Shaoping Ma")]
df_members_2020$V1[which(df_members_2020$Author == "Shaoping Ma")]


# Show the length of each community where "Shaoping Ma" belongs
length(communities_louvain_2016$membership[which(communities_louvain_2016$membership == 242)])
length(communities_louvain_2017$membership[which(communities_louvain_2017$membership == 640)])
length(communities_louvain_2018$membership[which(communities_louvain_2018$membership == 147)])
length(communities_louvain_2019$membership[which(communities_louvain_2019$membership == 752)])
length(communities_louvain_2020$membership[which(communities_louvain_2020$membership == 251)])

# compare author similaritities in communities

sub_2016 <- subset(df_members_2016, V1 == 242)
sub_2017 <- subset(df_members_2017, V1 == 640)
sub_2018 <- subset(df_members_2018, V1 == 147)
sub_2019 <- subset(df_members_2019, V1 == 752)
sub_2020 <- subset(df_members_2020, V1 == 251)

# intersection 
similarities <- Reduce(intersect, list(sub_2016$Author,sub_2017$Author,sub_2018$Author,sub_2019$Author,sub_2020$Author))
similarities
# "Min Zhang 0006", "Shaoping Ma", "Yiqun Liu 0001"

# communities vertices plot
communities_vertices <- c(length(communities_louvain_2016$membership[which(communities_louvain_2016$membership == 242)]),
                          length(communities_louvain_2017$membership[which(communities_louvain_2017$membership == 640)]),
                          length(communities_louvain_2018$membership[which(communities_louvain_2018$membership == 147)]),
                          length(communities_louvain_2019$membership[which(communities_louvain_2019$membership == 752)]),
                          length(communities_louvain_2020$membership[which(communities_louvain_2020$membership == 251)]))
communities_vertices


# Criterion No1: Number of vertices among communities evolution
plot(year,communities_vertices,type = "b", xlab="Year", ylab="Communitie's Vertices", col = "black", main = "Authors' Communities Vertices Evolution")


# Final plots
set.seed(2822001)

# 2016
# Get the sizes of each community
community_size_2016 <- sizes(communities_louvain_2016)

# Some mid-size communities
mid_communities_2016 <- unlist(communities_louvain_2016[community_size_2016 > 40 & community_size_2016 < 80])

# Induce a subgraph of graph using in_mid_community
sub2016_directed <- induced.subgraph(g_2016, mid_communities_2016)
sub2016_undirected<- as.undirected(sub2016_directed)
subgraph_louvain_2016 <- cluster_louvain(sub2016_undirected)

# edges cross between commmunities
is_crossing_2016 <- crossing(g_2016, communities = communities_louvain_2016)

# Set edge linetype: solid for crossings, dotted otherwise 
E(g_2016)$lty <- ifelse(is_crossing_2016, "solid", "dotted")


# Plot  mid-size communities
plot(sub2016_directed, 
     vertex.color=rainbow(17, alpha=1)[subgraph_louvain_2016$membership], 
     vertex.label=NA, 
     edge.arrow.size=.2, 
     vertex.size=10,
     margin = 0,  
     coords = layout_with_kk(sub2016_directed), 
     edge.arrow.width = 0.8, 
     edge.arrow.size = 0.2, 
     lty=E(g_2016)$lty, 
     main="Communities of year 2016")



# 2017
# Get the sizes of each community
community_size_2017 <- sizes(communities_louvain_2017)

# Some mid-size communities
mid_communities_2017 <- unlist(communities_louvain_2017[community_size_2017 > 40 & community_size_2017 < 80])

# Induce a subgraph of graph using in_mid_community
sub2017_directed <- induced.subgraph(g_2017, mid_communities_2017)
sub2017_undirected<- as.undirected(sub2017_directed)
subgraph_louvain_2017 <- cluster_louvain(sub2017_undirected)

# edges cross between commmunities
is_crossing_2017 <- crossing(g_2017, communities = communities_louvain_2017)

# Set edge linetype: solid for crossings, dotted otherwise 
E(g_2017)$lty <- ifelse(is_crossing_2017, "solid", "dotted")


# Plot  mid-size communities
plot(sub2017_directed, 
     vertex.color=rainbow(17, alpha=1)[subgraph_louvain_2017$membership], 
     vertex.label=NA, 
     edge.arrow.size=.2, 
     vertex.size=10,
     margin = 0,  
     coords = layout_with_kk(sub2017_directed), 
     edge.arrow.width = 0.8, 
     edge.arrow.size = 0.2, 
     lty=E(g_2017)$lty, 
     main="Communities of year 2017")


# 2018
# Get the sizes of each community
community_size_2018 <- sizes(communities_louvain_2018)

# Some mid-size communities
mid_communities_2018 <- unlist(communities_louvain_2018[community_size_2018 > 40 & community_size_2018 < 80])

# Induce a subgraph of graph using in_mid_community
sub2018_directed <- induced.subgraph(g_2018, mid_communities_2018)
sub2018_undirected<- as.undirected(sub2018_directed)
subgraph_louvain_2018 <- cluster_louvain(sub2018_undirected)

# edges cross between commmunities
is_crossing_2018 <- crossing(g_2018, communities = communities_louvain_2018)

# Set edge linetype: solid for crossings, dotted otherwise 
E(g_2018)$lty <- ifelse(is_crossing_2018, "solid", "dotted")


# Plot  mid-size communities
plot(sub2018_directed, 
     vertex.color=rainbow(17, alpha=1)[subgraph_louvain_2018$membership], 
     vertex.label=NA, 
     edge.arrow.size=.2, 
     vertex.size=10,
     margin = 0,  
     coords = layout_with_kk(sub2018_directed), 
     edge.arrow.width = 0.8, 
     edge.arrow.size = 0.2, 
     lty=E(g_2018)$lty, 
     main="Communities of year 2018")


# 2019
# Get the sizes of each community
community_size_2019 <- sizes(communities_louvain_2019)

# Some mid-size communities
mid_communities_2019 <- unlist(communities_louvain_2019[community_size_2019 > 40 & community_size_2019 < 80])

# Induce a subgraph of graph using in_mid_community
sub2019_directed <- induced.subgraph(g_2019, mid_communities_2019)
sub2019_undirected<- as.undirected(sub2019_directed)
subgraph_louvain_2019 <- cluster_louvain(sub2019_undirected)

# edges cross between commmunities
is_crossing_2019 <- crossing(g_2019, communities = communities_louvain_2019)

# Set edge linetype: solid for crossings, dotted otherwise 
E(g_2019)$lty <- ifelse(is_crossing_2019, "solid", "dotted")


# Plot  mid-size communities
plot(sub2019_directed, 
     vertex.color=rainbow(17, alpha=1)[subgraph_louvain_2019$membership], 
     vertex.label=NA, 
     edge.arrow.size=.2, 
     vertex.size=10,
     margin = 0,  
     coords = layout_with_kk(sub2019_directed), 
     edge.arrow.width = 0.8, 
     edge.arrow.size = 0.2, 
     lty=E(g_2019)$lty, 
     main="Communities of year 2019")



# 2020
# Get the sizes of each community
community_size_2020 <- sizes(communities_louvain_2020)

# Some mid-size communities
mid_communities_2020 <- unlist(communities_louvain_2020[community_size_2020 > 40 & community_size_2020 < 80])

# Induce a subgraph of graph using in_mid_community
sub2020_directed <- induced.subgraph(g_2020, mid_communities_2020)
sub2020_undirected<- as.undirected(sub2020_directed)
subgraph_louvain_2020 <- cluster_louvain(sub2020_undirected)

# edges cross between commmunities
is_crossing_2020 <- crossing(g_2020, communities = communities_louvain_2020)

# Set edge linetype: solid for crossings, dotted otherwise 
E(g_2020)$lty <- ifelse(is_crossing_2020, "solid", "dotted")


# Plot  mid-size communities
plot(sub2020_directed, 
     vertex.color=rainbow(17, alpha=1)[subgraph_louvain_2020$membership], 
     vertex.label=NA, 
     edge.arrow.size=.2, 
     vertex.size=10,
     margin = 0,  
     coords = layout_with_kk(sub2020_directed), 
     edge.arrow.width = 0.8, 
     edge.arrow.size = 0.2, 
     lty=E(g_2020)$lty, 
     main="Communities of year 2020")
