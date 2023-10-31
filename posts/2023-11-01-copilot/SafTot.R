# First day ------------------------------------------------------------

# use tidyverse package and readr package
library(tidyverse)
library(readr)

# Open SAFI_openrefine.csv in file data, call it SAFI_openrefine, use read_csv 
SAFI_openrefine <- read_csv("data/SAFI_openrefine.csv")

# View(SAFI_openrefine), not used here

# change order of variables
SAFI_openrefine <- SAFI_openrefine[,c("village","ward","district","province","interview_date","quest_no","start","end","items_owned","months_lack_food","months_no_water","liv_owned","res_change","no_food_mitigation","respondent_roof_type", "respondent_wall_type", "respondent_roof_type", "gps_Altitude", "gps_Latitude", "gps_Longitude", "years_farm", "no_membrs", "years_liv", "rooms")]

#Let us research a specific variable.
#show groups village
SAFI_openrefine$village

# We have to make this variable more consistent.
# change names of groups in village
# 49 will become Chirodzo, Chirdoze will become Chirodzo, Ruaca-Nhamuenda and Ruca wwill become Ruaca
library(tidyverse)
SAFI_openrefine$village <- recode(SAFI_openrefine$village, "49" = "Chirodzo", "Chirdoze" = "Chirodzo", "Chirdozo" = "Chirodzo", "Ruaca-Nhamuenda" = "Ruaca", "Ruaca - Nhamuenda" = "Ruaca", "Ruca" = "Ruaca")

# How does it look now?
#show groups village
SAFI_openrefine$village

# count village values are there in the survey results data?
table(SAFI_openrefine$village)

# count interview_date values are there in the survey results data?  
table(SAFI_openrefine$interview_date)

# Look at variable `interview_date`. It is formatted as text. We have to change this to a date format.
# Is variable interview_date formatted as Text or Date? (ChatGPT)
my_variable<-"17-Nov-16" 

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
SAFI_openrefine$interview_date <- dmy(SAFI_openrefine$interview_date)

# R count different dates of variable interview_data 
table(SAFI_openrefine$interview_date)

## Transforming data
# remove left bracket from items_owned
SAFI_openrefine$items_owned <- str_replace(SAFI_openrefine$items_owned, "\\[", "")

#remove right bracket from items_owned
SAFI_openrefine$items_owned <- str_replace(SAFI_openrefine$items_owned, "\\]", "")

# remove all ' from items_owned
SAFI_openrefine$items_owned <- str_replace_all(SAFI_openrefine$items_owned, "'", "")

#remove white spaces from cells of items_owned
SAFI_openrefine$items_owned <- str_trim(SAFI_openrefine$items_owned)

# remove all ; from items_owned
SAFI_openrefine$items_owned <- str_replace_all(SAFI_openrefine$items_owned, ";", "")

# items_owned count and add the objects
items_owned_count <- table(SAFI_openrefine$items_owned)

# add the objects of items_owned_count
items_owned_count <- sort(items_owned_count, decreasing = TRUE)

# print the objects of items_owned_count
items_owned_count

# how many radio do we have over 131 rows?
items_owned_count["radio"]

# Filtering
table(SAFI_openrefine$respondent_roof_type)

# 2. Some analysis
# For the second part I did some Explorative Data Analysis using `tidyverse` package of R?RStudio and copilot. I used a clean dataset and followed Data Carpentry:R for Social Scientists. See [Data Carpentry:R for Social Scientists](https://kelseygonzalez.github.io/2020-01-15-brynmawr-lessons/intro.html), especially chapter 6 *Data wrangling with dplyr* and chapter 8 *Data visualization with ggplot2*.

library(tidyverse)
library(readr)
if (!dir.exists("data"))
  dir.create("data")

if (! file.exists("data/SAFI_clean.csv")) {
  download.file("https://ndownloader.figshare.com/files/11492171",
                "data/SAFI_clean.csv", mode = "wb")
}

