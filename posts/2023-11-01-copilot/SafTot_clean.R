# First day ------------------------------------------------------------

# use tidyverse package and readr package
library(tidyverse)
library(readr)

# Open SAFI_openrefine.csv in file data, call it SAFI_openrefine, use read_csv 


# View(SAFI_openrefine), not used here

# change order of variables

#Let us research a specific variable.
#show groups village

# We have to make this variable more consistent.
# change names of groups in village
# 49 will become Chirodzo, Chirdoze will become Chirodzo, Ruaca-Nhamuenda and Ruca wwill become Ruaca

# How does it look now?
#show groups village

# count village values are there in the survey results data?

# count interview_date values are there in the survey results data?  

# Look at variable `interview_date`. It is formatted as text. We have to change this to a date format.
# Is variable interview_date formatted as Text or Date? (ChatGPT)

#check the class of interview_date
if (class(my_variable) == "character") {
  print("The variable is formatted as text.")
} else if (class(my_variable) == "Date") {
  print("The variable is formatted as a date.")
} else {
  print("The variable is of an unknown type.")
}
class(SAFI_openrefine$interview_date)

# Change interview_date
# Use faceting to produce a timeline display for interview_date
# convert this column to dates

# R count different dates of variable interview_data 

## Transforming data
# remove left bracket from items_owned

#remove right bracket from items_owned

# remove all ' from items_owned

#remove white spaces from cells of items_owned

# remove all ; from items_owned

# items_owned count and add the objects

# add the objects of items_owned_count

# print the objects of items_owned_count

# how many radio do we have over 131 rows?



# Second day ------------------------------------------------------------------
# Before we start

# Open SAFI_clean.csv in file data, call it SAFI_clean, use read_csv
SAFI_clean <- read_csv("data/SAFI_clean.csv")

# Introduction to R 
area_hectares <- 50                 # land area in hectares
area_acres <- 2.47 * area_hectares  # convert to acres
area_acres                          # print the result

# create two variables r_length en r_width and assign values to them

# create a third value based on the first two

# changing r_length and r_width does not affect the value of r_area

# Functions and their arguments
sqrt(area_hectares)
round(3.14159)
round(3.14159, 2)
args(round)
?round

# what other functions are similar to round?
# ceiling, floor, trunc, signif
# Vectors and data types
hh_members <- c(3, 7, 10, 6)

#show hh_members

respondent_wall_type <- c("muddaub", "burntbricks", "sunbricks")
# show respondent_wall_type

# length hh_members and respondent_wall_type

# type of object

#structure of object

# adding elements
possessions <- c("bicycle", "radio", "television")

# add to end of object mobile phone

# add car at the beginning of the object

# show possessions

# some asked: put it in alphabetical order

# back to old order

# Show possessions again

# create a new factor for values with different types chr, int, dbl, logical
newfactor <- c("a", 1, 2.5, TRUE)

# check data type of your objects
num_char <- c(1, 2, 3, "a")
str(num_char)

num_logical <- c(1, 2, 3, TRUE)
str(num_logical)

char_logical <- c("a", "b", "c", TRUE)
str(char_logical)

tricky <- c(1, 2, 3, "4")
str(tricky)

# take care of order of data types chr < int < dbl < logical
# subsetting vectors
# second element of respondent_wall_type

# subset elements 3 and 2

# assign new value to second element of respondent_wall_type 1, 2, 3, 2, 1, 3
# call it more_respondent_wall_type
more_respondent_wall_type <- respondent_wall_type[c(1, 2, 3, 2, 1, 3)]

# Show more_respondent_wall_type

# hh_members conditional subsetting, first true, second false, third true, fourth true

# hh_members only greater than 5

# hh_members only smaller than four or  greater than 7

# hh_members only greater or equal than four and smaller or equal than 7

# possesions and equal to car

# possesions and equal to car and bicycle

# possessions and all elements are either car or bicycle

# possesions check if elements are either car, bicycle, truck, boat, bus

# Missing data
rooms <- c(2, 1, 1, NA, 7)

# mean rooms

# max rooms

# mean rooms without NA

# max rooms without NA

# extract those eleeemnts that are not NA

# count number of elements that are not NA

# count number of elements that are NA

# return object with incomplete cases removed

# create vector rooms
rooms <- c(1, 2, 1, 1, NA, 3, 1, 3, 2, 1, 1, 8, 3, 1, NA, 1)

# remove NA's from rooms and make new object called rooms_no_na

# median rooms_no_na

# calculate median rooms without NA's
# median(rooms, na.rm = TRUE)

# count number of elements that are not NA and are greater than 2, call it rooms_above_2


# length of rooms_above_2

# how many households have more than 2 rooms for sleeping


# Third day ---------------------------------------------------------------------
# Open libraries
# 1. INTRODUCTION 
library(tidyverse)
library(here)

# open dataset Safi_clean.csv in file data, call it interviews, use here package, na=NULL
interviews<-read_csv(
  file = here("data", "SAFI_clean.csv"),
  na = "NULL")

# show dataset interviews

# View interviews
# View(interviews) # do it in the console
# show first rows

# show first 10 rows

# what kind of object is interviews

# 2. INSPECTING DATA FRAMES 
# number of rows as the first element and number of columns as the second element

# number of rows

# number of columns

# show first 6 rows

# show last 6 rows

# return column names

# structure of interviews and information about class, length and content

# summary statistics of each column

# number of columsn and rows of the tibble, the names and class of each column, preview  

