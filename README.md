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
  
View module 1 video [here](https://github.com/HUB-Ocean-Data/odp_classroom/blob/main/videos/module1/r_module1.mov)

**Module 2**

Further Resources
*R Packages*
* RColorBrewer
* sf
* 