# open SAFI_clean.csv and save it as safi
safi <- read_csv("data/SAFI_clean.csv")
safi

# show the first 10 rows of safi
glimpse(safi)

# Explorative Data Analysis using `dplyr`
# selecting
# The code `select()` we use to select columns
# For example

#select interview_date, village, no_membrs, years_liv
select(safi, interview_date, village, no_membrs, years_liv)


# filtering
# You can also choose rows based on their values using `filter()`
# filter for rows where village is "God"
filter(safi, village == "God")

# pipes
# The pipe operator `%>%` is used to chain together multiple `dplyr` functions (for example selecting and filtering. You can also use `|>` instead of `%>%` if you prefer.
                                                                            
# filter village=God and select no_membrs and years_liv
safi %>% 
filter(village == "God") %>% 
select(no_membrs, years_liv)

# mutating
# We use `mutate()` to create new columns
# ratio of number of household members to number of rooms
safi %>% 
mutate(ratio = no_membrs / rooms)
                                                                              
# Let us research whether a member of an irrigation association had any effect on the ratio of household members to rooms. 
# To look at this relationship, we remove data from our dataset where the respondent didn't answer the question of whether they were 
# a memnber of an irrigation association (recorded als "NULL" in the dataset)
# to remove these cases, we could use filter() to remove and people per room is ratio of number of household members to number of rooms 
safinew<-safi %>% 
  filter(!is.na(memb_assoc)) %>%
  mutate(people_per_room = no_membrs / rooms)
safinew

# summarizing
# `group_by()` is used to group the data by a variable and often used together with `summarize`. `summarize()` is used to calculate summary statistics for each group. 
# to compute the average number of household size for each village
safi %>% 
  group_by(village) %>% 
  summarize(mean_no_membrs = mean(no_membrs))

# group by multiple columns (village, memb_assoc) and calculate the mean number of household members
safi %>% 
  group_by(village, memb_assoc) %>% 
  summarize(mean_no_membrs = mean(no_membrs))

# Once the data are groupes, you can also summarize multiple variables at once (and not necessary on the same variable)
# we could  add a column indicating the minimum household size for each village for each group (member of irrigation association or not) and take out if memb_assoc is missing.
safi %>% 
  filter(!is.na(memb_assoc)) %>%
  group_by(village, memb_assoc) %>% 
  summarize(mean_no_membrs = mean(no_membrs),
            min_no_membrs = min(no_membrs))

# counting
# `count()` is used to count the number of observations in each group, for each factor or comination of factors
# count village
safi %>% 
  count(village)

# count village in decreasing order
safi %>% 
  count(village, sort = TRUE)

# Data visualization
# Building plots with `ggplot2` involves three steps:
# - step 1: use `ggplot()` to specify the dataset and variables to be plotted
# - step 2: add on layers to specify the type of plot (points, lines, bars, etc.)
# - step 3: (optionally) add on themes, faceting specifications, and other details to make the plot more informative and interpretable

# Building plots with ggplot2 is an iterative process. You may need to try out several different combinations of variables and layers before you get the plot you want.
# plot no_membrs vs. rooms 
ggplot(data = safi) +
  geom_point(mapping = aes(x = no_membrs, y = rooms))


# use bit of randomness in position to avoid overplotting, alpha 0.5
ggplot(data = safi) +
  geom_point(mapping = aes(x = no_membrs, y = rooms), position = "jitter", alpha = 0.5)


# same plot but use color blue
ggplot(data = safi) +
  geom_point(mapping = aes(x = no_membrs, y = rooms), position = "jitter", alpha = 0.5, color = "blue")


# same plot but use color=village
ggplot(data = safi) +
  geom_point(mapping = aes(x = no_membrs, y = rooms, color = village), position = "jitter", alpha = 0.5)


