#### Practice Problem: Loading and manipulating a data frame ####
# Load the readxl and dplyr packages
library(readxl)  # from the tidyverse, for reading Excel files
library(dplyr)  # for filtering data

# Use the read_excel function to load the class survey data
icebreaker <- read_excel("data/icebreaker_answers.xlsx")
# Take a peek!
icebreaker
head(icebreaker)
tail(icebreaker)

# Create a travel_speed column in your data frame using vector operations and 
#   assignment
icebreaker$travel_speed <- (icebreaker$travel_distance / 
                              icebreaker$travel_time * 60)  # speed in miles per hour
icebreaker
# Look at a summary of the new variable--seem reasonable?
summary(icebreaker)
boxplot(icebreaker$travel_speed ~ icebreaker$travel_mode)  # quick boxplots!
hist(icebreaker$travel_speed)  # quick historgrams!

# Choose a travel mode, and use a pipe to filter the data by your travel mode
icebreaker |> filter(travel_mode == "light rail")

# Repeat the above, but this time assign the result to a new data frame
ice_lrt <- icebreaker |> filter(travel_mode == "light rail")
ice_lrt
# Look at a summary of the speed variable for just your travel mode--seem 
#   reasonable?
summary(ice_lrt)

# Filter the data by some arbitrary time, distance, or speed threshold
icebreaker |> filter(travel_speed > 20 & travel_speed < 50)

# Stretch yourself: Repeat the above, but this time filter the data by two 
#   travel modes (Hint: %in%)
icebreaker |> filter(travel_mode %in% c("bike", "bus"))

icebreaker |> filter(travel_mode == "bike" | travel_mode == "bus")