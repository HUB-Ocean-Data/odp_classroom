rm(list = ls())

# install.packages("package")
# library(package)

install.packages("ggplot2")
library(ggplot2)

sessionInfo()

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(arrow,
               ggplot2,
               janitor,
               mapview,
               pak,
               RColorBrewer,
               remotes,
               rnaturalearth,
               sf,
               sfarrow,
               tidyverse)

sessionInfo()

remotes::install_github("C4IROcean/odp-sdkr")
pak::pkg_install("C4IROcean/odp-sdkr")

# connect to ODP
odp_api_key <- Sys.getenv("odp_api_key")
client <- odp::odp_client(api_key = odp_api_key)

data_uuid <- "aea06582-fc49-4995-a9a8-2f31fcc65424"

glodap <- client$dataset(data_uuid)

# create table on ODP
dataset <- client$dataset(data_uuid)$table

# stastics about the data
names(client$dataset(data_uuid)$table$stats())
client$dataset(data_uuid)$table$stats()$num_rows
client$dataset(data_uuid)$table$stats()$size

# inspect field names
client$dataset(data_uuid)$table$schema()
client$dataset(data_uuid)$table$schema()$names

client$dataset(data_uuid)$table$schema()$names[11]
client$dataset(data_uuid)$table$stats()$columns[[11]]

# ingest from ODP to R
# data <- client$dataset(data_uuid)$table$select()$all_dataframe(max_rows = 10000000000000000000,
#                                                                max_time = 10000000000000000000)

data <- client$dataset(data_uuid)$table$select(filter = "G2bottomdepth >= ? AND G2bottomdepth <= ?",
                                               vars = list(500, 2000))$all_dataframe(max_rows = 10000000000000000000,
                                                                                     max_time = 10000000000000000000)

# inspect data structure
dplyr::glimpse(data)
dim(data)
names(data)
class(data)

# convert to sf
data_sf <- data %>%
  sf::st_as_sf(x = .,
               wkt = "geometry",
               crs = 4326) %>%
  janitor::clean_names()
names(data_sf)
class(data_sf)

# mapping interactively
mapview::mapview(data_sf,
                 zcol = "g2bottomdepth",
                 layer.name = "Depth (m)")

# global data
world <- rnaturalearth::ne_countries(scale = "large",
                                     type = "countries",
                                     returnclass = "sf")
europe <- rnaturalearth::ne_countries(scale = "large",
                                      type = "countries",
                                      continent = "Europe",
                                      returnclass = "sf")

# static plot
p <- ggplot2::ggplot() +
  # GLODAP
  ggplot2::geom_sf(data = data_sf,
                   aes(color = g2bottomdepth),
                   fill = NA) +
  
  # world
  ggplot2::geom_sf(data = world,
                   fill = "grey90",
                   color = "black",
                   alpha = 0.5) +
  
  # legend
  ggplot2::scale_color_gradientn(name = "Depth (m)",
                                 # color ramp
                                 colors = RColorBrewer::brewer.pal(n = 9,
                                                                   name = "Blues"),
                                 
                                 # NA values
                                 na.value = "grey70",
                                 
                                 # limits
                                 limits = c(500, 2000),
                                 
                                 # legend breaks
                                 breaks = seq(from = 500,
                                              to = 2000,
                                              by = 250),
                                 
                                 # legend labels
                                 labels = c("500", "750", "1000", "1250", "1500", "1750", "2000")) +
  
  # guides
  guides(color = guide_colourbar(title.position = "top",
                                 ticks.colour = "black",
                                 frame.colour = "black",
                                 title.hjust = 0.5),
         fill = "none") +
  
  # default theme
  theme_bw() +
  
  # map theme
  theme(axis.text = element_text(size=6),
        axis.title = element_text(size=8),
        axis.text.y = element_text(angle = 90,
                                   hjust = 0.5),
        strip.text = element_text(size = 8),
        
        # gridlines
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(), 
        axis.line = element_line(colour = "black"),
        
        # legend
        legend.text = element_text(size = 6),
        legend.title = element_text(size = 8),
        legend.position = "bottom",
        legend.key.size = unit(0.4, "cm"),
        legend.key.width = unit(2, "cm"),
        legend.direction = "horizontal",
        legend.background = element_rect(fill = NA,
                                         color = NA,
                                         linewidth = 0.5),
        # plot
        plot.margin=grid::unit(c(0,0,0,0), "mm"))
p

# load protected areas
pa <- client$dataset("a608f54b-75c7-4df9-a3a8-cedbfa391873")$table$select(filter = "category_name = 'Marine Protected Area' AND iucn_category = 'Ia'")$all_dataframe() %>%
  # fix geometries
  dplyr::mutate(geometry = sf::st_as_sfc(structure(as.list(geometry),
                                                   class = "WKB"))) %>%
  # set CRS as WGS84 (EPSG:4326)
  sf::st_as_sf(crs = 4326) %>%
  # make geometries valid
  sf::st_make_valid()

