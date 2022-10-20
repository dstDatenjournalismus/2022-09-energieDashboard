library(httr)

# urls ---------------------------------------------------------------------

# url = "https://www.bruegel.org/sites/default/files/2022-09/gas_tracker_update_.zip"

# 10.10
# url = "https://www.bruegel.org/sites/default/files/2022-10/gas%20datasets_0.zip"

# 20.10
url = "https://www.bruegel.org/sites/default/files/2022-10/Gas%20tracker_0.zip"

# download zip ------------------------------------------------------------
download_path = tempfile()
download_dir = dirname(download_path)

# download.file(url, download_path, method="libcurl", headers = c("User-Agent" = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:104.0) Gecko/20100101 Firefox/104.0"))


# Download the data in loop -----------------------------------------------
success = FALSE
i = 1
while(!success & i <= 5) {

  print(paste0("Try for the ", i, ". time"))

  # try the download
  res = httr::GET(url, write_disk(download_path, overwrite = T))

  # if it did work
  if (res$status_code == 200) {
    success = TRUE
  }

  # if it did not work
  i = i + 1

}

if(!res$status_code == 200) stop("Download did not work after 5 tries")

unzip(download_path, exdir = download_dir)


# data dir ----------------------------------------------------------------

# the unzipped file does not contain the files, but another directory which apparently
# changes each week its name. But every week so far the word "Gas" was in it
unzipped_dir_name = dir(download_dir, ".*[gG]as.*", full.names = T)

# find file
files = dir(unzipped_dir_name, "*.csv|xlsx", full.names = T)
print(paste0("files: ", files))
file_idx = which(grepl("country_data", files))

# read data
data = read.csv(files[[file_idx]])

# wrangle it a bit
col_indices = which(grepl("week|Russia_", names(data)))
data = data[, col_indices]
# data = data[complete.cases(data), ]

data[["EU Ziel"]] = (1/3) * data$Russia_2021

print(head(data))
print(tail(data))

names(data)[names(data) == "Russia_avg"] = "Durchschnitt 2015 - 2022"
names(data)[names(data) == "Russia_2022"] = "2022"

output_file = "R/output/natural_gas_russia_europe.csv"
dir = dirname(output_file); if(!dir.exists(dir)) dir.create(dir, recursive = T)
write.csv(data, output_file)





