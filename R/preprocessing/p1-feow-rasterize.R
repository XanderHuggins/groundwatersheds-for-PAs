# Name: p1- feow-rasterize.R
# Description: Convert freshwater ecoregions of the world to unique id raster at 30 arc-seconds

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

feow = terra::vect("D:/Geodatabase/Ecological/Ecoregions/Freshwater/feow_hydrosheds.shp")
feow_r = terra::rasterize(x = feow, 
                           y = terra::rast(file.path(wd, "data/World/input/wgs-area-ras-30-arcsec.tif")),
                           field = "FEOW_ID",
                           touches = TRUE)
writeRaster(feow_r, "D:/Geodatabase/Ecological/Ecoregions/Freshwater/feow_1km.tif", overwrite = T)