library(tidyverse)
library(here)
library(glue)
library(readxl)

# path data ---------------------------------------------------------------
path_data = here("data/weekly_oil_bulleting/Oil_Bulletin_Prices_History.xlsx")

# data --------------------------------------------------------------------
data_raw = read_xlsx(path_data)


# vals --------------------------------------------------------------------
vals = c(
  "Euro-super 95",
  "Dieselkraftstoff",
  "Heizöl \\(II\\)"
)


# clean -------------------------------------------------------------------
country_data = data_raw %>%
  rename(
    country = 1
  ) %>%
  tidyr::fill(country)  %>% split(., .$country)

data_per_country = lapply(country_data, function(x){

  vals_country = vector("list", length = length(vals)) %>% setNames(vals)

  # add the date
  # also removes the row with the units...
  data_with_date = x %>% rename(date = 2,
                                er = 3) %>%
    filter(!is.na(date))

  for(val in names(vals_country)){

    idxs = apply(data_with_date, 2, function(x){
      grepl(val, x)
    })

    # which column
    col = apply(idxs, 2, function(x){
      any(x)
    }) %>% which() %>% unname()

    # row
    row = apply(idxs, 1, function(x){
      any(x)
    }) %>% which()

    vals_country[[val]][["col"]] = col
    vals_country[[val]][["row"]] = row
  }

  # get the data
  cols = vapply(vals_country, function(x){x[["col"]]}, numeric(1))
  data_with_date = data_with_date[,c(1:3,cols)]

  # get the names

  data = data_with_date %>%
    slice(2:n())
  names(data)[cols] = names(vals_country)

  data$date = as.Date(as.numeric(data$date), origin="1899-12-30")
  data
})


# put all countries together ----------------------------------------------
countries = bind_rows(data_per_country, .id="country")


# make one file for each fuel ---------------------------------------------

### diesel
countries %>%
  select(country, date, matches("Diesel")) %>%
  pivot_wider(
    names_from = country,
    values_from = matches("Diesel")
  ) -> diesel

path_diesel = here("output/oil_bulletin/diesel.csv")
dir = dirname(path_diesel); if(!dir.exists(dir)) dir.create(dir)
write_csv(diesel, path_diesel)

# wher is the  max value
global_max = 0
global_max_country = ""
global_max_date = as.Date("2020-01-01")
for(r in 1:nrow(diesel)){
  print(r)
  row = diesel[r,]
  date = row$date
  idx_date = which(names(row) == "date")
  vals = row[-idx_date]
  vals_numeric = lapply(vals, function(x) gsub(",", "", x)) %>%
    unlist() %>% as.numeric
  max = max(vals_numeric, na.rm=T)
  country_max = names(vals)[which.max(vals_numeric)]

  if(max > global_max){
    global_max = max
    global_max_country = country_max
    global_max_date = date
  }

}



### Super 95
countries %>%
  select(country, date, matches("super")) %>%
  pivot_wider(
    names_from = country,
    values_from = matches("super")
  ) -> super

path_super = here("output/oil_bulletin/super.csv")
dir = dirname(path_diesel); if(!dir.exists(dir)) dir.create(dir)
write_csv(super, path_super)








