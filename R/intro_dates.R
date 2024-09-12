library(dplyr)
# library(tidyr)
library(ggplot2)
library(lubridate)

# Read in data
stations <- read.csv("data/portal_stations.csv", stringsAsFactors = F)
detectors <- read.csv("data/portal_detectors.csv", stringsAsFactors = F)
data <- read.csv("data/agg_data.csv", stringsAsFactors = F)

#### Get the total daily volume and average speed for each station ####

# look at the start_date format
head(detectors$start_date)

# use lubridate to convert to specific timestamp format
detectors$start_date <- ymd_hms(detectors$start_date) |>
  with_tz("US/Pacific")
head(detectors$start_date)

# convert stations$end_date to datetime format
detectors$end_date <- ymd_hms(detectors$end_date) |>
  with_tz("US/Pacific")

# filter open detectors (where the end_date is NA)
open_det <- detectors |>
  filter(!is.na(end_date))

# need to group detectors by stations
data_stid <- data |>
  left_join(detectors, by = c("detector_id" = "detectorid")) |>
  select(detector_id, starttime, volume, speed, countreadings, stationid)

data_stid$starttime <- ymd_hms(data_stid$starttime) |>
  with_tz("US/Pacific")

# aggregations!
daily_data <- data_stid |>
  mutate(date = floor_date(starttime, unit = "day")) |>
  group_by(stationid, date) |>
  summarize(
    daily_volume = sum(volume),
    daily_obs = sum(countreadings),
    mean_speed = mean(speed),
    mean_daily_volume = mean(volume)
  ) |>
  as.data.frame()
# point out sometimes need to be explicit about as.data.frame()

# let's visualize this
daily_volume_fig <- daily_data |>
  ggplot(aes(x = date, y = daily_volume)) +
  geom_line() +
  geom_point() +
  facet_grid(stationid ~ ., scales = "free")
daily_volume_fig

# a little bit of digging
select_vol_fig <- daily_data |>
  filter(stationid %in% c(1056, 1057, 1059)) |>
  ggplot(aes(x = date, y = daily_volume)) +
  geom_line() +
  geom_point() +
  facet_grid(stationid ~ ., scales = "free")
select_vol_fig

# a little bit more digging with help using plotly
library(plotly)
ggplotly(select_vol_fig)

# the daily data gaps
# There is no great way or one size fits all, but if you find it let me know!
dist_stid <- unique(daily_data$stationid)

start_date <- ymd("2023-03-01")
end_date <- ymd("2023-03-31")
data_gap <- data.frame(
  timestamp_seq = rep(seq(start_date, end_date, by = "1 day")),
  station_id = rep(dist_stid, each = 31)
)

looking_gaps <- data_gap |>
  left_join(daily_data, by = c("timestamp_seq" = "date",
                             "station_id" = "stationid"))

# saveRDS(looking_gaps, "data/looking_volumes.rds")
# write.csv(looking_gaps, "data/looking_volumes.csv", row.names = F)

mod_date_fig <- looking_gaps |>
  filter(station_id %in% c(1056, 1057, 1059)) |>
  ggplot(aes(x = timestamp_seq, y = daily_volume)) +
  geom_line(aes(color = "blue")) +
  geom_point(aes(color = "skyblue")) +
  facet_grid(station_id ~ .)
mod_date_fig

mod_date_fig2 <- mod_date_fig +
  scale_x_date(date_breaks = "1 day") + # this throws error for as date class format
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

mod_date_fig <- looking_gaps |>
  filter(station_id %in% c(1056, 1057, 1059)) |>
  ggplot(aes(x = as.Date(timestamp_seq), y = daily_volume)) +
  geom_line() +
  geom_point() +
  facet_grid(station_id ~ .)

mod_date_fig2 <- mod_date_fig +
  scale_x_date(date_breaks = "1 day") + # fixed to as.date
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
mod_date_fig2

mod_date_fig3 <- mod_date_fig2 +
  xlab("Date") +
  ylab("Total Daily Volume") +
  geom_hline(yintercept = mean(daily_data$daily_volume), col = "red")
mod_date_fig3

library(padr)
mod_df <- pad(daily_data)
mod_data <- pad(data_detectors)

df$stid <- daily_data |>
  distinct(stationid)

# factors, numeric, characters
speed_vol_data <- data_stid |>
  filter(
    stationid == 3128,
    starttime >= "2023-03-01 00:00:00" &starttime <= "2023-03-07 23:59:59"
         ) |>
  ggplot(aes(x = starttime, y = speed, color = as.factor(detector_id))) +
  geom_line()
speed_vol_data

# categories!
speed_vol_data <- data_stid |>
  filter(
    stationid == 3128,
    starttime >= "2023-03-01 00:00:00" &starttime <= "2023-03-07 23:59:59"
  ) |>
  ggplot(aes(x = starttime, y = speed, color = as.factor(detector_id))) +
  geom_line()
speed_vol_data


# if you didn't have a timezone designation in your original file "... 00:00:00-07" use force_tz

head(timestamp_seq)
timestamp_seq <- force_tz(timestame_seq, tz = "US/Pacific")
head(timestame_seq)
