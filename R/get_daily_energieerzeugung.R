today = as.Date(Sys.time())
tomorrow = today + 1

# url ---------------------------------------------------------------------
url = sprintf("https://transparency.apg.at/transparency-api/api/v1/Data/AGPT/German/M15/%sT000000/%sT000000", today, tomorrow)


# download data -----------------------------------------------------------

# build request
req = httr2::request(url)
req = httr2::req_headers(req, "Accept" = "application/json")
req = httr2::req_headers(req, "User-Agent" = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:104.0) Gecko/20100101 Firefox/104.0")


# perform the request
resp = httr2::req_perform(req)

# get the content
content = httr2::resp_body_json(resp)
print(paste0("content: ", content))

# table headers -----------------------------------------------------------
values_list = list(
  "Wind" = c(),
  "Solar" = c(),
  "Biomasse" = c(),
  "Gas" = c(),
  "Kohle" = c(),
  "Öl" = c(),
  "Geothermie" = c(),
  "Pumpspeicher" = c(),
  "Lauf- und Schwellwasser" = c(),
  "Speicher" = c(),
  "Sonstige Erneuerbare" = c(),
  "Müll" = c(),
  "Andere" = c(),
  "Date" = c(),
  "Time" = c()
)


# clean data --------------------------------------------------------------
rows = content$ResponseData$ValueRows


for(r in seq_along(rows)){

  row = rows[[r]]

  # date and time
  values_list$Date = c(values_list$Date, row$DF)
  values_list$Time = c(values_list$Time, row$TF)

  # for the values
  values = row$V

  # for each energy category
  for(c in seq_along(values)){

    vals_one_category = values[[c]]
    val = vals_one_category$V
    values_list[[c]] = c(values_list[[c]], val)
  }
}

# shorten each list element to the length of the values -------------------
l_each_element = vapply(values_list, length, numeric(1))
min_length = min(l_each_element)

# do all but the time and the date have the same minimum length?
min_elements = which(l_each_element == min_length)
diff = setdiff(names(values_list), names(min_elements))
only_date_time_missing = all(diff %in% c("Date", "Time"))
if(!only_date_time_missing){
  stop("Some error...")
}

# short then date time to the length of the values
final_list = lapply(values_list, function(x){
  x = x[1:min_length]
})


# make it a dataframe -----------------------------------------------------
df = as.data.frame(final_list)


# save it -----------------------------------------------------------------
tdy = gsub("-", "_", today)
tmr =gsub("-", "_", tomorrow)
filename = paste0("output/energieerzeugung/", sprintf("%s_%s.csv", tdy, tmr))


# if the directory does not exist -----------------------------------------
dir = dirname(filename)
if(!dir.exists(dir)) dir.create(dir)
write.csv(df, filename)






























