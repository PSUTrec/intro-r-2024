library(tidyr)
library(dplyr)
library(xml2)
library(readr)


#### Stations metadata from WSDOT feed (locations) ####
meta_xml <- as_list(read_xml("https://wsdot.com/Traffic/WebServices/SWRegion/Service.asmx/GetRTDBLocationData"))

meta_df <- as_tibble(meta_xml) %>%
  unnest_longer(RTDBLocationList)

meta_unnest_df <- meta_df %>%
  filter(RTDBLocationList_id == "RTDBLocation") %>%
  unnest_wider(RTDBLocationList)
meta_unnest_more <- meta_unnest_df %>%
  unnest(cols = names(.)) %>%
  unnest(cols = names(.)) %>%
  type_convert()

wsdot_a_meta <- meta_unnest_more %>%
  filter(!grepl("ORE", name))

saveRDS(wsdot_a_meta, "data/wsdot_api_meta_202405.rds")