# same plot but add title and subtitle
ggplot(data = safi) +
  geom_point(mapping = aes(x = no_membrs, y = rooms, color = village), position = "jitter", alpha = 0.5) +
  labs(title = "Number of household members vs. number of rooms",
       subtitle = "Data from SAFI")

# `ggplot` has a special technique called faceting that allows you to split one plot into multiple plots based on a factor included in the dataset. 

# plot bar x=reSpondent_wall_type facet=village
ggplot(data = safi) +
  geom_bar(mapping = aes(x = respondent_wall_type)) +
  facet_wrap(~ village)

# same plot but theme_bw()
ggplot(data = safi) +
  geom_bar(mapping = aes(x = respondent_wall_type)) +
  facet_wrap(~ village) +
  theme_bw()


# Second day ------------------------------------------------------------------
# Before we start

download.file(
  "https://raw.githubusercontent.com/datacarpentry/r-socialsci/main/episodes/data/SAFI_clean.csv",
  "data/SAFI_clean.csv", mode = "wb"
)

# Introduction to R 
area_hectares <- 50                 # land area in hectares
area_acres <- 2.47 * area_hectares  # convert to acres
area_acres                          # print the result

# create two variables r_length en r_width and assign values to them
r_length <- 5
r_width <- 3

# create a third value based on the first two
r_area <- r_length * r_width
r_area

# changing r_length and r_width does not affect the value of r_area
r_length <- 10
r_width <- 2
r_area

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
hh_members

respondent_wall_type <- c("muddaub", "burntbricks", "sunbricks")
respondent_wall_type

length(hh_members)
length(respondent_wall_type)

# type of object
typeof(hh_members)
typeof(respondent_wall_type)

#structure of object
str(hh_members)
str(respondent_wall_type)

# adding elements
possessions <- c("bicycle", "radio", "television")

# add to end of object mobile phone
possessions <- c(possessions, "mobile phone")

# add car at the beginning of the object
possessions <- c("car", possessions)
possessions

# some asked: put it in alphabetical order
sort(possessions)

# back to old order
sort(possessions, decreasing = TRUE)
possessions

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
respondent_wall_type[2]

# subset elements 3 and 2
respondent_wall_type[c(3, 2)]

# assign new value to second element of respondent_wall_type 1, 2, 3, 2, 1, 3
more_respondent_wall_type <- respondent_wall_type[c(1, 2, 3, 2, 1, 3)]
more_respondent_wall_type

# conditional subsetting, first true, second false, third true, fourth tru
hh_members[c(TRUE, FALSE, TRUE, TRUE)]

# hh_members only greater than 5
hh_members[hh_members > 5]

# hh_members only smaller than four or  greater than 7
hh_members[hh_members < 4 | hh_members > 7]

# hh_members only greater or equal than four and smaller or equal than 7
hh_members[hh_members >= 4 & hh_members <= 7]

# possesions and equal to car
possessions[possessions == "car"]

# possesions and equal to car and bicycle
possessions[possessions == "car" | possessions == "bicycle"]

# possessions and all elements are either car or bicycle
possessions[possessions %in% c("car", "bicycle")]

# possesions check if elements are either car, bicycle, truck, boat, bus
possessions[possessions %in% c("car", "bicycle", "truck", "boat", "bus")]

# Missing data
rooms <- c(2, 1, 1, NA, 7)

# mean rooms
mean(rooms)

# max rooms
max(rooms)

# mean rooms without NA
mean(rooms, na.rm = TRUE)

# max rooms without NA
max(rooms, na.rm = TRUE)

# extract those eleeemnts that are not NA
rooms[!is.na(rooms)]

# count number of elements that are not NA
sum(!is.na(rooms))

# count number of elements that are NA
sum(is.na(rooms))

# return object with incomplete cases removed
rooms[complete.cases(rooms)]

# create vector rooms
rooms <- c(1, 2, 1, 1, NA, 3, 1, 3, 2, 1, 1, 8, 3, 1, NA, 1)

