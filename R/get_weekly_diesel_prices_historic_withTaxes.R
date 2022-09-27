library(tidyverse)
url = "https://ec.europa.eu/energy/observatory/reports/Oil_Bulletin_Prices_History.xlsx"
file = paste0(tempdir(), "/", "temp.xlsx")
download.file(url, file)
data_raw = readxl::read_xlsx(file, sheet = 8)

# vals --------------------------------------------------------------------
vals = c(
  "Euro-super 95",
  "Dieselkraftstoff",
  "Heizöl \\(II\\)"
)


# add country and rename --------------------------------------------------

data_raw %>%
  rename(country_date = 1) %>%
  mutate(country = ifelse(str_detect(country_date, "^[A-Z]{2}\\b"),
                          country_date,
                          NA)) %>%
  tidyr::fill(country) %>%
  rename(
    date = 1,
    ex_rate = 2,
    super_95 = 3,
    diesel = 4,
    heizoel = 5
  )  -> data_renamed

print("date renamed")
print(head(data_renamed))


# remove empty columns ----------------------------------------------------
data_only_necessary_cols = data_renamed %>%
  select(
    -c(6,7,8)
  )

print("data only necessary cols")
print(head(data_only_necessary_cols))


# keep only complete rows -------------------------------------------------

data_only_necessary_cols %>%
  filter(
    if_all(
      everything(),
      ~!is.na(.x)
    )
  ) -> data_no_na

print("data only no na")
print(head(data_no_na))

# reformat data types -------------------------------------------------------

data_no_na %>%
  split(.$country) %>%
  lapply(function(x) {
    x = x[2:nrow(x),]
    # format date and numeric types
    x[["date"]] = as.Date(as.numeric(x$date), origin = as.Date("1899-12-30"))
    x = x %>% mutate(across(2:ncol(.),
                        ~ gsub(",", "", .x)))

    # filter only after 2020
    x = x %>%
      filter(
        date > as.Date("2020-01-01")
      )

  }) %>% bind_rows() %>%
  mutate(
    country = recode(country,
                    "AT"  = "Österreich",
                    "BG" = "Bulgarien",
                    "BE"  = "Belgien",
                    "BU"  = "Bulgarien",
                    "CY"  = "Zypern",
                    "CZ"  = "Tschechien",
                    "DE"  = "Deutschland",
                    "DK"  = "Dänemark",
                    "EE"  = "Estland",
                    "ES"  = "Spanien",
                    "FI"  = "Finnland",
                    "FR"  = "Frankreich",
                    "GR"  = "Griechenland",
                    "HU"  = "Ungarn",
                    "LV"  = "Lettland",
                    "IT"  = "Italien",
                    "RO"  = "Rumänien",
                    "LT"  = "Lituaen",
                    "PT"  = "Portugal",
                    "HR" = "Kroatien",
                    "IE" = "Irland",
                    "LU" = "Luxemburg",
                    "SE"  = "Schweden",
                    "SI"  = "Slovenien",
                    "SK"  = "Slovakei",
                    "PL"  = "Polen",
                    "EE"  = "Estland",
                    "MT" = "Malta",
                    "NL" = "Niederlanden"
                     )
  ) -> one_df_all_countries

print("formatted data")
print(head(one_df_all_countries))

# only take the diesel ----------------------------------------------------
one_df_all_countries %>%
  select(
    1,
    country,
    diesel
  ) %>%
  mutate(
    diesel = as.numeric(diesel) / 1000
  ) %>%
  pivot_wider(
    names_from = country,
    values_from = diesel
  ) -> diesel_wide

path_diesel = here::here("R/output/weekly_fuel_prices/historic/historic_diesel.csv")
dir = dirname(path_diesel); if(!dir.exists(dir)) dir.create(dir, recursive = T)
write.csv(diesel_wide, path_diesel)









