library(tidyverse)

start_date = as.POSIXct("2020-01-01")
date_of_publish = as.POSIXct("2022-09-29")
remaining_budget = 400e9
co2_per_y = 42.2e9
co2_per_s = 1337

seconds_between_start_and_publish = difftime(date_of_publish, start_date, units="secs")
carbon_used_carbon_unitl_publish = co2_per_s * as.numeric(seconds_between_start_and_publish)


left_carbon_on_date_of_publish = remaining_budget - carbon_used_carbon_unitl_publish

time_left = left_carbon_on_date_of_publish / co2_per_y
years = floor(time_left)
days = 365 * (time_left %% floor(time_left))

