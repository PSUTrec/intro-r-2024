library(dplyr)
library(ggplot2)
library(lubridate)

# read in files
stations <- read.csv("data/portal_stations.csv", stringsAsFactors = F)
detectors <- read.csv("data/portal_detectors.csv", stringsAsFactors = F)
data <- read.csv("data/agg_data.csv", stringsAsFactors = F)

# check the notation of the start_date, is it yyyy-mm-dd or mm-dd-yyyy, is there a time stamp too...
str(detectors)
head(detectors$start_date)

# convert class character to datetime using lubridate, and assign the appropriate timezone
detectors$start_date <- ymd_hms(detectors$start_date) |>
  with_tz("US/Pacific")
head(detectors$start_date)

# list of acceptable timezones
OlsonNames()

# convert detectors$end_date to date/time format
detectors$end_date <- ymd_hms(detectors$end_date) |>
  with_tz("US/Pacific")

# open detectors
open_det <- detectors |>
  filter(is.na(end_date))
# closed detectors
closed_det <- detectors |>
  filter(!is.na(end_date))

#### I want the total daily volume and average volume and average speed/station ####
data_stid <- data |>
  left_join(open_det, by = c("detector_id" = "detectorid")) |>
  select(detector_id, starttime, volume, speed, countreadings, stationid)

# convert starttime to datetime format
data_stid$starttime <- ymd_hms(data_stid$starttime) |>
  with_tz("US/Pacific")

# summarize data to get daily total and averages
daily_data <- data_stid |>
  mutate(date = floor_date(starttime, unit = "day")) |>
  group_by(stationid,
           date) |>
  summarise(
    daily_volume = sum(volume),
    daily_obs = sum(countreadings),
    mean_speed = mean(speed)
  ) |>
  as.data.frame() # remember that sometimes you need to force your manipulated data into a new df

# plot data to check it out
daily_volume_fig <- daily_data |>
  ggplot(aes(x = date, y = daily_volume)) +
  geom_line() +
  geom_point() +
  facet_grid(stationid ~ ., scales = "free")
daily_volume_fig # there is a data gap!

# sometimes you want to get specific information about a data point without looking at the table
library(plotly)
ggplotly(daily_volume_fig)

# how many unique stations are there in the data (using base R)
length(unique(daily_data$stationid))

# need the stationids to start building a dataframe for for expected observations
stids <- unique(daily_data$stationid)

# create the expected observations dataframe
start_date <- ymd("2023-03-01")
end_date <- ymd("2023-03-31")
date_df <- data.frame(
  date_seq = rep(seq(start_date, end_date, by = "1 day")),
  station_id = rep(stids, each = 31)
)

# use a join to be able to insert the missing expected data
data_with_gaps <- date_df |>
  left_join(daily_data, by = c("date_seq" = "date",
                               "station_id" = "stationid")
  )

# two ways of saving data
# write to a new csv file, but does not retain the data structure (e.g. class datetime)
write.csv(data_with_gaps, "data/data_with_gaps.csv", row.names = F)
# save the dataframe object as a rds data file to retain the data structure and also compresses size
saveRDS(data_with_gaps, "data/data_with_gaps.rds")

# use subset of data to check the data are visualized with the date gap
mod_date_fig <- data_with_gaps |>
  filter(station_id %in% c(1056, 1057, 1059)) |>
  ggplot(aes(x = date_seq, y = daily_volume)) +
  geom_line(aes(color = "blue")) +
  geom_point(aes(color = "skyblue")) +
  facet_grid(station_id ~ .)
mod_date_fig

mod_date_fig2 <- mod_date_fig +
  scale_x_date(date_breaks = "1 day") + # this throws error for as date class format
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
mod_date_fig2

# so many ggplot2 layers to add to continue playing with the layout
mod_date_fig <- data_with_gaps |>
  filter(station_id %in% c(1056, 1057, 1059)) |>
  ggplot(aes(x = as.Date(date_seq), y = daily_volume)) +
  geom_line() +
  geom_point() +
  facet_grid(station_id ~ .) +
  scale_x_date(date_breaks = "1 day") + # fixed to as.date
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_hline(yintercept = mean(daily_data$daily_volume))
mod_date_fig
