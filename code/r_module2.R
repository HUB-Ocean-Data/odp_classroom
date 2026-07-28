#########################
# Module 2 - R analysis #
#########################

## Notes:

### Recommendation: use usethis::edit_r_environ() and add odp_api_key = "YOUR_API_KEY" to the tab that opens then save and close tab
### Notation
###     %>% is symbology within the tidyverse (e.g., dplyr) that means take the result of this action and use it for the step below
###     . within a function means use data that gets piped into this function came from the previous action
###     :: this appears between a package (e.g., dplyr) and a function (e.g., rename) -- i.e., dplyr::rename will inform the code take the dplyr package and use the rename function within it

# clear environment
rm(list = ls())

# calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(arcpullr,
               fs,
               h3,
               janitor,
               leaflet,
               mapview,
               odp,
               pangaear,
               readr,
               sf,
               tidyverse)

############################
############################

#### 0. build ODP function

# function
## will make data be on ODP
odp_function <- function(odp_ready_data, uuid){
  # connect to ODP
  odp_api_key <- Sys.getenv("odp_api_key")
  client <- odp::odp_client(api_key = odp_api_key)
  
  # connect to dataset on ODP through the UUID
  odp_client <- client$dataset(uuid)
  
  # prepare the table for ODP
  odp_table <- odp_client$table
  
  ## inspect the data structure
  dplyr::glimpse(odp_ready_data)
  names(odp_ready_data)
  
  # construct the schema for the table that gets added to ODP
  schema <- arrow::schema(
    # build the schema based on the data
    odp_ready_data
  )
  
  # inspect schema
  schema
  
  # # create schema for the table
  # odp_table <- odp_table$create(schema)
  
  # generate table (defaults to the first table in the dataset)
  # drop the existing table
  odp_table$drop()
  
  # create with the table to repopulate
  odp_table$create(odp_ready_data)
}

############################
############################

#### 1. connect to ODP and obtain data

# ODP
## connect to client
# set up ODP API
## to find the API key or create one, navigate to: https://app.hubocean.earth/account
### Client (API key can come from ODP_API_KEY)
### API key saved in .Renvironment so retrieving through the Sys.getenv()
### this is so the API key is not public
odp_api_key <- Sys.getenv("odp_api_key")
client <- odp::odp_client(api_key = odp_api_key)

## load in dataset (see https://app.hubocean.earth/)
gustav_polygon <- client$dataset("4172129e-ed91-48ea-a4d6-6d838ff87626")$table$select()$all_dataframe() %>%
  # return first two rows
  dplyr::slice(1:2) %>%
  # detect and return observations that have the POLYGON pattern in the geometry field
  dplyr::filter(stringr::str_detect(pattern = "POLYGON",
                                    # in this field
                                    geometry)) %>%
  # set as sf column
  sf::st_as_sfc(x = .$geometry,
                # set the coordinate reference system to be WGS84 (epsg.io/4326)
                crs = 4326) %>%
  # convert to sf and set geometry
  sf::st_sf(geometry = .)

# inspect data
## class (sf, data.frame)
class(gustav_polygon)
## structure
str(gustav_polygon)
## data values
dplyr::glimpse(gustav_polygon)
## field names
names(gustav_polygon)

############################
############################

#### 2. build study area boundary box

# build study area
## Western Indian Ocean
wio_e <- 40
wio_w <- 51
wio_n <- -11
wio_s <- -15

## Western Indian Ocean boundary box
wio_points <- rbind(c("point", wio_e, wio_s), # southeastern point
                    c("point", wio_e, wio_n), # northeastern point
                    c("point", wio_w, wio_n), # northwestern point
                    c("point", wio_w, wio_s)) %>% # southwestern point
  # convert to data frame
  as.data.frame() %>%
  # rename column names
  dplyr::rename("point" = "V1",
                # longitude
                "lon" = "V2",
                # latitude
                "lat" = "V3") %>%
  # convert to simple feature -- using the longitude and latitude fields
  sf::st_as_sf(coords = c("lon", "lat"),
               # set the coordinate reference system to WGS84
               crs = "EPSG:4326")

############################

## interactive map viewer of the points
mapview::mapView(wio_points)

############################

