# sta404-R-preparing-data-for-plotting-BLANK-02oct17.R

# To reset Global environment after every session
# Tools > Global Options > "uncheck" Rstore .RData into workspace at startup
#                           "choose" Save workspace to .RData on exit "Never"

# Expanded and Revised from: Bali-R-code-gather-21mar17.R

# Input Data Set (Do not read into RStudio.Miamioh.edu - read into local version)
#    http://www.users.miamioh.edu/baileraj/workshop-Bali/HNP_Data.csv
# Original source:
#    http://datacatalog.worldbank.org/   (HNP_Data.csv)
#    https://data.worldbank.org/data-catalog/health-nutrition-and-population-statistics
# Comments:
#  1.  This dataset has 89785 rows and 60 columns
#  2.  Many of the columns are missing values
#  3.  Some of the rows are aggregate data (e.g. Arab World) vs. country
#  4.  Please do NOT read this into the Rstudio.miamioh.edu server

# Resources
#   Rstudio cheat sheets - Tidyr particularly important

# TO START ...
# Download the HNP_Data.csv file to your desktop/laptop computer
# Open this file (Excel should work)

# This data set is not "Tidy" - why?
# Tidy data are ... (from the Data Import cheat sheet)
#    i)  each variable in its own column
#   ii)  Each observation, or case, is in its own row

# Some of the tidyr verbs 
# tidyr::gather - move wide to long formats
# tidyr::separate - move long to wide formats

library(tidyverse)
# data()   # available data sets


# TOY EXAMPLE:  gather - quick digression to explore a small example

temp_DF <- data.frame(country=paste("C",rep(1:5,2),sep = ""),
                      vars= as.character(rep(c("a","b"),c(5,5))), 
                      YR1960=rnorm(10),YR1961=rnorm(10))
View(temp_DF)

# Moving from WIDE TO LONG formats ... 
# first apply tidyr::gather to move year columns into rows
#    key = name of column variable with levels = variable names from original DF
#  value = name of the column variable with values of variables from original DF
#  other arguments are the columns in the original DF 

temp_DF %>% 
    group_by(vars) %>% 
    gather(key=cyear, value=measurement, YR1960, YR1961)

# note that cyear has values YR1960 and YR1961 and these are character values
# let's fix this and add this as a new variable to the data frame
substring("YR1960",3)

as.numeric(substring("YR1960",3))

temp_DF %>% 
    group_by(vars) %>% 
    gather(key=cyear, value=measurement, YR1960, YR1961) %>% 
    mutate(year = as.numeric(substring(cyear,3))) %>% 
    select(-cyear)

temp_DF_long <- temp_DF %>% 
    group_by(vars) %>% 
    gather(key=cyear, value=measurement, YR1960, YR1961) %>% 
    mutate(year = as.numeric(substring(cyear,3))) %>% 
    select(-cyear)
View(temp_DF_long)

# Ok, good start but we want to have variables in different columns

# TOY EXAMPLE:  spread ...

# Moving from LONG to WIDE formats ...
# first apply tidyr::spread to move year columns into rows
#    key = name of column variable in the original DF with levels to 
#             be made into separate columns in the resulting DF
#  value = name of the column variable in the original DF that will be
#             the values under the new columns in the resulting DF

temp_DF_expand <- temp_DF_long %>% 
    spread(key=vars,value=measurement)

View(temp_DF_expand)

#---------------------------------------------------------
# bring in new data set from the World Bank
#   Health Nutrition and Population Statistics

data_URL <- "https://www.users.miamioh.edu/baileraj/workshop-Bali/HNP_Data.csv"
HNP_DF <- read_csv(data_URL)

# read from local disk (my Mac)
# HNP_DF2 <- read_csv("/Users/baileraj/Desktop/Workshop-Bali-2017/HNP_Data.csv")

View(HNP_DF)

unique(HNP_DF$`Country Code`)
unique(HNP_DF$`Indicator Name`)