# remove NA's from rooms and make new object called rooms_no_na
rooms_no_na <- rooms[!is.na(rooms)]

# median rooms_no_na
median(rooms_no_na)

# calculate median rooms without NA's
#median(rooms, na.rm = TRUE)
rooms_above_2 <- rooms_no_na[rooms_no_na > 2]
length(rooms_above_2)

# how many households have more than 2 rooms for sleeping
sum(rooms_no_na > 2) 


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
interviews

# View interviews
# View(interviews) # do it in the console
# show first rows
head(interviews)

# show first 10 rows
interviews[1:10, ]

# what kind of object is interviews
class(interviews)

# 2. INSPECTING DATA FRAMES 
# number of rows as the first element and number of columns as the second element
dim(interviews)

# number of rows
nrow(interviews)

# number of columns
ncol(interviews)

# show first 6 rows
head(interviews)

# show last 6 rows
tail(interviews)

# return column names
names(interviews)

# structure of interviews and information about class, length and content
str(interviews)

# summary statistics of each column
summary(interviews)

# number of columsn and rows of the tibble, the names and class of each column, preview  
glimpse(interviews)

# 3. SUBSETTING DATA FRAMES 
#  first element in the first column of the tibble
interviews[1, 1]

# first element in the 6th column of the tibble
interviews[1, 6]

# first column of the tibble (as a vector)
interviews[, 1]

#interviews[[1]] # same result

# first three elements in the 7th column of the tibble
interviews[1:3, 7]

# the 3rd row of the tibble
interviews[3, ]

# all columns except the 1st column of the tibble
interviews[, -1]

# interviews and exclude 7:131
interviews[-7:-131, ]

# equivalent to head_interviews<-head(interviews)
head_interviews <- interviews[1:6, ]

# the whole tibble except the first column
interviews[, -1]

# look for vector no_meals
interviews$no_meals

# Excercise 
# 1. Create a tibble (interviews_100) containing only the data in row 100 of the interviews dataset.
interviews_100 <- interviews[100, ]

# 2. Continue using interviews for each of the following activities
# Notice how `nrow()` gave you the number of rows in the tibble
n_rows<-nrow(interviews)

# Use that number 131 to pull out just that last row in the tibble.
interviews[131, ]

# compare the with what you see als the last row using `tail()`
tail(interviews)

# pull out that last row using nrow() instead of the row number
# create a new tibble (interviews_last) for that last row
interviews_last <- interviews[n_rows, ]

# 3. Using the number of rows in the interviews dataset that you found in question 2, 
# extract the row that is in the middle of the dataset. 
#Store the content of this middle row in an object named interviews_middle. 
# (hint: This dataset has an odd number of rows, so finding the middle is a 
# bit trickier than dividing n_rows by 2. Use the median( ) 
# function and what you’ve learned about sequences in R to extract the middle row!
interviews_middle <- interviews[median(1:n_rows), ]

# 4. Combine nrow() with the - (exclude) notation above to reproduce the behavior of head(interviews), 
# keeping just the first through 6th rows of the interviews dataset.Call it interviews_head.
#interviews_head <- interviews[1:6, ]
interviews_head <- interviews[-7:-131, ]

# 4. Factors 
respondent_floor_type <- factor(c("earth", "cement", "cement", "earth"))
respondent_floor_type

# ask levels
levels(respondent_floor_type)

# number of levels
nlevels(respondent_floor_type)

# current order of variablw respondent_floor_type
respondent_floor_type

# change order of levels
respondent_floor_type <- factor(respondent_floor_type, levels = c("earth", "cement"))

# after reordering
respondent_floor_type

# see levels now
levels(respondent_floor_type)

# other variable respondent_floor_type, factor recode, fct_recode, brick replace cement
respondent_floor_type <- factor(c("earth", "cement", "cement", "earth"))
respondent_floor_type
# brick = cement, recode factor
respondent_floor_type <- fct_recode(respondent_floor_type, brick = "cement")
respondent_floor_type

