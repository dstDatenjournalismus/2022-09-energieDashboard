library(tidyverse)
library(here)
library(glue)
library(data.table)
library(readxl)
library(sf)


# dir to data -------------------------------------------------------------
dir_data = here("data/photovoltaik/")

# files -------------------------------------------------------------------
files = dir(dir_data, ".*\\.xlsx$", full.names = T)


# names -------------------------------------------------------------------
bundesland = gsub(".*\\/Anlagen.*_(.*)\\.xlsx", "\\1", files)


# data --------------------------------------------------------------------
data = map(files, read_xlsx) %>% setNames(bundesland)
df = bind_rows(data, .id="bl")

# plots -------------------------------------------------------------------
ggplot2::theme_set(theme_light())


# anzahl an solaranlagen pro bundesland -----------------------------------
df %>%
  count(bl) %>%
  mutate(bl = fct_reorder(bl, n)) %>%
  ggplot() +
  geom_col(aes(n, bl)) +
  labs(
    x = "#",
    y = "",
    title = "Anzahl an Solaranlagen pro BL"
  ) -> p1


# eingespeister strom zeit pro bundesland -------------------------
df_long = df %>%
  pivot_longer(cols = matches("\\d{4}"),
               names_to = "year",
               values_to = "vals") %>%
  mutate(year = str_match(year, ".*(\\d{4}).*")[, 2],
         bl = tolower(bl))


df_long %>%
  group_by(bl, year) %>%
  summarise(
    einspeisung = sum(vals),
  ) %>%
  mutate(
    year = as.numeric(year)
  ) %>%
  ungroup() %>%
  ggplot() +
  geom_line(
    aes(year, einspeisung, color=bl)
  ) +
  labs(
    x = "",
    y = "Einspeisung [kWh]",
    title = "Einspeisung in das Stromnetz",
    subtitle = "(nach Bundesland und Jahr)"
  )

# wie viel eingespeiste energie pro qm pro bundesland
bls = geodata::gadm("Austria", level=1, path=tempdir())
bls_geo = st_as_sf(bls) %>%
  select(NAME_1) %>%
  mutate(
   bl = tolower(NAME_1),
   area_sqkm = st_area(geometry) / 1e6,
   bl = str_replace(bl, "ö", "oe"),
   bl = str_replace(bl, "ä", "ae")
  ) %>%
  st_drop_geometry() %>%
  right_join(df_long, ., by=c("bl")) -> solar_with_area


bls_geo %>%
  group_by(
    bl
  ) %>%
  filter(year == 2021) %>%
  summarise(
    area = area_sqkm[[1]],
    sum_einspeisung = sum(vals)
  ) %>% mutate(
    einspeisung_pro_sqkm = as.numeric(sum_einspeisung / area)
  ) %>%
  mutate(bl = fct_reorder(bl, einspeisung_pro_sqkm)) -> einspeisung_pro_sqkm

ggplot(einspeisung_pro_sqkm) +
  geom_col(
    aes(
      x = bl,
      y = einspeisung_pro_sqkm
    ),
    fill = "#cccccc",
    color = "black"
  ) +
  labs(
    x = "",
    y = "Einspeisung [kWh]",
    title = "Einspeisung aus Photovoltaik je Quadratkilometer und Bundesland 2021"
  )


# welche plz hat die meisten photovoltaik-anlagen -------------------------
df %>%
  group_by(Plz) %>%
  summarise(n = n(),
            ort = Ort[[1]]) %>%
  arrange(desc(n))




