# Subset data to include the following variables ...
# Birth rate, crude (per 1,000 people)
# Death rate, crude (per 1,000 people)
# Fertility rate, total (births per woman)
# Life expectancy at birth, female (years)
# Life expectancy at birth, male (years)
# Mortality rate, under-5 (per 1,000)
# Rural population (% of total population)
# Survival to age 65, female (% of cohort)
# Survival to age 65, male (% of cohort)
# Urban population (% of total)

HNP_DF_subset <- HNP_DF %>% 
    filter(`Indicator Name` %in% 
               c("Birth rate, crude (per 1,000 people)",
                 "Death rate, crude (per 1,000 people)",
                 "Fertility rate, total (births per woman)",
                 "Life expectancy at birth, female (years)",
                 "Life expectancy at birth, male (years)",
                 "Mortality rate, under-5 (per 1,000)",
                 "Rural population (% of total population)",
                 "Survival to age 65, female (% of cohort)",
                 "Survival to age 65, male (% of cohort)",
                 "Urban population (% of total)"))

View(HNP_DF_subset)
dim(HNP_DF)
dim(HNP_DF_subset)

# need to 'gather' the years AND 'spread' the variables

HNP_DF_long <- HNP_DF_subset %>% 
    group_by(`Indicator Code`) %>%
    gather(key=cyear, value=number, `1960`:`2015` ) %>% 
    mutate(year=as.numeric(cyear))

View(HNP_DF_long)
dim(HNP_DF_long)
names(HNP_DF_long)

HNP_DF_long <- HNP_DF_long[,-c(5,6)]  # removing unnecessary columns

View(HNP_DF_long)

str(HNP_DF_long)

#
# need to expand variables
#
# Issue:  group attribute still attached to DF from previous step,
#         used as.data.frame to coerce this back to regular data frame
# Warning: sometimes moving back to a data frame is useful before other
#          manipulation

HNP_DF_expand <- as.data.frame(HNP_DF_long) %>%   # remove grouped DF attr
    select(-`Indicator Code`) %>% 
    spread(key=`Indicator Name`,value=number) %>% 
    filter(year < 2016) 

View(HNP_DF_expand)

########################################### ..........................
# rename variables for easier specification ..........................
########################################### ..........................

names(HNP_DF_expand) <- c(
    "Country_Name",
    "Country_Code",
    "year",
    "birth_Rate",
    "death_Rate",
    "fertility_PC_rate",
    "life_exp_female",
    "life_exp_male",
    "child_mortality",
    "rural_pop_pct",
    "surv_age65_female_pct",
    "surv_age65_male_pct",
    "urban_pop_pct"
)

# ===================== now we can start doing some data viz ...
#
#  graphics code 
#

library(readr)
library(ggplot2)
library(dplyr)

####################################################

# Exploring Birth rate changes over time

ggplot(data = HNP_DF_expand) + geom_line(aes(x = year, y = birth_Rate,  
                                             group = Country_Name))

ggplot(data = HNP_DF_expand) + 
    geom_line(aes(x = year, y = birth_Rate, 
                  group = Country_Name)) + 
    ggtitle("Birth Rate Over Time") + 
    xlab("Year") + 
    ylab("Birth Rate (Births/Population)")


