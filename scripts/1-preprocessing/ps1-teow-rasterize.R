# Name: ps1-teow-rasterize.R
# Description: Convert terrestrial ecoregion shapefile to unique id raster at 30 arc-second

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

teow = terra::vect("D:/Geodatabase/Ecological/Ecoregions/Terrestrial/wwf_terr_ecos.shp")
teow_r = terra::rasterize(x = teow, 
                           y = terra::rast(file.path(dat_loc, "World/input/wgs-area-ras-30-arcsec.tif")),
                           field = "ECO_ID",
                           touches = TRUE)
writeRaster(teow_r, "D:/Geodatabase/Ecological/Ecoregions/Terrestrial/teow_1km.tif", overwrite = T)