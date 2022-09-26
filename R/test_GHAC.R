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

