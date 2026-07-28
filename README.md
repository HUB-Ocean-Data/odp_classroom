# ODP in the Classroom

Here are resources for the R Modules within [HUB Ocean](https://www.hubocean.earth)'s ODP in the Classroom.

**Module 1:** Connecting to ODP, Pulling Data, Visualizing Data, and Exporting Back
In this module, you will become familiarized with the [Ocean Data Platform](https://app.hubocean.earth) and how to interact
with it in RStudio. Before beginning it will be helpful to create an API key. If you have not set up an API key yet, you can
do so [here](https://app.hubocean.earth/account) after having created an account.

To read more about the datasets used in the this module, here are a few resources:
* GLODAP: This database contains more than 50 years of ocean-based cruises collecting observation samples spanning the globe on biochemistry allowing with other key metadata (e.g., depth, time, spatial location).
Data hosted on the Ocean Data Platform come from [version 2 (2022)](https://glodap.info/index.php/merged-and-adjusted-data-product-v2-2022/).
Since then, there has been a [version 2 (2023)](https://glodap.info/index.php/merged-and-adjusted-data-product-v2-2022/) and the most current version ([version 3](https://glodap.info/index.php/merged-and-adjusted-data-product-v3/)).
Version 3 has 57 additional cruises. For a full list of past versions, they are hosted [here](https://glodap.info/index.php/previous-versions/).

* Protected Areas: Protection of the seascapes and ocean areas has increased over the last two decades, though it still lags behind terrestrial area-based protections.
Strength of protection also varies by country when new areas are getting designated. Only recently has a mechanism been agreed to that will permit creation of protection
areas in the high seas. Since no universal definitions have been accepted on protection, different trackers on protection have varying metrics on sizes and effectiveness.
The [World Database on Protected and Conserved Areas](https://www.protectedplanet.net/en) has 16.952 areas covering 9.8% of ocean coverage (July 2026).
[SkyTruth's 30x30](https://30x30.skytruth.org/progress-tracker?layers=eez,mpt&content={%22showDetails%22:true,%22tab%22:%22marine%22}) tracker gets its data from the WDPCA
though reports marine protection at 10% (July 2026). Interestingly, another tracker that relies on WDPCA data has an lower percentage on ocean protection. Marine Conservation Institute's
[MPAtlas](https://mpatlas.org/mpaguide/) estimates that some level of protection covers 9.3% of the ocean (July 2026). This analysis implements ProtectedSeas Navigator's [dataset](https://map.navigatormap.org)
to visualize marine protected areas and their [IUCN protection categories](https://portals.iucn.org/library/sites/library/files/documents/pag-021.pdf).

  - Section 1:  Install packages
  - Section 2:  Connect to ODP
  - Section 3:  Ingest data to R Environment
  - Section 4:  Inspect data
  - Section 5:  Convert to sf
  - Section 6:  Interactive map
  - Section 7:  Static map -- plot 1
  - Section 8:  Static map -- plot 2
  - Section 9:  Create directories
  - Section 10: Export figures 
  - Section 11: Export data
  - Section 12: Export to ODP
  


**Module 2:** Building upon Module 1, this module will let you interact with pulling and exporting data to ODP. Additionally,
you will start to use geospatial packages (sf and rmapshaper) to conduct data manipulations for visualizing coral reef data in
the Western Indian Ocean. For these data, you will learn how to leverage ODP, its server, and the R SDK to aggregate data by an
[H3 hex grid](https://h3geo.org).

Module 2 relied on two datasets hosted elsewhere from ODP. The first data are [Mauritius coral data](https://rcoe-geoportal.rcmrd.org/search?collection=dataset&layout=grid&sort=Date%20Updated%7Cmodified%7Cdesc&tags=seascape) from the [Regional Center
of Excellence for Biodiversity, Forests & Seascapes for Eastern and Southern Africa](https://rcoe-geoportal.rcmrd.org) (RCoE-ESA). Its [geoportal](https://rcoe-geoportal.rcmrd.org/search?collection=dataset) hosts [data
on seascapes](https://rcoe-geoportal.rcmrd.org/search?collection=dataset&layout=grid&sort=Date%20Updated%7Cmodified%7Cdesc&tags=seascape) for the region through an ArcGIS REST API.

Additional data for the region were hosted on Pangaea by [Dawson et al. (2025)](https://doi.pangaea.de/10.1594/PANGAEA.986811). This database on global reef islands contained low-lying reef boundaries and points.

  - Section 0:  Create function (ODP exporting)
  - Section 1:  Connect to ODP
  - Section 2:  Build boundary box
  - Section 3:  Obtain data from ArcGIS REST API
  - Section 4:  Obtain data from Pangaea
  - Section 5:  Load data from Pangaea
  - Section 6:  Clip data to regional boundary box
  - Section 7:  Clip data to area of interest boundary box
  - Section 8:  Interactive mapping
  - Section 9:  ODP data preparation
  - Section 10: Export data to ODP
  - Section 11: Aggregate on H3 hexagons

**Further Resources**

*Videos*
* View module 1 video [here](https://github.com/HUB-Ocean-Data/odp_classroom/blob/main/videos/module1/r_module1.mov) (13 minutes 43 seconds)
* View module 2 video [here](https://github.com/HUB-Ocean-Data/odp_classroom/tree/main/videos/module2) (17 minutes 09 seconds)
* Module 1 segment videos are within the [Module 1 videos sub-directory](https://github.com/HUB-Ocean-Data/odp_classroom/tree/main/videos/module1). All of the videos are there except for segment 11

*Ocean Data Platform*
* [ODP R SDK GitHub](https://github.com/C4IROcean/odp-sdkr)
* [ODP R SDK guide](https://docs.hubocean.earth/reference/sdk/)
* [GLODAP v2](https://app.hubocean.earth/catalog/dataset/aea06582-fc49-4995-a9a8-2f31fcc65424/global-ocean-data-analysis-project-glodap-data)
* [Protected Seas: Focused Area-Based Protections](https://app.hubocean.earth/catalog/dataset/a608f54b-75c7-4df9-a3a8-cedbfa391873/protectedseas-navigator-v2-focused-area-based-protections)
* [ODP Classroom data collection](https://app.hubocean.earth/data_collections/cf8af38f-ec1d-4c84-87af-53a0a0e10880/odp-classroom)

*R Packages*
* [sf](https://r-spatial.github.io/sf/) -- powerful geospatial functions ([cheatsheet](https://rstudio.github.io/cheatsheets/sf.pdf))
* [tidyverse](https://tidyverse.org/packages/) -- suite of packages, including [dplyr](https://dplyr.tidyverse.org) ([cheatsheet](https://github.com/rstudio/cheatsheets/blob/main/data-transformation.pdf)), [ggplot2](https://ggplot2.tidyverse.org) ([cheatsheet](https://github.com/rstudio/cheatsheets/blob/main/data-visualization.pdf)), [readr](https://readr.tidyverse.org) ([cheatsheet](https://github.com/rstudio/cheatsheets/blob/main/data-import.pdf)), [stringr](https://stringr.tidyverse.org) ([cheatsheet](https://github.com/rstudio/cheatsheets/blob/main/strings.pdf))
* [mapview](https://r-spatial.github.io/mapview/index.html)-- interactive mapping
* [h3](https://crazycapivara.github.io/h3-r/index.html) -- ability to create and use H3 grids
* [rnaturalearth](https://docs.ropensci.org/rnaturalearth/articles/rnaturalearth.html) -- pull data from [Natural Earth](https://www.naturalearthdata.com), a collated standardized data catalogue 
* [pangaear](https://docs.ropensci.org/pangaear/index.html) -- pull data from [Pangaea](https://www.pangaea.de) 
* [arcpullr](https://pfrater.github.io/arcpullr/index.html) -- pull data from ArcGIS REST APIs
* [rmapshaper](https://andyteucher.ca/rmapshaper/index.html) -- useful spatial package that has some more familiar tools to those who use ArcGIS and QGIS; built on [mapshaper](https://mapshaper.org), which a helpful resource on converting and working with a range of spatial data formats
* [RColorBrewer](https://cran.r-project.org/web/packages/RColorBrewer/RColorBrewer.pdf) -- package that provides templates designed by Cynthia Brewer at PSU ([website](https://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3)); NCEAS's [cheatsheet](https://www.nceas.ucsb.edu/sites/default/files/2020-04/colorPaletteCheatsheet.pdf) and a different [guide](https://r-graph-gallery.com/38-rcolorbrewers-palettes.html) on color palettes

*Sites*
* [Pangaea](https://www.pangaea.de) -- location for researchers to share and dessiminate their data