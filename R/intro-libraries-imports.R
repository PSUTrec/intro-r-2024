# Read in csv file using base R
sta_meta <- read.csv("data/portal_stations.csv", stringsAsFactors = F)

str(sta_meta) # structure of data

head(sta_meta) # first six rows of data
tail(sta_meta) # last six rows of data

nrow(sta_meta) # number of rows of data

summary(sta_meta) # summary of data, can get some information about NA

# Using Data Import shortcut to read in xlsx and copy/paste code
library(readxl)
icebreaker_answers <- read_excel("data/icebreaker_answers.xlsx")
View(icebreaker_answers)

library(dplyr)

odot_meta <- sta_meta |> # old pipe notation %>%
  filter(
    agency == "ODOT",
    highwayid == 1
    )

notodot_meta <- sta_meta |>
  filter(
    agency != "ODOT" 
  )

# looking for NAs
nas_meta <- sta_meta |>
  filter(
    is.na(detectorlocation)
  )

# excluding NAs
real_meta <- sta_meta |>
  filter(
    !is.na(detectorlocation)
  )