# create polygon
wio_bbox <- wio_points %>%
  # group by the points field
  dplyr::group_by(point) %>%
  # combine geometries without resolving borders to create multipoint feature
  dplyr::summarise(geometry = st_combine(geometry)) %>%
  # convert back to sf
  sf::st_as_sf() %>%
  # convert to polygon simple feature
  sf::st_cast("POLYGON") %>%
  # convert back to sf
  sf::st_as_sf()

mapview::mapView(wio_bbox)

############################

## Mauritius points
mus_e <- 58.5
mus_w <- 56.5
mus_n <- -19.25
mus_s <- -21.25

## Mauritius boundary box
mus_points <- rbind(c("point", mus_e, mus_s), # southeastern point
                    c("point", mus_e, mus_n), # northeastern point
                    c("point", mus_w, mus_n), # northwestern point
                    c("point", mus_w, mus_s)) %>% # southwestern point
  # convert to data frame
  as.data.frame() %>%
  # rename column names
  dplyr::rename("point" = "V1",
                # longitude
                "lon" = "V2",
                # latitude
                "lat" = "V3") %>%
  # convert to simple feature
  sf::st_as_sf(coords = c("lon", "lat"),
               # set the coordinate reference system to WGS84
               crs = "EPSG:4326")

############################

# interactive view of Mauritius boundary box points
mapview::mapView(mus_points)

############################

# create polygon
mus_bbox <- mus_points %>%
  # group by the points field
  dplyr::group_by(point) %>%
  # combine geometries without resolving borders to create multipoint feature
  dplyr::summarise(geometry = st_combine(geometry)) %>%
  # convert back to sf
  sf::st_as_sf() %>%
  # convert to polygon simple feature
  sf::st_cast("POLYGON") %>%
  # convert back to sf
  sf::st_as_sf()

## check units for determining cellsize of grid (units will be in degrees)
sf::st_crs(mus_bbox, parameters = TRUE)$units_gdal

mapview::mapView(mus_bbox)

############################
############################

#### 3. obtain Mauritius coral data from RCMRD

## set the download path directory (should still be within your working directory)
## you might have to change this path directory for your computer
download_path <- "data"

# habitat data
## coral data (https://rcoe-geoportal.rcmrd.org/datasets/rcmrd::mauritius-coral-reefs/about)
### REST service: https://services6.arcgis.com/zOnyumh63cMmLBBH/arcgis/rest/services/Mauritius_Coral_Reefs/FeatureServer/0 
coral <- arcpullr::get_spatial_layer("https://services6.arcgis.com/zOnyumh63cMmLBBH/arcgis/rest/services/Mauritius_Coral_Reefs/FeatureServer/0") %>%
  # change to WGS 84 -- the CRS needed to ODP
  sf::st_transform(x = .,
                   # WGS84
                   crs = 4326) %>%
  # check to make sure all geometries are valid
  sf::st_make_valid() %>%
  # clean field names
  janitor::clean_names()

mapview::mapview(coral)

# check structure
str(coral)

############################
############################

#### 4. obtain coral reef data from Dawson et al. (2025)

## reef data (https://doi.pangaea.de/10.1594/PANGAEA.986811)
### navigate to data from Pangaea using the Pangaea R package (https://github.com/ropensci/pangaear)
table <- pangaear::pg_data(doi="10.1594/PANGAEA.986811")

### inspect the metadata
table[[1]]$metadata

### to download the data, they will are hosted at the end of this URL
prefix <- "https://download.pangaea.de/dataset/986811/files/"

### get files needed (a CSV of points, and shapefile)
files <- table[[1]]$data %>%
  # filter for files that fit files that we want (i.e., shapefiles and CSV)
  dplyr::filter(grepl(pattern = "Shapefiles|CSV",
                      # within the "Binary" column
                      x = .$Binary,
                      # ignore case
                      ignore.case = T))

### Alternative
# files <- table[[1]]$data[grep(pattern = "CSV|Shapefiles",
#                               x = table[[1]]$data$Binary,
#                               ignore.case = T), ]

### loop through the dataframe to download 
for (i in (1:nrow(files))){
  # download the files from the URL
  download.file(url = paste0(prefix, files$Binary[i]),
                # destination for the data will be in the data directory
               destfile = paste(download_path, files$Binary[i],
                                # separate with a "/"
                                sep = "/"))
}

