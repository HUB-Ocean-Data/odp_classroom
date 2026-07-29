#########################
# Module 1 - R analysis #
#########################

# clear environment
rm(list = ls())

# install.packages("package")
# library(package)

# calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

############################
############################

#### 1. install packages

# install packages
## installing and loading individual packages
install.packages("ggplot2")
library(ggplot2)

# check session
## version of R, packages and their versions, etc.
sessionInfo()

# alternative to install and loading packages
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

# check session again to notice the difference
sessionInfo()

# install ODP R package
## remotes package or pak() package
remotes::install_github("C4IROcean/odp-sdkr")
pak::pkg_install("C4IROcean/odp-sdkr")

############################
############################

#### 2. connecting to the ODP server

# connect to ODP
## usethis::edit_r_environ() to set and save odp_api_key
odp_api_key <- Sys.getenv("odp_api_key")
client <- odp::odp_client(api_key = odp_api_key)

# load data (GLODAP V2: https://app.hubocean.earth/catalog/dataset/aea06582-fc49-4995-a9a8-2f31fcc65424/global-ocean-data-analysis-project-glodap-data)
## designate the UUID for the dataset
data_uuid <- "aea06582-fc49-4995-a9a8-2f31fcc65424"

## point the ODP client to the UUID on the server
glodap <- client$dataset(data_uuid)

# create dataset table from ODP (still server side)
dataset <- client$dataset(data_uuid)$table

## statistics about the data
### names of the statistics options
names(client$dataset(data_uuid)$table$stats())

### number of rows
client$dataset(data_uuid)$table$stats()$num_rows

### dataset size (in bytes)
client$dataset(data_uuid)$table$stats()$size

## inspect field names
### names and type
client$dataset(data_uuid)$table$schema()

### just names
client$dataset(data_uuid)$table$schema()$names

### particular field name -- "G2bottomdepth"
client$dataset(data_uuid)$table$schema()$names[11]

### stats on the 11th field -- "G2bottomdepth"
client$dataset(data_uuid)$table$stats()$columns[[11]]

############################
############################

#### 3. ingesting data from ODP server to local R environment

# ingest from ODP to R
## under normal circumstances -- uncomment the below two lines and run
# data <- client$dataset(data_uuid)$table$select()$all_dataframe(max_rows = 10000000000000000000,
#                                                                max_time = 10000000000000000000)

# calculate start time of code (determine how long it takes to complete all code)
load_start <- Sys.time()

# ingest data from ODP
data <- client$dataset(data_uuid)$table$select(filter = "G2bottomdepth >= ? AND G2bottomdepth <= ?",
                                               # set the variables to be the minimum and maximum values (depth) for the field
                                               vars = list(500, 2000))$all_dataframe(max_rows = 10000000000000000000, # maximum number of rows to grab before timing out
                                                                                     # maximum amount of time to run before timing out
                                                                                     max_time = 10000000000000000000)

# calculate end time and print time difference
print(Sys.time() - load_start) # print how long it takes to calculate

############################
############################

#### 4. data inspection

# inspect data structure
dplyr::glimpse(data)

# dimensions
dim(data)

# field names
names(data)

# class (data.frame)
class(data)

############################
############################

#### 5. preparing data for visualization and analysis

# convert to sf to visualize the data
data_sf <- data %>%
  # set as sf
  sf::st_as_sf(x = .,
               # geometry field that holds the WKT-encoded geometries
               wkt = "geometry",
               # convert to WGS84 (EPSG: 4326, https://epsg.io/4326)
               crs = 4326) %>%
  # clean field names to be unique, lowercase and use "_" when needed
  janitor::clean_names()

# check field names and class
names(data_sf)

## now sf and data.frame
class(data_sf)

############################
############################

#### 6. visualizing -- interactive

# build interactive map
mapview::mapview(x = data_sf,
                 # color for legend
                 zcol = "g2bottomdepth",
                 # layer name for legend
                 layer.name = "Depth (m)")

############################
############################

#### 7. visualizing -- static map (global)

