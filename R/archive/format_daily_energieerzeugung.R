library(tidyverse)
library(lubridate)
library(here)

# dates -------------------------------------------------------------------
start = as.Date("2022-08-01")
end = Sys.time() %>% as.Date() + 1

# url ---------------------------------------------------------------------
url = "https://transparency.apg.at/transparency-api/api/v1/Download/AGPT/German/M15/2022-01-01T000000/2022-08-30T000000/868d39b3-d482-41e3-84b0-41136c8bfa68/AGPT_2021-12-31T23_00_00Z_2022-08-29T22_00_00Z_15M_de_2022-08-29T09_23_11Z.csv?"

# download data -----------------------------------------------------------
file = tempfile()
download.file(url, file)


# data --------------------------------------------------------------------
data = read.delim(file, sep = ";")


# format names ------------------------------------------------------------
names_src = names(data)
new_names = gsub("(.*)\\.\\..*$", "\\1", names_src)
names(data) = new_names

# format ------------------------------------------------------------------
data_num = data %>%
  mutate(
    across(3:ncol(data), function(x){
      as.numeric(gsub(",", ".", x))
    })
  )

data_date = data_num %>%
  rename(
    "start" = 1,
    "end" = 2,
  ) %>%
  mutate(
    start_date = as.Date(substr(start, 1, 10), format="%d.%m.%Y"),
    end_date = as.Date(substr(end, 1, 10), format="%d.%m.%Y")
  )


# aggregate per day -------------------------------------------------------
per_day = data_date %>%
  group_by(start_date) %>%
  summarise(
    across(where(is.numeric),
           function(x){sum(x, na.rm=T)})
  )



# set negative to 0 -------------------------------------------------------
per_day %>%
  mutate(across(where(is.numeric),
                ~ ifelse(.x < 0, 0, .x)
  )) -> per_day




# write out ---------------------------------------------------------------

fn = here("data/daily_energieerzeugung_historical.csv")
write_csv(per_day, fn)


pd_long = per_day %>%
  summarise(
    across(
      where(is.numeric),
      sum
    )
  ) %>%
  pivot_longer(
    cols = everything(),
    names_to = "type",
    values_to = "vals"
  ) %>%
  mutate(
    share = vals / sum(vals)
  ) %>% arrange(desc(share))


# lump togehter all but the 5 most common ones ----------------------------
idx = which(names(per_day) %in% pd_long$type[1:5])
most_common = per_day[,idx]
least_common = per_day[,-c(1,idx)] %>%
  rowwise() %>%
  transmute(Andere = sum(c_across(everything())))


lumped = bind_cols(per_day[,1], most_common, least_common)


fn = here("data/daily_energieerzeugung_historical_lumped.csv")
write_csv(lumped, fn)


