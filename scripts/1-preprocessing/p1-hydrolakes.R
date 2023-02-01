# Name: p1-hydrolakes.R
# Description: Generate raster representation of HydroLAKES

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

gdalUtilities::gdal_rasterize(src_datasource = "D:/Geodatabase/HydroSHEDS/HydroLAKES_polys_v10_shp/HydroLAKES_polys_v10.shp",
                              dst_filename = "D:/Geodatabase/HydroSHEDS/hydrolakes_1km_binary_alltouch.tif",
                              at = T,
                              burn = 1,
                              tr = c((1/120), (1/120)),
                              te = c(-180, -90, 180, 90))
