library(tidyverse)
library(lubridate)

# path --------------------------------------------------------------------
url = "https://energy.abteil.org/data/gas/consumption/data-aggm.csv"


# read data ---------------------------------------------------------------
data = read_csv(url)


# clean -------------------------------------------------------------------
data %>%
  filter(
    variable == "rm7"
  ) %>%
  select(
    -date20,
    -date,
    -variable
  ) %>%
  pivot_wider(
    names_from = year,
    values_from = value
  )