# global data (from Natural Earth: https://www.naturalearthdata.com)
## world country boundries
world <- rnaturalearth::ne_countries(scale = "large",
                                     # return country boundaries
                                     type = "countries",
                                     # class should be sf
                                     returnclass = "sf")

## European country boundaries
europe <- rnaturalearth::ne_countries(scale = "large",
                                      # country level
                                      type = "countries",
                                      # specific continent
                                      continent = "Europe",
                                      # class should be sf
                                      returnclass = "sf")

# static plot
p <- ggplot2::ggplot() +
  # GLODAP
  ggplot2::geom_sf(data = data_sf,
                   # aesthetics will be color
                   aes(color = g2bottomdepth),
                   # no fill
                   fill = NA) +
  
  # world
  ggplot2::geom_sf(data = world,
                   # fill will be a light grey
                   fill = "grey90",
                   # black border
                   color = "black",
                   # middle transparency (low alpha (0.0) = opaque, high alpha (1.0) = very transparent)
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
                                              # maximum break
                                              to = 2000,
                                              # break steps by every X value (250)
                                              by = 250),
                                 
                                 # legend labels
                                 labels = c("500", "750", "1000", "1250", "1500", "1750", "2000")) +
  
  # guides
  guides(color = guide_colourbar(title.position = "top",
                                 # tick color
                                 ticks.colour = "black",
                                 # frame color
                                 frame.colour = "black",
                                 # title horizontal adjustment (middle = 0.5)
                                 title.hjust = 0.5),
         # no fill
         fill = "none") +
  
  # default theme (resource: https://ggplot2.tidyverse.org/reference/ggtheme.html)
  theme_bw() +
  
  # map theme
  theme(axis.text = element_text(size = 6), # axis text size
        # axis title size
        axis.title = element_text(size = 8),
        # y-axis text angle and horizontal adjustment
        axis.text.y = element_text(angle = 90,
                                   # horizontal adjustment (ranges from 0.0 - 1.0)
                                   hjust = 0.5),
        # strip text size
        strip.text = element_text(size = 8),
        
        # gridlines (remove = element_blank())
        ## major gridlines
        panel.grid.major = element_blank(),
        ## minor gridlines
        panel.grid.minor = element_blank(),
        ## panel background
        panel.background = element_blank(), 
        ## axis line color
        axis.line = element_line(colour = "black"),
        
        # legend (https://tidyverse.org/blog/2024/02/ggplot2-3-5-0-legends/)
        ## text size
        legend.text = element_text(size = 6),
        ## title size
        legend.title = element_text(size = 8),
        ## location position (https://ggplot2.tidyverse.org/reference/theme.html -- bottom, top, right, left, none, inside)
        legend.position = "bottom",
        # legend key size (unit main options: cm, mm, inches, points, picas -- https://rdrr.io/r/grid/unit.html)
        legend.key.size = unit(0.4, "cm"),
        # legend key width
        legend.key.width = unit(2, "cm"),
        # legend key direction (horizontal or vertical)
        legend.direction = "horizontal",
        # legend background
        legend.background = element_rect(fill = NA, # no fill
                                         # no color
                                         color = NA,
                                         # line width (0.0 to 1.0)
                                         linewidth = 0.5),
        # plot
        plot.margin=grid::unit(c(0,0,0,0), "mm"))

# plot image
p

############################
############################

#### 8. visualizing -- static map (European Arctic)

# load data
## protected areas from Protected Seas (resource: https://protectedseas.net)
### ODP: https://app.hubocean.earth/catalog/dataset/a608f54b-75c7-4df9-a3a8-cedbfa391873/protectedseas-navigator-v2-focused-area-based-protections
pa <- client$dataset("a608f54b-75c7-4df9-a3a8-cedbfa391873")$table$select(filter = "category_name = 'Marine Protected Area' AND iucn_category = 'Ia'")$all_dataframe() %>%
  # fix geometries (WKB format)
  dplyr::mutate(geometry = sf::st_as_sfc(structure(as.list(geometry),
                                                   class = "WKB"))) %>%
  # set CRS as WGS84 (EPSG:4326)
  sf::st_as_sf(crs = 4326) %>%
  # make geometries valid
  sf::st_make_valid()

