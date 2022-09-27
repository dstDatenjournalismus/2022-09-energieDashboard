library(tidyverse)
library(httr2)
library(glue)

# url ---------------------------------------------------------------------
url_key = readLines(here("apikeys.txt")) %>% strsplit("=") %>% .[[1]] %>% .[[2]]
endpoint = "about?show=listing"
url = glue("https://agsi.gie.eu/api/{endpoint}")

req = httr2::request(url)
req = httr2::req_headers(req, "x-key" = url_key)


# perform request ---------------------------------------------------------
resp = req_perform(req)

# response ----------------------------------------------------------------
content = httr2::resp_body_json(resp)



# countries ---------------------------------------------------------------
data = imap(content, function(x, i){
  c = x[["facilities"]][[1]][["country"]]
  d = x[["facilities"]][[1]][["url"]]
  n = x[["facilities"]][[1]][["name"]]
  l =list(country = c, linkData = d, name = n)
  return(l)
})

# get the data on how full the gas storages are ---------------------------
map(data, function(x){

  url = x$linkData
  req = httr2::req_headers(req, "x-key" = url_key)
  resp = httr2::req_perform(req)

  if(!resp$status_code == 200){
    return(NA)
  }

  content = httr2::resp_body_json(resp)

  #####
  # DATA FOR EACH STORAGE
  #####
  dates = map(content$data, "gasDayStart") %>% unlist
  fulls = map(content$data, "full") %>% unlist
  gasInStorage = map(content$data, "gasInStorage") %>% unlist
  trend = map(content$data, "trend") %>% unlist








})



