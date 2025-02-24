# sta404-R-intro-spatial-data-display-BLANK-09oct17.R
# /home/baileraj/sta404
#
# References:
#    Chang 13.17-13.20
#    Lovelace et al. https://cran.r-project.org/doc/contrib/intro-spatial-rl.pdf

# Mapping
# Chang - 13.17-13.20
# http://spatial.ly/2013/12/introduction-spatial-data-ggplot2/
# http://uchicagoconsulting.wordpress.com/tag/r-ggplot2-maps-visualization/# 
# datacamp:  Data Visualization with ggplot2 (Part 3) 
#                  (3) Plots for specific data types 

# GIS = Geographic Information System
#   Choropleth  := drawing polygons (lines, points) often shaded using levels other variable
#   Cartographic:= drawn topographical, altitude, 
#                  photograph, hybrid
#                  (ggmap)

# load packages:
library(maps)             # Chang 13.17
library(ggplot2)
library(ggmap)            # note citation('ggmap') if you use it
library(mapproj)
library(ggthemes)

# library(rgdal) # other packages of possible interest for mapping
# library(rgeos) # 
# library(maptools)
# library(tmap)  # 

# CONSTRUCTING BASIC MAP ==============================================
# maps built into ggplot2 
#  global (world, world2), country (usa, nz, ...),  USA (county, state)

states_map <- map_data("state")
str(states_map)
unique(states_map$region)

# longitude :=  east/west direction (relative to Greenwich, England)
# latitude  :=  north/south direction (relative to the equator)

ggplot(states_map, aes(x = long, y = lat)) +
    geom_point()

ohio_map <- subset(states_map, states_map$region=="ohio")
unique(ohio_map$region)

ggplot(ohio_map, aes(x=long,y=lat,group=group))+
    geom_polygon(fill="white", colour="black")

mw_map <- map_data("state", region=c("ohio","kentucky","indiana",
                                     "michigan","west virginia",
                                     "pennsylvania"))
ggplot(mw_map, aes(x=long,y=lat,group=group,fill=region))+
    geom_polygon(fill="white", colour="black")

ggplot(mw_map, aes(x=long,y=lat,group=group,fill=region))+
    geom_polygon(fill="white", colour="black") +
    coord_map() +       # map projection correction
    theme_nothing()

# ADDING POINTS AND TEXT TO MAP ==============================================
# Oxford Latitude, longitude
#      39.5070∞ N, 84.7452∞ W

oxford_df <- data.frame(long=-84.7452, lat=39.5070)

# adding a point and annotation
# http://ggplot2.tidyverse.org/reference/annotate.html
ggplot()+
    geom_polygon(data=mw_map, aes(x=long,y=lat,group=group,fill=region),
                 fill="white", colour="black") +
    geom_point(data=oxford_df,aes(x=long,y=lat)) +
    annotate(geom="text",x=-84.7452,y=39.5070,
             label="Oxford",adj=0, color="blue") +
    coord_map() +       # map projection correction
    theme_nothing()

# CONSTRUCTING CHOROPLETH MAP =========================================
# choropleth map
# OLD http://www.census.gov/statab/ranks/rank19.html
#   may need to determine where these data might be on the census site
# college.grad <- data.frame(region=c("ohio","kentucky","indiana",
#                                     "michigan","west virginia",
#                                     "pennsylvania"),
#                            rate=c(24.1,20.0,22.1,24.7,17.3,25.8))

# college grad updated - from factfinder part of census
# https://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?pid=ACS_15_5YR_S1501&prodType=table

college.grad <- data.frame(region=c("ohio","kentucky","indiana",
                                    "michigan","west virginia",
                                    "pennsylvania"),
                           rate=c(26.1, 22.3, 24.1, 26.9, 19.2, 28.6))

grad_map <- merge(mw_map, college.grad, by.x="region", by.y="region")

head(grad_map)

ggplot(grad_map, aes(x=long,y=lat, group=group, fill=rate)) +
    geom_polygon(colour="black") +
    coord_map("polyconic")

# Chang p. 314 - diverging from middle value example

ggplot(grad_map, aes(x=long,y=lat, group=group, fill=rate)) +
    geom_polygon(colour="black") +
    scale_fill_gradient2(low="#559999",mid="grey90",high="#BB650B",
                         midpoint=median(college.grad$rate)) +
    coord_map("polyconic") +
    theme_minimal()