# Greenland
greenland <- rnaturalearth::ne_countries(scale = "large",
                                         # countries boundary
                                         type = "countries",
                                         # continent
                                         continent = "North America",
                                         # class
                                         returnclass = "sf") %>%
  # return only the boundary for Greenland
  dplyr::filter(admin == "Greenland")

## check field names
names(greenland)
## inspect 
dplyr::glimpse(greenland)

############################

# interactive plot
mapview::mapview(x = data_sf,
                 # legend color based on bottom depth field
                 zcol = "g2bottomdepth",
                 # new legend name
                 layer.name = "Depth (m)") +
  
  # protected areas
  mapview::mapview(x = pa,
                   # color as green (green1 = light, green4 = dark)
                   col.regions = "green4")

############################

# static map of GLODAP (500 - 2000m) + protected areas
p2 <- ggplot2::ggplot() + 
  
  # GLODAP
  ggplot2::geom_sf(data = data_sf,
                   # aesthetic (what appears in legend)
                   aes(color = g2bottomdepth),
                   # no fill
                   fill = NA) +
  
  # Europe
  ggplot2::geom_sf(data = europe,
                   # light grey field (grey0 = dark grey/black, grey99 = light grey)
                   fill = "grey90",
                   # black boundary line
                   color = "black",
                   # whole layer half transparent
                   alpha = 0.5) +
  
  # Greenland
  ggplot2::geom_sf(data = greenland,
                   # light grey fill
                   fill = "grey90",
                   # black boundary line
                   color = "black",
                   # middle transparency
                   alpha = 0.5) +
  
  # protected areas
  ggplot2::geom_sf(data = pa,
                   # aesthetics will be linetype
                   aes(linetype = "Protected Areas"),
                   # line color
                   color = "green4",
                   # no fill
                   fill = NA,
                   # low line width
                   lwd = 0.2,
                   # some transparency
                   alpha = 0.4) +
  
  # x-axis limit (zoom in between -30 and 30 longitude)
  ggplot2::xlim(-30, 30) +
  # y-axis limit (zoom between 60 and 85 latitude)
  ggplot2::ylim(60, 85) + 
  
  # legend (depth)
  ggplot2::scale_color_gradientn(name = "Depth (m)",
                                 # color ramp (RColor Brewer is based off Color Brewer: https://colorbrewer2.org/)
                                 ## RColorBrewer (resource: https://r-graph-gallery.com/38-rcolorbrewers-palettes.html)
                                 colors = RColorBrewer::brewer.pal(n = 9,
                                                                   name = "Blues"),
                                 
                                 # NA values
                                 na.value = "grey70",
                                 
                                 # limits
                                 limits = c(500, 2000),
                                 
                                 # legend breaks
                                 breaks = seq(from = 500,
                                              # maximum
                                              to = 2000,
                                              # step by
                                              by = 250),
                                 
                                 # legend labels
                                 labels = c("500", "750", "1000", "1250", "1500", "1750", "2000")) +
  
  # legend (protected areas)
  ggplot2::scale_linetype_manual(name = "", # ignore legend title
                                 # make the protected areas equal to a dashed linetype
                                 values = c("Protected Areas" = "dashed")) +
  
  # guides
  guides(color = guide_colourbar(title.position = "top",
                                 # guide tick color
                                 ticks.colour = "black",
                                 # guide frame color
                                 frame.colour = "black",
                                 # guide title horizontal adjustment
                                 title.hjust = 0.5,
                                 # guide order to add the legend
                                 ## first of the legend entries
                                 order = 1),
         # protected areas guide
         linetype = guide_legend(title.position = "top",
                                 # override the aesthetics for the protected areas
                                 override.aes = list(color = "green4",
                                                     # transparency
                                                     alpha = 1,
                                                     # line width
                                                     lwd = 0.5),
                                 # 2nd entry in the legend
                                 order = 2),
         # guide will have no fill
         fill = "none") +
  
  # default theme
  theme_bw() +
  
  # map theme
  theme(axis.text = element_text(size = 6),
        # axis title size
        axis.title = element_text(size = 8),
        # y-axis text angle and horizontal adjustment
        axis.text.y = element_text(angle = 90,
                                   # horizontal adjustment
                                   hjust = 0.5),
        # string text size
        strip.text = element_text(size = 8),
        
        # gridlines
        ## major grid lines (none)
        panel.grid.major = element_blank(),
        ## minor grid lines (none)
        panel.grid.minor = element_blank(),
        ## background (non)
        panel.background = element_blank(),
        ## axis line color
        axis.line = element_line(colour = "black"),
        
        # legend
        legend.text = element_text(size = 6),
        ## legend title size
        legend.title = element_text(size = 8),
        ## legend position
        legend.position = "right",
        ## legend key size (in centimeters)
        legend.key.size = unit(1, "cm"),
        ## legend key width (in cm)
        legend.key.width = unit(0.5, "cm"),
        ## legend box -- vertical orientation
        legend.box = "vertical",
        ## legend direction -- vertical orientation
        legend.direction = "vertical",
        ## legend background (no fill, no color, linewidth minimal)
        legend.background = element_rect(fill = NA,
                                         color = NA,
                                         linewidth = 0.5),
        
        # plot
        plot.margin = grid::unit(c(0, 0, 0, 0), "mm"))

