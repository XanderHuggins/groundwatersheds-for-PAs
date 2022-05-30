# Name: p4-eco-cells.R
# Description: Mosaic root zone intersections with lake and perennial river layers and mask by protected areas

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import perennial rivers, HydroLAKES, and root zone intersections 
rivs <- terra::rast("D:/Geodatabase/HydroSHEDS/perennial_1km_world_raw.tif")
laks <- terra::rast("D:/Geodatabase/HydroSHEDS/hydrolakes_1km_AT.tif")
rzi <- terra::rast(file.path(wd, paste0("data/World/rz_intersects_allmonth_binary.tif")))
rzi <- terra::extend(rzi, rivs)

# mosaic together
eco_cells <- terra::mosaic(rivs, laks, rzi, fun = 'max')

terra::writeRaster(x = eco_cells,
                   filename = file.path(wd, paste0("data/World/perennial-hydrosheds_rzi-min1_eco_cells_binary.tif")),
                   filetype = "GTiff", overwrite = T)

# mask by protected areas raster
protplan <- terra::rast(file.path(wd,  "data/World/protected_areas_ID.tif"))

eco_cells[is.nan(protplan)] <- 0
eco_cells[eco_cells == 0] <- NA

terra::writeRaster(x = eco_cells,
                   filename = file.path(wd, paste0("data/World/eco_cells_for_gwshed_pourpoints.tif")),
                   filetype = "GTiff", overwrite = T)