### unzip the data
unzip(zipfile = "data/Shapefiles.zip",
      # output directory
      exdir = "data")

### inspect shapefiles
fs::dir_ls(path = "data/Shapefiles",
           # only inspect files that end with ".shp"
           glob = "*.shp")

############################
############################

#### 5. load in Dawson et al. (2025) coral data

# reef points 
reef_points <- readr::read_csv(file = "data/GRID.csv") %>%
  # clean the field names
  janitor::clean_names() %>%
  # set the geometry using the longitude and latitude fields
  sf::st_as_sf(coords = c("long", "lat"),
               # set the coordinate reference system to WGS84
               crs = "EPSG:4326")

# reef polygons
reef_polygons <- sf::st_read(dsn = "data/Shapefiles/GRID_polygons84.shp") %>%
  # clean field names
  janitor::clean_names() %>%
  # fix any geometry errors that may exist
  sf::st_make_valid()

############################
############################

#### 6. limiting data to study areas

# limit data to study regions
## Western Indian Ocean
reef_wio <- reef_polygons %>%
  # keep only reef data in the Western Indian Ocean boundary box
  rmapshaper::ms_clip(target = .,
                      # Western Indian Ocean boundary box
                      clip = wio_bbox)

# map data interactively
wio_map <- mapview::mapView(reef_wio,
                            # outline color
                            color = "coral",
                            # fill color
                            col.regions = "coral") +
  # Western Indian Ocean boundary box
  mapview::mapView(wio_bbox,
                   # transparency
                   alpha.regions = 0.1,
                   # legend
                   legend = F) +
  # reef data
  mapview::mapView(reef_polygons,
                   # fill color
                   col.regions = "#F0B778")

wio_bbox_map <- wio_map@map %>%
  # center on the boundary box
  leaflet::setView(lng = (wio_e - (wio_e - wio_w) / 2),
                   # latitude
                   lat = (wio_n - (wio_n - wio_s) / 2),
                   # zoom
                   zoom = 6)
wio_bbox_map

############################

## Mauritius
coral_mus <- coral %>%
  rmapshaper::ms_clip(target = .,
                      clip = mus_bbox)

mus_map <- mapview::mapView(coral_mus,
                            color = "coral",
                            col.regions = "coral") +
  mapview::mapView(mus_bbox,
                   alpha.regions = 0.1,
                   legend = F) +
  mapview::mapView(coral,
                   col.regions = "#F0B778")

# map zoomed into focused area
mus_bbox_map <- mus_map@map %>%
  # center on the boundary box
  leaflet::setView(lng = (mus_e - (mus_e - mus_w) / 2),
                   # latitude
                   lat = (mus_n - (mus_n - mus_s) / 2),
                   # zoom
                   zoom = 7)
mus_bbox_map

############################
############################

#### 7. Gustav's area

# Gustav's area of interest
mapview::mapView(gustav_polygon,
                 # transparency
                 alpha = 0.1,
                 # fill
                 col.regions = "#e1dbdf")

# Dawson et al. (2025) in Gustav's area of interest
gustav_reef <- reef_polygons %>%
  # clip data to polygon
  rmapshaper::ms_clip(target = .,
                      # clip polygon
                      clip = gustav_polygon)

# Mauritius data in Gustav's area of interest
gustav_coral <- coral %>%
  # clip data to polygon
  rmapshaper::ms_clip(target = .,
                      # clip polygon
                      clip = gustav_polygon)

############################
############################

#### 8. viewing data interactively

gustav_map <- mapview::mapView(gustav_reef,
                               # outline color
                               color = "coral",
                               # fill color
                               col.regions = "coral") +
  # coral data layer
  mapview::mapView(gustav_coral,
                   # outline color
                   col = "#f26770",
                   # fill color
                   col.regions = "#f26770") +
  # polygon data layer
  mapview::mapView(gustav_polygon,
                   # transparency
                   alpha.regions = 0.1,
                   # fill color
                   col.regions = "#e1dbdf",
                   # legend (F = do not show)
                   legend = F)

# view map
gustav_map

############################
############################

#### 9. ODP data preparation

## prepare the data for ODP
reef_wio_odp <- reef_wio %>%
  # change geometry to appropriate format (string)
  dplyr::mutate(geometry = sf::st_as_text(geometry))