# plot image
p2

############################
############################

#### 9. create output directories

# create output directories (data, code, figures)
fs::dir_create("code")
fs::dir_create(c("data", "figures"))

############################
############################

#### 10. export figures

# export figures
## global map
ggplot2::ggsave(plot = p,
                # path and filename
                filename = file.path("figures", "glodap_map.png"),
                # width
                width = 2048,
                # height
                height = 1736,
                # units for width and height (options: in, cm, mm, px)
                ## pixels
                units = "px",
                # plot resolution (300 = "print", 72 = "screen", 320 = "retina" / 600 would be high-resolution)
                dpi = "screen")

ggplot2::ggsave(plot = p2,
                filename = file.path("figures", "glodap_europe.png"),
                width = 1736,
                height = 2048,
                units = "px",
                ## high resolution
                dpi = 600)

############################
############################

#### 11. export data -- locally

# export data
## geopackage
sf::st_write(obj = data_sf,
             # destination (file path)
             dsn = file.path("data", "glodap.gpkg"),
             # layer name
             layer = "glodap_500-2000m",
             # append (TRUE) or replace (FALSE)
             append = F)

## GeoJSON -- format friendly with ODP
sf::st_write(obj = data_sf,
             # destination
             dsn = file.path("data", "glodap_500-2000m.geojson"),
             # delete destination if data already exist (T)
             delete_dsn = T)

## Geoparquet -- ODP friendly format
sfarrow::st_write_parquet(obj = data_sf,
                          # destination
                          dsn = file.path("data", "glodap_500-2000.geoparquet"))

## RDS file -- R friendly format
readr::write_rds(x = data_sf,
                 file = file.path("data", "glodap_500-2000m.rds"))

############################
############################

#### 12. export data -- ODP

# export to ODP
data_odp <- data_sf %>%
  # change geometry to appropriate format (string)
  dplyr::mutate(geometry = sf::st_as_text(geometry))

dplyr::glimpse(data_odp)

# dataset from the ODP side
odp_client <- client$dataset("92962e0f-3c67-4abd-a40f-e0bff21b0ea5")

## table for ODP
odp_table <- odp_client$table

# check field names
names(data_odp)

# construct the data schema
schema <- arrow::schema(
  # build the schema based on these data
  data_odp
)

# inspect the schema
schema

# drop existing tables to populate with new one
odp_table$drop()

# send data to table to repopulated on ODP
odp_table$create(data_odp)

############################
############################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
