# Zeit's data
# https://datawrapper.dwcdn.net/XteIv/65/dataset.csv

library(tidyverse)
library(here)
library(glue)


# paths --------------------------------------------------------------------
path_data = here("data/gas_flow_russia_europe/country_data_2022-08-30.csv")


# data --------------------------------------------------------------------
data = read_csv(path_data)


# wrange data -------------------------------------------------------------
data %>%
  select(
    week,
    matches("Russia")
  ) %>%
  filter(
    !is.na(
      Russia_2021
    )
  )-> formattedData



# write out ---------------------------------------------------------------
inFile_basename = basename(path_data)
outFile = here(glue("output/natural_gas_russia_europe/{inFile_basename}"))
outDir = dirname(outFile)
if(!dir.exists(outDir)) dir.create(outDir, recursive = T)

write_csv(formattedData, outFile)