# order factor respondent_floor_type as respondent_floor_type_ordered, ordered = TRUE
respondent_floor_type_ordered <- factor(respondent_floor_type, ordered = TRUE)
# after setting as ordered factor
respondent_floor_type_ordered

# 5. Convert factors to characters 
# convert factor respondent_floor_type as a character vector
as.character(respondent_floor_type)

# new factor
year_fct <- factor(c(1990, 1983, 1977, 1998, 1990))
as.numeric(year_fct) # wrong, and no warning

# make it work
as.numeric(as.character(year_fct))
year_fct

# renaming factors
# create a vector from the data frame column "memb_assoc"
memb_assoc <- interviews$memb_assoc

# convert to factor
memb_assoc <- factor(memb_assoc)

# how does it look
memb_assoc

# bar plot of the number of interviews who were members of irrigation associstions and who were not
barplot(table(memb_assoc))


# Let us recreate the vector from the data frame column "memb_assoc"
memb_assoc <- interviews$memb_assoc

# replace the missing data with "undertermined"
memb_assoc[is.na(memb_assoc)] <- "undetermined"

# convert to factor
memb_assoc <- factor(memb_assoc)

# Let's see what ik looks like
memb_assoc

# bar plot of the number of interviews who were members of irrigation associstions and who were not
barplot(table(memb_assoc))

# Excercise
# rename the levels of the factor to have the first letter in uppercase: "No", "Undetermined", "Yes"
# use fct_recode()
memb_assoc <- fct_recode(memb_assoc, No = "no", Undetermined = "undetermined", Yes = "yes")

# Recreate the bar plot such that "Undertermined is last(after "Yes")
# reorder levels. Use the new levels names
memb_assoc <- factor(memb_assoc, levels = c("No", "Yes", "Undetermined"))
barplot(table(memb_assoc))


# 6. Formatting dates 
str(interviews)

# load package lubridate
library(lubridate)

# Extract our interview_date column  call it dates
dates <- interviews$interview_date

# inspect structure of dates
str(dates)

# use the day() call it interviews$day
interviews$day <- day(dates)

# use the month() call it interviews$month
interviews$month <- month(dates)

# use the year() call it interviews$year
interviews$year <- year(dates)

# look at interviews
interviews

# we have a vector of dates in character format, call it char_dates
char_dates <- c("7/31/2012", "8/9/2014", "4/30/2016")

# what is structure of char_dates
str(char_dates)

# convert it to format %m/%d/%Y, as_date()
as_date(char_dates, format = "%m/%d/%Y")
char_dates
mdy(char_dates)

# convert it to format %d%m/%Y, as_date()
# doesn't work yet (Harrie)
as_date(char_dates, format = "%d%m/%Y")
char_dates
dmy(char_dates)

# 7. Data wrangling with dplyr 
# load package dplyr
library(dplyr)

# selecting columns and filtering rows
# select columns village, no_membrs, months_lack_food from interviews
select(interviews, village, no_membrs, months_lack_food)

# same with subsetting
interviews[, c("village", "no_membrs", "months_lack_food")]

# select a series of connected columns, village to respondent_wall_type
select(interviews, village:respondent_wall_type)

# filter observations with village name is Chirodzo
filter(interviews, village == "Chirodzo")

# filter observations with "and" operator (comma)
# output dataframe satisfies ALL specified conditions, village = Chirodzo, rooms > 1, no_meals >2
filter(interviews, village == "Chirodzo", rooms > 1, no_meals > 2)

# filters observations with "&" logical operator
# output datafraem satisfies All specified conditions, village = Chirodzo, rooms > 1, no_meals >2
filter(interviews, village == "Chirodzo" & rooms > 1 & no_meals > 2)

# filters observations with "|" logical operator
# output dataframe satisfies AT LEAST ONE of the specified conditions, village = Chirodzo, rooms or village == Ruaca
filter(interviews, village == "Chirodzo" | village == "Ruaca")

