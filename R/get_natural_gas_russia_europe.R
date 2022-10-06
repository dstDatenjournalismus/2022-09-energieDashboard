library(httr)

# url ---------------------------------------------------------------------
url = "https://www.bruegel.org/sites/default/files/2022-09/gas_tracker_update_.zip"


# download zip ------------------------------------------------------------
download_path = tempfile()
download_dir = dirname(download_path)

# download.file(url, download_path, method="libcurl", headers = c("User-Agent" = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:104.0) Gecko/20100101 Firefox/104.0"))
httr::GET(url, write_disk(download_path, overwrite = T))
unzip(download_path, exdir = download_dir)
files = dir(download_dir)
print(files)

# find file
files = dir(download_dir, "*.csv|xlsx", full.names = T)
file_idx = which(grepl("country_data", files))

# read data
data = read.csv(files[[file_idx]])

# wrangle it a bit
col_indices = which(grepl("week|Russia_", names(data)))
data = data[, col_indices]
data = data[complete.cases(data), ]

data[["EU Ziel"]] = (1/3) * data$Russia_2021

print(head(data))

names(data)[names(data) == "Russia_avg"] = "Durchschnitt 2015 - 2022"
names(data)[names(data) == "Russia_2022"] = "2022"

output_file = "R/output/natural_gas_russia_europe.csv"
dir = dirname(output_file); if(!dir.exists(dir)) dir.create(dir, recursive = T)
write.csv(data, output_file)