#### Aggregating and Summarizing Data ####

# Load packages ----
library(readxl)
library(dplyr)
library(ggplot2)

# Read in the excel file ----
df <- read_excel("Data/icebreaker_answers.xlsx")
df
summary(df)

# custom summaries of an entire data frame by column  ----
df |> summarise(
  avg_dist = mean(travel_distance), 
  sd_dist = sd(travel_distance),
  pct60_dist = quantile(travel_distance, prob = 0.6), 
  avg_time = mean(travel_time)
)
?summarize

# an aside, if you want an integer, must specify
df %>% mutate(travel_time = as.integer(travel_time))

# assign the summary if you want to save
#   View() may show more precision
df_summ <- df |> summarize(
  avg_dist = mean(travel_distance), 
  sd_dist = sd(travel_distance),
  pct60_dist = quantile(travel_distance, prob = 0.6), 
  avg_time = mean(travel_time)
)
# View(df_summ) # same as clicking df_summ in Environment window

# Aggregating and summarizing subsets ----
#   of a data frame 
df <- df |> 
  mutate(travel_speed = travel_distance / travel_time * 60)

df |> 
  summarize(avg_speed = mean(travel_speed))

# average speed by mode
df |> group_by(travel_mode) |> 
  summarize(avg_speed = mean(travel_speed))

# sort by avg_speed
df |> group_by(travel_mode) |> 
  summarize(avg_speed = mean(travel_speed)) |> 
  arrange(desc(avg_speed))

# grouped data frame
df_mode_grp <- df |> group_by(travel_mode)
str(df_mode_grp)

# grouping by multiple variables
#   by default, summarize will leave data grouped by next higgher level
df_mode_comma_grp <- df |> group_by(travel_mode, serial_comma) |> 
  summarize(avg_speed = mean(travel_speed)) 

df |> group_by(travel_mode, serial_comma) |> 
  summarize(avg_speed = mean(travel_speed)) |> 
  summarize(mean_avg_speed = mean(avg_speed))

# have to explicitly ungroup()
df_mode_comma_ungrp <- df |> group_by(travel_mode, serial_comma) |> 
  summarize(avg_speed = mean(travel_speed)) |> 
  ungroup()
df_mode_comma_ungrp

# frequencies ----
#   so common there are shortcuts
df |> group_by(serial_comma) |> 
  summarize(n = n())

# replaces the summarize function and assigns to n
df |> group_by(serial_comma) |> 
  tally()

# replaces group_by AND summarize and assigns to n
df |> count(serial_comma)  
# can arrange this also 
df |> count(serial_comma, sort=T)  # where T is for TRUE

# using intermediate results ----
#   calculate a mode split (percentage using each travel mode)
df |> count(travel_mode)

df |> group_by(travel_mode) |> 
  summarize(split = n() / nrow(df) * 100) |>
  arrange(desc(split))
