# alternative to the ACS Census API

library(tidycensus)
#library(tidyverse)
library(dplyr)
library(tidyr)
library(ggplot2)

##### Run on first use if your API key not already stored in R ####
?census_api_key
census_api_key("myCensusAPIKey", install=T)
readRenviron("~/.Renviron")
#####

# for documenting functions within code use the docstring package!
tidy_acs_result <- function(raw_result, include_moe=F) {
  #takes a tidycensus ACS result and returns a wide 'n tidy data tibble
  if (isTRUE(include_moe)) {
    new_df <- raw_result |> pivot_wider(id_cols = GEOID:NAME, 
                                        names_from = variable, 
                                        values_from = estimate:moe) 
  } else {
    new_df <- raw_result |> pivot_wider(id_cols = GEOID:NAME, 
                                        names_from = variable, 
                                        values_from = estimate) 
  }
  return(new_df)
}

# get a searchable census variable data frame
v19 <- load_variables(2019, "acs1", cache = TRUE)
v19 |> filter(
  grepl("^B08006_", name)
) %>% print(n=100)

# get the data for transit and total commuters
comm_19_raw <- get_acs(geography = "tract", 
                  variables = c(wfh = "B08006_017", 
                                transit = "B08006_008", 
                                tot = "B08006_001"), 
                  county = "Multnomah",
                  state = "OR", 
                  year = 2019, 
                  survey = "acs5", 
                  geometry = F)
comm_19_raw
#comm_19 <- comm_19 |> pivot_wider(id_cols = GEOID:NAME, names_from = variable, 
#                                  values_from = estimate:moe)
comm_19 <- tidy_acs_result(comm_19_raw)
comm_19

comm_22_raw <- get_acs(geography = "tract", 
                       variables = c(wfh = "B08006_017", 
                                     transit = "B08006_008", 
                                     tot = "B08006_001"), 
                       county = "Multnomah",
                       state = "OR", 
                       year = 2022, 
                       survey = "acs5", 
                       geometry = F)
comm_22_raw
comm_22 <- tidy_acs_result(comm_22_raw)
comm_22

# join 'em
comm_19
comm_22
comm_22 %>% anti_join(comm_19, by = "GEOID")

comm_19_22 <- comm_19 %>% inner_join(comm_22, by = "GEOID", 
                                     suffix = c("_19", "_22")) %>% 
  select(-starts_with("NAME_"))
comm_19_22

# diff 'em
comm_19_22 <- comm_19_22 %>% 
  mutate(wfh_chg = wfh_22 - wfh_19, 
         transit_chg = transit_22 - transit_19)
summary(comm_19_22 %>% select(ends_with("_chg")))

# plot 'em
p <- comm_19_22 %>%
  ggplot(aes(x = wfh_chg, y = transit_chg))
p + geom_point() + geom_smooth(method = "lm")

cor(comm_19_22$transit_chg, comm_19_22$wfh_chg)

# model 'em
m <- lm(transit_chg ~ wfh_chg, data=comm_19_22)
summary(m)
plot(m)

# m as an object
policy_scenario_1 <- comm_19_22 %>% 
  mutate(wfh_22 = 1.5 * wfh_22, 
         wfh_chg = wfh_22 - wfh_19)
summary(comm_19_22)
summary(policy_scenario_1)

policy_scenario_1 <- policy_scenario_1 %>% 
  mutate(transit_chg_ps1 = predict(m, newdata=policy_scenario_1))

policy_scenario_1 %>% summarize(tot_transit_chg = sum(transit_chg_ps1), 
                               tot_wfh_chg = sum(wfh_chg))
comm_19_22 %>% summarize(tot_transit_chg = sum(transit_chg), 
                         tot_wfh_chg = sum(wfh_chg))

m_updated <- update(m, data=comm_19_22)
summary(m_updated)
