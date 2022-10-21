library(tidyverse)
library(lubridate)

# path --------------------------------------------------------------------
url = "https://www.e-control.at/documents/1785851/10140531/gas_dataset_mn.csv"


# read data ---------------------------------------------------------------
data = read_delim(url, delim = ";")


# current year ------------------------------------------------------------
current_year = Sys.Date() %>% lubridate::year()

# get the date of publication ---------------------------------------------
date = tryCatch({
  date = data$`1`[[1]] %>% as.Date()
},
error = function(cond) {
  date = NA
})

# format the data ---------------------------------------------------------
new_headers = data[5,] %>% unlist() %>% unname()
new_headers[[1]] = "date"

data %>%
  slice(12:nrow(.)) %>%
  setNames(new_headers) -> data_new_names


# get only the inlandsverbrauch -------------------------------------------
data_new_names %>%
  select(
    date,
    Inlandgasverbrauch
  ) %>%
  mutate(
    Inlandgasverbrauch = gsub(",", ".", Inlandgasverbrauch) %>% as.numeric(),
    year = lubridate::year(date)
  ) -> data_selected


# filter only the current and last five years -----------------------------
data_selected %>%
  filter(
    year >= current_year - 5
  ) %>%
  mutate(
    current_year = ifelse(year == current_year, T, F)
  ) -> data_current_year

# compute five year rolling average per month -----------------------------
data_current_year %>%
  mutate(month = lubridate::month(date)) %>%
  group_by(month, current_year) %>%
  summarise(mean_verbrauch = mean(Inlandgasverbrauch, na.rm = T)) %>% ungroup %>%
  mutate(monat = lubridate::month(month, label = T)) -> data_avg


# make it wide for dw -----------------------------------------------------
data_avg %>%
  pivot_wider(
    names_from = current_year,
    values_from = mean_verbrauch
  ) %>%
  rename("5_j_avg" =   `FALSE` ,
         "current_year" =   `TRUE`) -> data_wide



# write out the data ------------------------------------------------------
fn = here::here("R/output/gasverbrauch/monatlicher_gasverbrauch_5jahresmittel.csv")
print(paste0("Filename: ", fn))
dir = dirname(fn); if(!dir.exists(dir)) dir.create(dir, recursive = T)
print(paste0("Created: ", dir))
write.csv(data_wide, fn)



