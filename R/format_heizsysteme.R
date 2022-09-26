library(here)
library(tidyverse)

# path --------------------------------------------------------------------
path_data_oe_pro = here("data/heizsysteme/PZwpABANjDXlWLye-bar-stacked-vertical-so-hat-sich-das-heizsystem-in.csv")
path_data_oe_abs = here("data/heizsysteme/PZwpABANjDXlWLye-bar-stacked-vertical-so-hat-sich-das-heizsystem-in_oe_abs.csv")

# data --------------------------------------------------------------------
data_pro = read_delim(path_data_oe_pro, delim = ";")
data_abs = read_delim(path_data_oe_abs, delim=";")

# wrangle data ------------------------------------------------------------

## PROZENT

data_pro %>%
  select(1, 4, 5) %>%
  rename(
    date = 1,
    typ = 2,
    value = 3
  ) %>%
  pivot_wider(
    names_from = date
  ) %>% rename_with(
    function(x){gsub("^(\\d{4}).*", "\\1", x)}
  ) -> df_final


out_file = here("output/heizsysteme_zeit/heizsysteme_zeit_oe_prozent.csv")
dir = dirname(out_file)
if(!dir.exists(dir)) dir.create(dir)
write_csv(df_final, out_file)

## ABSOLUT

data_abs %>%
  select(1, 4, 5) %>%
  rename(
    date = 1,
    typ = 2,
    value = 3
  ) %>%
  pivot_wider(
    names_from = date
  ) %>% rename_with(
    function(x){gsub("^(\\d{4}).*", "\\1", x)}
  ) -> df_final_abs


out_file_abs = here("output/heizsysteme_zeit/heizsysteme_zeit_oe_abs.csv")
dir = dirname(out_file_abs)
if(!dir.exists(dir)) dir.create(dir)
write_csv(df_final_abs, out_file_abs)
