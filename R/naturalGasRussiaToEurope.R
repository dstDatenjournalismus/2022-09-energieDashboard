library(tidyverse)
library(glue)
library(readxl)
library(here)

# url ---------------------------------------------------------------------
url = "https://www.bruegel.org/sites/default/files/2022-09/gas_tracker_update_.zip"


# download zip ------------------------------------------------------------
download_path = tempfile()
download_dir = dirname(download_path)



download.file(url, download_path, headers = c("User-Agent" = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:104.0) Gecko/20100101 Firefox/104.0"))

# unzip data --------------------------------------------------------------
unzip(download_path, exdir = download_dir)

# load data ---------------------------------------------------------------

# find file
files = dir(download_dir, "*.csv|xlsx")
file_idx = which(grepl("country_data", files))

# read data
data = read_csv(files[[file_idx]])

# transform data ----------------------------------------------------------
data %>%
  select(
    week,
    matches("Russia_*")
  ) %>%
  mutate(
    `EU Ziel` = (1/3) * Russia_2021,
  )  %>%
  rename(
    `Durchschnitt 2015 - 2022` = Russia_avg,
    `2022` = Russia_2022
  ) -> data


# write out ---------------------------------------------------------------
output_file = here("output/natural_gas_russia_europe.csv")
write_file(data, output_file)