greenland <- rnaturalearth::ne_countries(scale = "large",
                                         type = "countries",
                                         continent = "North America",
                                         returnclass = "sf") %>%
  dplyr::filter(admin == "Greenland")
names(greenland)
dplyr::glimpse(greenland)

# interactive plot
mapview::mapview(data_sf,
                 zcol = "g2bottomdepth",
                 layer.name = "Depth (m)") +
  mapview::mapview(pa,
                   # color as green
                   col.regions = "green4")

# static map of GLODAP (500 - 2000m) + protected areas
p2 <- ggplot2::ggplot() + 
  
  # GLODAP
  ggplot2::geom_sf(data = data_sf,
                   aes(color = g2bottomdepth),
                   fill = NA) +
  
  # Europe
  ggplot2::geom_sf(data = europe,
                  fill = "grey90",
                  color = "black",
                  alpha = 0.5) +
  
  # Greenland
  ggplot2::geom_sf(data = greenland,
                   fill = "grey90",
                   color = "black",
                   alpha = 0.5) +
  
  # protected areas
  ggplot2::geom_sf(data = pa,
                   aes(linetype = "Protected Areas"),
                   color = "green4",
                   fill = NA,
                   lwd = 0.2,
                   alpha = 0.4) +
  
  # x-axis limit
  ggplot2::xlim(-30, 30) +
  # y-axis limit
  ggplot2::ylim(60, 85) + 
  
  # legend
  ggplot2::scale_color_gradientn(name = "Depth (m)",
                                 # color ramp
                                 colors = RColorBrewer::brewer.pal(n = 9,
                                                                   name = "Blues"),
                                 
                                 # NA values
                                 na.value = "grey70",
                                 
                                 # limits
                                 limits = c(500, 2000),
                                 
                                 # legend breaks
                                 breaks = seq(from = 500,
                                              to = 2000,
                                              by = 250),
                                 
                                 # legend labels
                                 labels = c("500", "750", "1000", "1250", "1500", "1750", "2000")) +
  
  ggplot2::scale_linetype_manual(name = "",
                                 values = c("Protected Areas" = "dashed")) +
  
  
  guides(color = guide_colourbar(title.position = "top",
                                 ticks.colour = "black",
                                 frame.colour = "black",
                                 title.hjust = 0.5,
                                 order = 1),
         linetype = guide_legend(title.position = "top",
                                 override.aes = list(color = "green4", alpha = 1, lwd = 0.5),
                                 order = 2),
         fill = "none") +
  
  # default theme
  theme_bw() +
  
  # map theme
  theme(axis.text = element_text(size = 6),
        axis.title = element_text(size = 8),
        axis.text.y = element_text(angle = 90, hjust = 0.5),
        strip.text = element_text(size = 8),
        
        # gridlines
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(), 
        axis.line = element_line(colour = "black"),
        
        # legend
        legend.text = element_text(size = 6),
        legend.title = element_text(size = 8),
        legend.position = "right",
        legend.key.size = unit(1, "cm"),
        legend.key.width = unit(0.5, "cm"),
        legend.box = "vertical",
        legend.direction = "vertical",
        legend.background = element_rect(fill = NA, color = NA, linewidth = 0.5),
        
        # plot
        plot.margin = grid::unit(c(0, 0, 0, 0), "mm"))
p2

# create output directories (data, code, figures)
fs::dir_create("code")
fs::dir_create(c("data", "figures"))

# export figures
ggplot2::ggsave(plot = p,
                filename = file.path("figures", "glodap_map.png"),
                width = 2048,
                height = 1736,
                units = "px",
                dpi = 300)

ggplot2::ggsave(plot = p2,
                filename = file.path("figures", "glodap_europe.png"),
                width = 1736,
                height = 2048,
                units = "px",
                dpi = 300)

# export
## geopackage
sf::st_write(obj = data_sf,
             dsn = file.path("data", "glodap.gpkg"),
             layer = "glodap_500-2000m",
             append = F)

## GeoJSON
sf::st_write(obj = data_sf,
             dsn = file.path("data", "glodap_500-2000m.geojson"),
             append = F)

## Geoparquet
sfarrow::st_write_parquet(obj = data_sf,
                          dsn = file.path("data", "glodap_500-2000.geoparquet"))

## RDS file
readr::write_rds(x = data_sf,
                 file = file.path("data", "glodap_500-2000m.rds"))

# export to ODP
data_odp <- data_sf %>%
  # change geometry to appropriate format (string)
  dplyr::mutate(geometry = sf::st_as_text(geometry))

dplyr::glimpse(data_odp)

# dataset from the ODP side
odp_client <- client$dataset("92962e0f-3c67-4abd-a40f-e0bff21b0ea5")

## table for ODP
odp_table <- odp_client$table

names(data_odp)

schema <- arrow::schema(
  # build the schema based on these data
  data_odp
)

schema

# send data to table to repopulated on ODP
odp_table$create(data_odp)