ggplot(data = HNP_DF_expand) + 
    geom_line(aes(x = year, y = birth_Rate,group= Country_Name), alpha = 0.1)+ 
    geom_line(data = subset(HNP_DF_expand, Country_Name == "Indonesia"),
              aes(x = year, y   =birth_Rate, group = Country_Name ), color = "red") + ggtitle("Birth Rate Over 
                                                                                              Time for Indonesia")+ ylab("Birth Rate") + xlab("Time")

ggplot(data = subset(HNP_DF_expand, year == 2013)) + 
    geom_point(aes(x= birth_Rate,y = child_mortality)) + 
    ggtitle("Birth Rate vs. Child Mortality for 2013") + 
    xlab("Birth Rate") + ylab("Child Mortality")

#
# add reference to median and 25th and 75th percentiles

HNP_Indonesia <- HNP_DF_expand %>% 
    filter(Country_Name == "Indonesia")

HNP_avg <- HNP_DF_expand %>% 
    group_by(year) %>% 
    summarize(medDR = median(birth_Rate,na.rm=TRUE), 
              Q1DR=quantile(birth_Rate,.25,na.rm=TRUE),
              Q3DR=quantile(birth_Rate,.75,na.rm=TRUE))

HNP_DF_expand %>% 
    ggplot(aes(x=year,y=birth_Rate,group=Country_Name)) +
    geom_line(color="gray") +
    geom_line(data=HNP_Indonesia, aes(x=year,y=birth_Rate), color="indianred")  # setting attribute

HNP_DF_expand %>% 
    ggplot(aes(x=year,y=birth_Rate,group=Country_Name)) +
    geom_line(color="gray",alpha=.6) +
    geom_line(data=HNP_Indonesia, aes(x=year,y=birth_Rate), color="indianred",
              size=1.5)    

ggplot() +
    geom_line(data=HNP_DF_expand, 
              aes(x=year,y=birth_Rate,group=Country_Name), color="gray", alpha=.6) +
    geom_line(data=HNP_Indonesia, aes(x=year,y=birth_Rate), color="indianred",
              size=1.5) +
    geom_line(data=HNP_avg, aes(x=year,y=Q1DR),color='blue',linetype="dashed", size=1)+
    geom_line(data=HNP_avg, aes(x=year,y=Q3DR),color='blue',linetype="dashed", size=1)+
    geom_line(data=HNP_avg, aes(x=year,y=medDR),color='blue', size=1)


# IN CLASS:  redo this with a different country



#############################################################


#
# new labels and title

########################  ..........................................
########################  Number of countries exceed expectation ...
########################  ..........................................

unique(HNP_DF_expand$Country_Name)

HNP_DF_expand_no_groups <- HNP_DF_expand %>% 
    filter(!(Country_Name %in% c("Arab World", 
                                 "Caribbean small states",
                                 "Central Europe and the Baltics",
                                 "Early-demographic dividend",
                                 "East Asia & Pacific",
                                 "East Asia & Pacific (excluding high income)",
                                 "East Asia & Pacific (IDA & IBRD countries)",
                                 "Europe & Central Asia",                               
                                 "Europe & Central Asia (excluding high income)",   
                                 "Europe & Central Asia (IDA & IBRD countries)",
                                 "European Union",
                                 "Fragile and conflict affected situations",
                                 "Heavily indebted poor countries (HIPC)",
                                 "High income",
                                 "Late-demographic dividend",
                                 "Latin America & Caribbean",                  
                                 "Latin America & Caribbean (excluding high income)",
                                 "Latin America & the Caribbean (IDA & IBRD countries)",
                                 "Least developed countries: UN classification",
                                 "Low & middle income",
                                 "Low income",
                                 "Lower middle income",
                                 "Middle East & North Africa",                         
                                 "Middle East & North Africa (excluding high income)",  
                                 "Middle East & North Africa (IDA & IBRD countries)",   
                                 "Middle income",
                                 "North America",
                                 "OECD members",
                                 "Other small states",
                                 "Pacific island small states",
                                 "Post-demographic dividend",                           
                                 "Pre-demographic dividend",
                                 "Small states",
                                 "Sub-Saharan Africa",                         
                                 "Sub-Saharan Africa (excluding high income)",
                                 "Sub-Saharan Africa (IDA & IBRD countries)" ,
                                 "Upper middle income",
                                 "World")))  

unique(HNP_DF_expand_no_groups$Country_Name)

HNP_DF_expand_no_groups <- HNP_DF_expand_no_groups %>% 
    filter(!(Country_Name %in% c("Euro area")))

View(HNP_DF_expand_no_groups)

################################################ .....................
# now we can start looking at graphical displays .....................
################################################ .....................

HNP_DF_expand_no_groups %>% 
    filter(year %in% c(1960, 1970, 1980, 1990, 2000, 2010)) %>% 
    ggplot(aes(x=life_exp_female)) +
    geom_histogram(binwidth = 2) +
    facet_grid(year ~ .)

#####################################-------------------------------
# package for countrycode conversions (ASIDE)
#####################################-------------------------------

install.packages("countrycode")
library(countrycode)
help(package=countrycode)

names(countrycode_data)
countrycode_data$country.name.en

View(countrycode_data)

#####################-------------------------------

ggplot() +
    geom_line(data=HNP_DF_expand, 
              aes(x=year,y=death_Rate,group=Country_Name), color="gray", alpha=.6) +
    geom_line(data=HNP_Indonesia, aes(x=year,y=death_Rate), color="indianred",
              size=1.5) +
    geom_line(data=HNP_avg, aes(x=year,y=Q1DR),color='blue',linetype="dashed", size=1)+
    geom_line(data=HNP_avg, aes(x=year,y=Q3DR),color='blue',linetype="dashed", size=1)+
    geom_line(data=HNP_avg, aes(x=year,y=medDR),color='blue', size=1) +
    ylab("Death Rate (#/1000)") +
    xlab("Year")+ 
    ggtitle("Country-specific Annual Death Rates between 1960 - 2014\n(Indonesia is the red line; world 
            avg. is the solid blue line, world quartiles are the dashed lines)")

######################################## ...............................
# Eliminating groups of country for data ...............................
######################################## ...............................

HNP_avg_noG <- HNP_DF_expand_no_groups %>% 
    group_by(year) %>% 
    summarize(medDR = median(death_Rate,na.rm=TRUE), 
              Q1DR=quantile(death_Rate,.25,na.rm=TRUE),
              Q3DR=quantile(death_Rate,.75,na.rm=TRUE))

ggplot() +
    geom_line(data=HNP_DF_expand_no_groups, 
              aes(x=year,y=death_Rate,group=Country_Name), color="gray", alpha=.6) +
    geom_line(data=HNP_Indonesia, aes(x=year,y=death_Rate), color="indianred",
              size=1.5) +
    geom_line(data=HNP_avg_noG, aes(x=year,y=Q1DR),color='blue',linetype="dashed", size=1)+
    geom_line(data=HNP_avg_noG, aes(x=year,y=Q3DR),color='blue',linetype="dashed", size=1)+
    geom_line(data=HNP_avg_noG, aes(x=year,y=medDR),color='blue', size=1) +
    ylab("Death Rate (#/1000)") +
    xlab("Year")+ 
    ggtitle("Country-specific Annual Death Rates between 1960 - 2014\n(Indonesia is the red line; world 
            avg. is the solid blue line, world quartiles are the dashed lines)")



# --------------------------------------------------------------------
# save the plot
gg <- ggplot() +
    geom_line(data=HNP_DF_expand, 
              aes(x=year,y=death_Rate,group=Country_Name), color="gray", alpha=.6) +
    geom_line(data=HNP_Indonesia, aes(x=year,y=death_Rate), color="indianred",
              size=1.5) +
    geom_line(data=HNP_avg, aes(x=year,y=Q1DR),color='blue',linetype="dashed", size=1)+
    geom_line(data=HNP_avg, aes(x=year,y=Q3DR),color='blue',linetype="dashed", size=1)+
    geom_line(data=HNP_avg, aes(x=year,y=medDR),color='blue', size=1) +
    ylab("Death Rate (#/1000)") +
    xlab("Year")+ 
    ggtitle("Country-specific Annual Death Rates between 1960 - 2014\n(Indonesia is the red line; world 
            avg. is the solid blue line, world quartiles are the dashed lines)")

gg + theme_bw()

# identifying countries with high death rates
HNP_DF_expand %>%   
    arrange(death_Rate) %>%   
    na.omit(death_Rate) %>%   
    select(Country_Name, death_Rate) %>%   
    tail(n=10)

# identifying countries on the plot
gg +  
    theme_bw() +  
    annotate("text", label = "Cambodia", x = 1977, y = 56, size = 3.5, colour = "black") +  annotate("text", 
                                                                                                     label = "Rwanda", x = 1993, y = 41, size = 3.5, colour = "black")

# final adjustments
gg +  
    theme_bw() +  
    annotate("text", label = "Cambodia", x = 1977, y = 56, size = 3.5, colour = "black") +  
    annotate("text", label = "Rwanda", x = 1993, y = 41, size = 3.5, colour = "black") +
    scale_x_continuous(limits = c(1960, 2015), breaks = seq(1960,2015,5)) + 		# scales x axis
    scale_y_continuous(limits = c(0, 60),breaks = seq(0,60,15)) +  				# scales y axis
    theme(plot.title = element_text(hjust = 0.5), 							# 
          centers title        
          panel.grid.minor = element_blank())  							# 
removes minor grid lines


# highest DR?
HNP_DF_expand %>% 
    arrange(death_Rate) %>% 
    na.omit(death_Rate) %>% 
    select(Country_Name, death_Rate) %>% 
    tail()

# lowest DR?
HNP_DF_expand %>% 
    arrange(death_Rate) %>% 
    na.omit(death_Rate) %>% 
    select(Country_Name, death_Rate) %>% 
    head()

# add more informative axis labels
# final

#####################################################################################
################

ggplot()+
    geom_line(aes(x=year, y=death_Rate, color=factor(Country_Name), group = factor(Country_Name)), 
              color = "gray",
              alpha=.4, data = HNP_DF_expand) +
    geom_line(aes(x=year, y=death_Rate, group=factor(Country_Name)), color = "indianred",
              size=1, data = HNP_DF_expand[HNP_DF_expand$Country_Name == "Indonesia",]) +
    guides(col=FALSE) +
    scale_x_continuous(breaks = seq(1960, 2020, 10)) +
    scale_y_continuous(breaks = seq(0, 60, 10)) +
    ylab("Death Rate (%)") +
    xlab("Year") +
    theme_bw() + 
    ggtitle("Death Rate Changes Over Time") +
    theme(strip.background = element_blank(),
          legend.title.align=0.5,
          plot.title = element_text(hjust = 0.5))

# =========================================================================
# simple example
# Find the outlying observation in this data set ...

# working with a little data set ...
myURL <- "https://www.users.miamioh.edu/baileraj/workshop-Bali/country.csv"
country_DF <- read_csv(myURL)
country_DF <- country_DF %>%   
    mutate(pcturban = as.numeric(pcturban))  # needed to change format of input

country_life <- country_DF %>% 
    gather(key=gender,value=life_expectancy,lifemen,lifewom) %>% 
    mutate(gender=recode(gender,lifemen="men",lifewom="women")) %>% 
    select(name,gender,life_expectancy) 

View(country_life)

# how does this graph relate to the discussion of ggplot producing graphs as layers?

ggplot(data=country_DF, aes(x=literacy,y=lifewom)) +  
    geom_point() +  
    geom_smooth(method="lm",se=FALSE,color="red") +  
    geom_smooth(method="loess",se=FALSE,color="blue",width=.5)

# a couple of other quick illustrations of example plots

ggplot(data=country_life,aes(x=gender,y=life_expectancy))+
    geom_boxplot() 

ggplot(data=country_life,aes(x=gender,y=life_expectancy))+
    geom_boxplot() + coord_flip()

ggplot(data=country_life,aes(x=life_expectancy))+
    geom_histogram(binwidth=2.5) 

ggplot(data=country_life,aes(x=life_expectancy,fill=gender))+
    geom_histogram(binwidth=2.5) +
    facet_grid(gender~.)

########################################################################
# BONUS material - CAUTION - WORK IN PROGRESS
# map example

# You can play around with limits and other variables. Urban population percentage
# of population looked kind of cool. I think the best thing to do here would be to
# look at percentage increases and decreases from different years (maybe a 10 year
# gap) to tell a better story. The code is:

library(tidyverse) 
#install.packages("maps")
library(maps)

HNP_DF_Ranking_2014 <- HNP_DF_expand %>%
    filter(year==2014)

chloroMap <- map_data('world') %>%
    filter(region != 'Antarctica') %>%
    inner_join(HNP_DF_Ranking_2014, by=c("region" = "Country_Name")) %>%
    ggplot(aes(long, lat)) +
    geom_polygon(aes(group=group, fill=urban_pop_pct),colour="black",size=0.1) +
    coord_equal() +
    scale_x_continuous(expand=c(0,0), limits = c(80, 175)) +
    scale_y_continuous(expand=c(0,0), limits = c(-50, 35)) +
    labs(x='Longitude', y='Latitude') +
    theme_bw() +
    scale_fill_gradient("Urban Population (%)", high="darkgrey",
                        breaks = seq(0, 100, 20), limits = c(0, 100))

chloroMap

# The thing you have to change for the variable of interest is the fill argument in the geom_polygon() 
aes() function.
# Also, some countries data will be missing due the names not matching up between R's map_data set 
and the one we have used.
# The following code might remove this problem:

worldMap$Country <- ifelse(HNP_DF_Ranking_2014$Country_Name == "United States", "USA",
                           ifelse(HNP_DF_Ranking_2014$Country_Name == "United Kingdom", "UK",
                                  ifelse(HNP_DF_Ranking_2014$Country_Name == "Russian Federation", "Russia",
                                         ifelse(HNP_DF_Ranking_2014$Country_Name == "Venezuela, RB", "Venezuela",
                                                ifelse(HNP_DF_Ranking_2014$Country_Name == "Congo, Rep.", "Republic of 
                                                       Congo",
                                                       ifelse(HNP_DF_Ranking_2014$Country_Name == "Congo, Dem. Rep.", 
                                                              "Democratic Republic of the Congo",
                                                              ifelse(HNP_DF_Ranking_2014$Country_Name == "Iran, Islamic Rep.", 
                                                                     "Iran",
                                                                     ifelse(HNP_DF_Ranking_2014$Country_Name == "Egypt, Arab 
                                                                            Rep.", "Egypt",
                                                                            ifelse(HNP_DF_Ranking_2014$Country_Name == "Cote 
                                                                                   d'Ivoire", "Ivory Coast",
                                                                                   ifelse(HNP_DF_Ranking_2014$Country_Name == "Yemen, 
                                                                                          Rep.", "Yemen",
                                                                                          ifelse(HNP_DF_Ranking_2014$Country_Name == "Sint 
                                                                                                 Maarten (Dutch part)", "Sint Maarten",
                                                                                                 ifelse(HNP_DF_Ranking_2014$Country_Name == 
                                                                                                            "Korea, Rep.", "South Korea",
                                                                                                        ifelse(HNP_DF_Ranking_2014$Country.Code 
                                                                                                               == "PRK", "North Korea",
                                                                                                               
                                                                                                               ifelse(HNP_DF_Ranking_2014$Country_Name == "Micronesia, Fed. Sts.", "Micronesia",
                                                                                                                      
                                                                                                                      ifelse(HNP_DF_Ranking_2014$Country_Name == "Gambia, The", "Gambia",
                                                                                                                             
                                                                                                                             HNP_DF_Ranking_2014$Country_Name)))))))))))))))



# dates and times - Ch. 16 Wickham and Grolemund

library(lubridate)
today()
now()

ymd("2017-03-20")

mdy("March 20, 2017")

dmy("20-Mar-2017")

ymd(20170320)

# make_date() for dates, or make_datetime() for date-times
#    from year, month, day, hour, minute

# can switch btwn date-time and a date using as_datetime() and as_date()


# can extract individual parts of the date with the accessor functions
# year(), month(), mday() (day of the month), yday() (day of the year), wday() (day of the week), 
# hour(), minute(), and second().

temp <- dmy("20-Mar-2017")
year(temp)
month(temp)
mday(temp)
yday(temp)
wday(temp)

# round the date to a nearby unit of time:
#     floor_date(), round_date(), and ceiling_date()

# arithmetic with dates
time_since_2000 <- today() - ymd(20000101)
time_since_2000

as.duration(time_since_2000)

Sys.timezone()