# p. 316 - example with colorRampPalette worth checking out

theme_clean <- function(base_size=12)  {
    # from Chang 13.19
    require(grid)
    theme_grey(base_size) %+replace%
        theme(
            axis.title = element_blank(),
            axis.text = element_blank(),
            panel.background = element_blank(),
            panel.grid = element_blank(),
            axis.ticks.length=unit(0,"cm"),
            axis.ticks.margin=unit(0,"cm"),
            panel.margin=unit(0,"lines"),
            plot.margin=unit(c(0,0,0,0),"lines"),
            complete=TRUE
        )
}

ggplot(grad_map, aes(x=long,y=lat, group=group, fill=rate)) +
    geom_polygon(colour="black") +
    scale_fill_gradient2(low="#559999",mid="grey90",high="#BB650B",
                         midpoint=median(college.grad$rate)) +
    coord_map("polyconic") +
    theme_clean()

ggplot(grad_map, aes(x=long,y=lat, group=group, fill=rate)) +
    geom_polygon(colour="black") +
    scale_fill_gradient2(low="#559999",mid="grey90",high="#BB650B",
                         midpoint=median(college.grad$rate)) +
    coord_map("polyconic") +
    labs(fill="College Grads %\n(ACS 2015)") +
    theme_clean()
#  theme_map()

ggplot(grad_map, aes(x=long,y=lat, group=group, fill=rate)) +
    geom_polygon(colour="white") +
    scale_fill_gradient(low="black",high="grey") +
    coord_map("polyconic") +
    labs(fill="College Grads %\n(ACS 2015)") +
    theme_clean()

us.state.map <- map_data('state')
head(us.state.map)
states <- levels(as.factor(us.state.map$region))
df <- data.frame(region = states, value = runif(length(states), min=0, max=100),stringsAsFactors = FALSE)

map.data <- merge(us.state.map, df, by='region', all=T)
map.data <- map.data[order(map.data$order),]
head(map.data)

# US Counties - from "maps" package and ggplot2::map_data
map.county <- map_data('county')  # ggplot2 function - turns maps pkg data into DF

ohio.county <- subset(map.county, region=="ohio")

ggplot(ohio.county, aes(x=long,y=lat,group=group,fill=subregion)) +
    geom_polygon() +
    guides(fill='none') +
    theme_map()


#=======================================================================
# Maps from Shapefiles (from DataCamp)
# Although the built-in maps from the maps package are 
# very convenient, using shapefiles is a more flexible 
# way of accessing geographic and political boundaries.
# 
# Shapefiles can be used to describe points, polylines 
# or polygons - here you'll focus on polygons for 
# drawing maps.
# 
# A single shapefile actually consists of several files, 
# each describing a specific aspect of the overall 
# geometry. The three core file types are:
# 
# .shp: the shape, the feature geometry itself.
# .shx: the shape index, a positional index.
# .dbf: the attribute, attributes for each shape arranged in columns.
# The prefix name of these files must be consistent and they must be kept in the same directory. 
#
# readOGR

#=======================================================================
# CARTOGRAPHIC MAPS
# ggmap - not working on Rstudio server but on local RStudio
#  REF:  http://stat405.had.co.nz/ggmap.pdf

# Oxford, Ohio
#     39.5070∞ N, 84.7452∞ W

library(ggmap)

oxford_oh <- c(lon= -84.7452, lat=39.5070)
oxford_map <- get_map(oxford_oh, zoom=13, maptype="satellite")

ggmap(oxford_map)

oxford_map_bw <- get_map(oxford_oh, zoom=13, 
                         source="stamen",
                         maptype="toner")
ggmap(oxford_map_bw)

oxford_map_bw12 <- get_map(oxford_oh, zoom=12, 
                           source="stamen",
                           maptype="toner")
ggmap(oxford_map_bw12)

# can use the following functions
# geocode    := query Google to get lat,long info
# make_bbox  := define bounding box for map sites
# get_map    := extract cartographic map from google
#               (can pick maptype, style, zoom)
# ggmap      := ggplot2 base map layer for carto maps


#=======================================================================
# You may have to deal with observations of dates or times
# While these may look like characters, it is important to
# store these as numbers for calculations
# We will learn more about lubridate
