library(tidyverse)
url = "https://ec.europa.eu/energy/observatory/reports/Oil_Bulletin_Prices_History.xlsx"
file = paste0(tempdir(), "/", "temp.xlsx")
download.file(url, file)
data_raw = readxl::read_xlsx(file)

# vals --------------------------------------------------------------------
vals = c(
  "Euro-super 95",
  "Dieselkraftstoff",
  "Heizöl \\(II\\)"
)


# clean -------------------------------------------------------------------
names(data_raw)[1] = "country"
country_data = data_raw %>%
  tidyr::fill(country)  %>% split(., .$country)

data_per_country = lapply(country_data, function(x){

  vals_country = vector("list", length = length(vals)) %>% setNames(vals)

  # add the date
  # also removes the row with the units...
  names(x)[2:3] = c("date", "er")
  data_with_date = x %>%
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


  data_num = lapply(seq_along(data), function(i){
    if(i %in% 1:2) return(data[[i]])
    num_col = as.numeric(gsub(",", "", data[[i]]))
    return(num_col)
  })

  df = as.data.frame(do.call("cbind", data_num))
  names(df) = names(data)
  df$date = as.Date(as.numeric(df$date), origin="1899-12-30")
  df

})



# bind them together ------------------------------------------------------
min_year = as.Date("2020-01-01")
data_after_min_year = lapply(data_per_country, function(x) x[x$date > min_year, ])

one_df_all_countries = do.call("rbind", data_after_min_year)
one_df_all_countries %>%
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



# diesel ------------------------------------------------------------------
diesel = one_df_all_countries[,c(1,2,5)]
rownames(diesel) = NULL
diesel_wide = diesel %>% pivot_wider(names_from = country,
                                values_from = Dieselkraftstoff)

path_diesel = "output/weekly_fuel_prices/historic/historic_diesel.csv"
dir = dirname(path_diesel); if(!dir.exists(dir)) dir.create(dir, recursive = T)
write.csv(diesel_wide, path_diesel)








