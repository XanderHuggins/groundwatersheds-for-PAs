# Name: p4-eco-cells.R
# Description: Mosaic root zone intersections, groundwater-driven wetlands, lakes, and perennial rivers and mask by protected areas.

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import perennial rivers, HydroLAKES, and root zone intersections 
rivs = terra::rast("D:/Geodatabase/HydroSHEDS/perennial_1km_world_raw.tif")
laks = terra::rast("D:/Geodatabase/HydroSHEDS/hydrolakes_1km_AT.tif")
rzi = terra::rast(file.path(dat_loc, "World/rz_intersects_allmonth_binary.tif"))
cw_tci = terra::rast(file.path(dat_loc, "World/cw_tci_binary.tif"))
cw_wtd = terra::rast(file.path(dat_loc, "World/cw_wtd_binary.tif"))

rzi = terra::extend(rzi, rivs)
cw_tci = terra::extend(cw_tci, rivs)
cw_wtd = terra::extend(cw_wtd, rivs)

# mosaic together
eco_cells = terra::mosaic(rivs, laks, rzi, cw_tci, cw_wtd, fun = 'max')

terra::writeRaster(x = eco_cells,
                   filename = file.path(dat_loc, "World/eco_cells_binary_perrivs_rzi_wlands_lakes.tif"),
                   filetype = "GTiff", overwrite = T)

# mask by protected areas raster
eco_cells = terra::rast(file.path(dat_loc, "World/eco_cells_binary_perrivs_rzi_wlands_lakes.tif"))
protplan = terra::rast(file.path(dat_loc,  "World/protected_areas_ID.tif"))

eco_cells[is.nan(protplan)] = 0
eco_cells[eco_cells == 0] = NA

terra::writeRaster(x = eco_cells,
                   filename = file.path(dat_loc, "World/eco_cells_for_gwshed_pourpoints.tif"),
                   filetype = "GTiff", overwrite = T)