# Pipes
# call it interviews_ch and select en filter village = Chirodzo and village till respondent_wall_type
interviews_ch <- interviews %>% filter(village == "Chirodzo") %>% select(village:respondent_wall_type)

# use new pipe symboul |>
interviews_ch <- interviews |> filter(village == "Chirodzo") |> select(village:respondent_wall_type)

# Excercise
# using pipes, subset interviews and include respondents were members of an irrigation association
# and retain only the columns affect_conflicts, liv_count, no_meals
interviews %>% filter(memb_assoc == "yes") %>% select(affect_conflicts, liv_count, no_meals)

# mutate
# make new variabele which is called people_per_room and it is no_membrs devided by rooms
interviews <- interviews %>% mutate(people_per_room = no_membrs / rooms)

# interviews with filter out missing memb_assoc and use people_per_room and it is no_membrs devided by rooms
interviews <- interviews %>% filter(!is.na(memb_assoc)) %>% mutate(people_per_room = no_membrs / rooms)

# Excercise
# create new dataframe from the interviews that meets the following conditions:xxx

## Split-apply-combine data analysis and the summarize verb
# interviews data, for each type of village (use village column), calculate the mean number of household members
interviews %>% group_by(village) %>% summarize(mean_no_membrs = mean(no_membrs))

# Obtain an ungrouped tibble
interviews %>% group_by(village) %>% summarize(mean_no_membrs = mean(no_membrs)) %>% ungroup()

# mean_no_members from low to high
interviews %>% group_by(village) %>% summarize(mean_no_membrs = mean(no_membrs)) %>% ungroup() %>% arrange(mean_no_membrs)

# now from high to low
interviews %>% group_by(village) %>% summarize(mean_no_membrs = mean(no_membrs)) %>% ungroup() %>% arrange(desc(mean_no_membrs))

# count village, please sort from high to low
interviews %>% group_by(village) %>% count() %>% ungroup() %>% arrange(desc(n))

# count village, sort from low to high
interviews %>% group_by(village) %>% count() %>% ungroup() %>% arrange(n)

# Excercise
# How many households have an average of two meals per day overall
interviews %>% summarize(mean_no_meals = mean(no_meals)) %>% filter(mean_no_meals == 2)

# Use group_by() and summarize() to find the mean, min, and max number of household members for each village, n=n()
interviews %>% group_by(village) %>% summarize(mean_no_membrs = mean(no_membrs), min_no_membrs = min(no_membrs), max_no_membrs = max(no_membrs), n = n())

# Open data for data visualization 

# load package tidyverse
library(tidyverse)

# open interviews_plotting.csv in folder data_output
interviews_plotting <- read_csv("data/interviews_plotting.csv")

# use ggplot function and bind the plot to a specific data frame, x=no_membrs, y=number_items
ggplot(data = interviews_plotting, aes(x = no_membrs, y = number_items)) 

# add geom_point() to the plot, 
ggplot(data = interviews_plotting, aes(x = no_membrs, y = number_items)) + geom_point()

# change alpha to 0.5
ggplot(data = interviews_plotting, aes(x = no_membrs, y = number_items)) + geom_point(alpha = 0.5)

# now use geom_jitter() instead of geom_point()
ggplot(data = interviews_plotting, aes(x = no_membrs, y = number_items)) + geom_jitter(alpha = 0.5)

# use alpha = 0.2, width = 0.2, height = 0.2
ggplot(data = interviews_plotting, aes(x = no_membrs, y = number_items)) + geom_jitter(alpha = 0.2, width = 0.2, height = 0.2)

# same but add color blue
ggplot(data = interviews_plotting, aes(x = no_membrs, y = number_items)) + geom_jitter(alpha = 0.2, width = 0.2, height = 0.2, color = "blue")

# close
dev.off()
