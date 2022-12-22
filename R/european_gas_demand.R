library(rvest)
library(dplyr)


# url ---------------------------------------------------------------------
url = "https://www.bruegel.org/dataset/european-natural-gas-demand-tracker"

# get the table -----------------------------------------------------------
rvest::read_html(url)