coral_mus_odp <- coral_mus %>%
  # change geometry to appropriate format (string)
  dplyr::mutate(geometry = sf::st_as_text(geometry))

gustav_coral_odp <- gustav_coral %>%
  # change geometry to appropriate format (string)
  dplyr::mutate(geometry = sf::st_as_text(geometry))

############################
############################

#### 10. export data to ODP

### GRID points (Dawson et al. 2025)
reef_points_odp <- reef_points %>%
  # need to prepare data for ODP (dates are as POSIXct, but ODP needs them as character)
  dplyr::mutate(start_date = as.character(start_date),
                end_date = as.character(end_date),
                # make geometry a character
                geometry = sf::st_as_text(geometry)) %>%
  # run it to the ODP function
  odp_function(odp_ready_data = .,
               uuid = "4689ff6a-3689-498b-86c7-c7c93f112de9")

### GRID polygons (Dawson et al. 2025) 
reef_polygons_odp <- reef_polygons %>%
  # make geometry a character
  dplyr::mutate(geometry = sf::st_as_text(geometry)) %>%
  # run it to the ODP function
  odp_function(odp_ready_data = .,
               uuid = "553c9c0f-82e1-43b2-b93a-8d1a5a18cdc4")

### Mauritius coral data
coral_odp <- coral %>%
  # make geometry a character
  dplyr::mutate(geometry = sf::st_as_text(geoms)) %>%
  # drop old geometry field
  sf::st_drop_geometry() %>%
  # run it to the ODP function
  odp_function(odp_ready_data = .,
               uuid = "1dffbd89-8659-454c-bae4-651fd2f32422")

### created data in Gustav's polygon
odp_gustav_coral <- odp_function(odp_ready_data = gustav_coral_odp,
                                 uuid = "f9c2c585-4218-47ac-9b20-c73f23ace29d")

############################
############################

#### 11. aggregate data into H3 hexes (https://h3geo.org)

# make data as a table for aggregation
agg_table <- client$dataset("f9c2c585-4218-47ac-9b20-c73f23ace29d")$table

# aggregate based on a H3 level (only works for ODP hosted data)
agg <- agg_table$aggregate(
  # group at h3 level (can be anywhere between 1 and 15)
  ## for further information about H3 hex resolutions: https://h3geo.org/docs/core-library/restable
  group_by = "h3(geometry, 6)",
  # aggregate based on a field (e.g., geometry) and a summary function (e.g., count, sum, max, min, avg)
  aggr = list(geometry = "count")) %>%
  # change the name of the "geometry" field to be "count"
  dplyr::rename("count" = "geometry")

# check names
names(agg)

############################

# get H3 indexes
h3_indexes <- as.character(agg$group)

# create a sf (simple feature) of the data using the H3 index value
h3_sf <- h3_indexes %>%
  # convert to sf using H3 indexes
  h3::h3_to_geo_boundary_sf() %>%
  # change the field name of the group to be "h3_index"
  dplyr::rename("group" = "h3_index") %>%
  # join the two tables (x = H3 index dataset, y = counted table)
  # left join will add the y fields to the x field dataframe
  dplyr::left_join(x = ., # "." means use data that gets piped into this function came from the previous action
                   # dataframe to get added
                   y = agg,
                   # field to join the two tables by
                   by = "group")

############################

# visualize H3 hexagons with coral data
coral_maps <- mapview::mapView(gustav_reef,
                               # outline color
                               color = "coral",
                               # fill color
                               col.regions = "coral",
                               # legend name update
                               layer.name = "Reef") +
  # coral layer
  mapview::mapView(gustav_coral,
                   # outline color
                   col = "#f26770",
                   # fill color
                   col.regions = "#f26770",
                   # legend name update
                   layer.name = "Coral") +
  # polygon layer
  mapview::mapView(gustav_polygon,
                   # transparency
                   alpha.regions = 0.1,
                   # fill color
                   col.regions = "#e1dbdf",
                   # legend (F = not added)
                   legend = F) +
  # H3 hexes layer
  mapview::mapView(h3_sf,
                   # data field used for visualizing
                   zcol = "count",
                   # legend name
                   layer.name = "Count")

# view coral data and study area as interactive map
coral_maps

############################
############################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
