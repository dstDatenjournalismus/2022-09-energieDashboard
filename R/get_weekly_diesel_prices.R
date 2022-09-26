url = "https://ec.europa.eu/energy/observatory/reports/latest_prices_with_taxes.xlsx"
file = paste0(tempdir(), "/", "temp.xlsx")
download.file(url, file)
data = readxl::read_xlsx(file, sheet = 2)


# get the date (in col 5 header) ------------------------------------------------------------
col5_header = names(data)[[5]]
date_unformatted = gsub(".*(\\d{1,2}/\\d{1,2}/\\d{1,2})$", "\\1", col5_header)
date = as.Date(date_unformatted, format="%m/%d/%y")

# format data --------------------------------------------------------------
new_names = c("country", "super95", "diesel", "heizöl")
data = data[,1:length(new_names)]
names(data) = new_names
data = data[!is.na(data$country) & !is.na(data$diesel), ]

new_data = lapply(seq_along(data), function(i){
  if(i != 1){
    ret = as.numeric(gsub(",", "", data[[i]]))
  }else{
    ret = data[[i]]
  }
  ret
})

new_data = as.data.frame(new_data)
new_data = setNames(new_data, names(data))
new_data = new_data[1:27, ]
new_data[["date"]] = date


# replace Czech Rep. ------------------------------------------------------
new_data$country = ifelse(new_data$country == "Czechia", "Czech Rep.", new_data$country)


# make german names -------------------------------------------------------
res = sapply(new_data$country, function(x) {
  switch(
    x,
    "Austria" = "Österreich",
    "Belgium" = "Belgien",
    "Bulgaria" = "Bulgarien",
    "Croatia" = "Kroatien",
    "Cyprus" = "Zypern",
    "Denmark" = "Dänemark",
    "Estonia" = "Estland",
    "Finland" = "Finnland",
    "France" = "Frankreich",
    "Germany" = "Deutschland",
    "Greece" = "Griechenland",
    "Hungary" = "Ungarn",
    "Czech Rep." = "Tschechien",
    "Ireland" = "Irland",
    "Italy" = "Italien",
    "Latvia" = "Lettland",
    "Lithuania" = "Litauen",
    "Luxembourg" = "Luxemburg",
    "Malta" = "Malta",
    "Netherlands" = "Niederlanden",
    "Poland" = "Polen",
    "Portugal" = "Portugal",
    "Romania" = "Rumänien",
    "Slovakia" = "Slovakei",
    "Slovenia" = "Slowenien",
    "Spain" = "Spanien",
    "Sweden" = "Schweden",
  )
})

new_data[["country_ger"]] = res



# save data ---------------------------------------------------------------
fn = sprintf("output/weekly_fuel_prices/weeky_fuel_prices.csv")
dir = dirname(fn); if(!dir.exists(dir)) dir.create(dir, recursive = T)
write.csv(new_data, fn)
