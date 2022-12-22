library(httr)
library(rvest)
library(dplyr)

# urls ---------------------------------------------------------------------

# url = "https://www.bruegel.org/sites/default/files/2022-09/gas_tracker_update_.zip"

# 10.10
# url = "https://www.bruegel.org/sites/default/files/2022-10/gas%20datasets_0.zip"

# 20.10
# url = "https://www.bruegel.org/sites/default/files/2022-10/Gas%20tracker_0.zip"

# 3.11
# url = "https://www.bruegel.org/sites/default/files/2022-11/Naturalgasimports-021122.zip"

# 14.11
# url = "https://www.bruegel.org/sites/default/files/2022-11/Gas%20tracker.zip"

# 18.11
# url = "https://www.bruegel.org/sites/default/files/2022-11/Gas%20tracker%2015%20Nov.zip"

# 28.11
# url = "https://www.bruegel.org/sites/default/files/2022-11/Gas%20tracker%2022.11.22.zip"

# 2.12
# url = "https://www.bruegel.org/sites/default/files/2022-11/Gas%20tracker%2029.11.22.zip"

# 9.12
# url = "https://www.bruegel.org/sites/default/files/2022-12/Gas%20tracker%2007.12.22.zip"

# 15.12
url = "https://www.bruegel.org/sites/default/files/2022-12/Gas%20tracker%2013.12.22.zip"

#######
# 15.12 Automate it
#######

# read the html
html = rvest::read_html("https://www.bruegel.org/dataset/european-natural-gas-imports")

# find the link
path = html_attr(html_elements(html, 'a[title="Download data"]'), "href")
url = paste0("https://www.bruegel.org/", path)




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
  print(paste0("res: ", res$status_code))

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


# find the file -----------------------------------------------------------
file = files[[file_idx]]

fileEnding = strsplit(basename(file), "\\.") %>% .[[1]] %>% .[[2]]


# read data
if(fileEnding == "csv") {
  data = read.csv(files[[file_idx]])
} else{
  data = readxl::read_xlsx(file)
}

data %>%
  mutate(
    across(where(is.character),
            ~as.numeric(gsub(",", "", .x))
           )
  ) -> data


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