# 3. SUBSETTING DATA FRAMES 
#  first element in the first column of the tibble

# first element in the 6th column of the tibble

# first column of the tibble (as a vector)

#interviews[[1]] # same result

# first three elements in the 7th column of the tibble

# the 3rd row of the tibble

# all columns except the 1st column of the tibble

# interviews and exclude 7:131

# equivalent to head_interviews<-head(interviews)

# the whole tibble except the first column

# look for vector no_meals

# Excercise 
# 1. Create a tibble (interviews_100) containing only the data in row 100 of the interviews dataset.

# 2. Continue using interviews for each of the following activities
# Notice how `nrow()` gave you the number of rows in the tibble

# Use that number 131 to pull out just that last row in the tibble.

# compare the with what you see als the last row using `tail()`

# pull out that last row using nrow() instead of the row number
# create a new tibble (interviews_last) for that last row

# 3. Using the number of rows in the interviews dataset that you found in question 2, 
# extract the row that is in the middle of the dataset. 
#Store the content of this middle row in an object named interviews_middle. 
# (hint: This dataset has an odd number of rows, so finding the middle is a 
# bit trickier than dividing n_rows by 2. Use the median( ) 
# function and what you’ve learned about sequences in R to extract the middle row!

# 4. Combine nrow() with the - (exclude) notation above to reproduce the behavior of head(interviews), 
# keeping just the first through 6th rows of the interviews dataset.Call it interviews_head.
#interviews_head <- interviews[1:6, ]

# 4. Factors 

# ask levels

# number of levels

# current order of variablw respondent_floor_type

# change order of levels

# after reordering

# see levels now

# other variable respondent_floor_type, factor recode, fct_recode, brick replace cement
# brick = cement, recode factor

# show respondent_floor_type

# order factor respondent_floor_type as respondent_floor_type_ordered, ordered = TRUE

# after setting as ordered factor

# 5. Convert factors to characters 
# convert factor respondent_floor_type as a character vector

# new factor
year_fct <- factor(c(1990, 1983, 1977, 1998, 1990))
as.numeric(year_fct) # wrong, and no warning

# make it work
as.numeric(as.character(year_fct))
year_fct

# renaming factors
# create a vector from the data frame column "memb_assoc"

# convert to factor

# how does it look

# bar plot of the number of interviews who were members of irrigation associstions and who were not

# Let us recreate the vector from the data frame column "memb_assoc"

# replace the missing data with "undertermined"

# convert to factor

# Let's see what ik looks like

# bar plot of the number of interviews who were members of irrigation associstions and who were not

# Excercise
# rename the levels of the factor to have the first letter in uppercase: "No", "Undetermined", "Yes"
# use fct_recode()

# Recreate the bar plot such that "Undertermined is last(after "Yes")
# reorder levels. Use the new levels names

# make barplot of memb_assoc

# 6. Formatting dates 

# load package lubridate
library(lubridate)

# Extract our interview_date column  call it dates

# inspect structure of dates

# use the day() call it interviews$day

# use the month() call it interviews$month

# use the year() call it interviews$year

# look at interviews

# we have a vector of dates in character format, call it char_dates
char_dates <- c("7/31/2012", "8/9/2014", "4/30/2016")

# what is structure of char_dates

# convert it to format %m/%d/%Y, as_date()


# 7. Data wrangling with dplyr 
# load package dplyr
library(dplyr)

# selecting columns and filtering rows
# take interviews and select columns village, no_membrs, months_lack_food from interviews

# same with subsetting

# select a series of connected columns, village to respondent_wall_type

# filter observations with village name is Chirodzo

# filter observations with "and" operator (comma)
# output dataframe satisfies ALL specified conditions, village = Chirodzo, rooms > 1, no_meals >2

# filters observations with "&" logical operator
# output datafraem satisfies All specified conditions, village = Chirodzo, rooms > 1, no_meals >2

# filters observations with "|" logical operator
# output dataframe satisfies AT LEAST ONE of the specified conditions, village = Chirodzo, rooms or village == Ruaca

# Pipes
# call it interviews_ch and select en filter village = Chirodzo and village till respondent_wall_type

# use new pipe symboul |>

# Excercise
# using pipes, subset interviews and include respondents were members of an irrigation association
# and retain only the columns affect_conflicts, liv_count, no_meals

# mutate
# make new variabele which is called people_per_room and it is no_membrs devided by rooms

# interviews with filter out missing memb_assoc and use people_per_room and it is no_membrs devided by rooms

# Excercise
# create new dataframe from the interviews that meets the following conditions:xxx

## Split-apply-combine data analysis and the summarize verb
# interviews data, for each type of village (use village column), calculate the mean number of household members

# Obtain an ungrouped tibble

# mean_no_members from low to high

# now from high to low

# count village, please sort from high to low

# count village, sort from low to high

# Excercise
# How many households have an average of two meals per day overall

# Use group_by() and summarize() to find the mean, min, and max number of household members for each village, n=n()

# Open data for data visualization 

# load package tidyverse
library(tidyverse)

# open interviews_plotting.csv in folder data_output
interviews_plotting <- read_csv("data/interviews_plotting.csv")

# use ggplot function and bind the plot to a specific data frame, x=no_membrs, y=number_items

# add geom_point() to the plot, 

# change alpha to 0.5

# now use geom_jitter() instead of geom_point()

# use alpha = 0.2, width = 0.2, height = 0.2

# same but add color blue

# close
dev.off()
