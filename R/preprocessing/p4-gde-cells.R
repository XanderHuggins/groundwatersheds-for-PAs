# Name: p4-gde-cells.R
# Description: Derive GDE grid cells by mosaicing root zone intersections, groundwater-driven wetlands, lakes, and perennial rivers and mask by protected areas.

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 
tmpFiles(current=TRUE, remove=TRUE) 

# import perennial rivers, HydroLAKES, and root zone intersections 
rivs = terra::rast("D:/Geodatabase/HydroSHEDS/perennial_1km_world_raw.tif")
laks = terra::rast("D:/Geodatabase/HydroSHEDS/hydrolakes_1km_AT.tif")
rzi = terra::rast(file.path(dat_loc, "World/rz_intersects_allmonth_binary.tif"))
cw_tci = terra::rast(file.path(dat_loc, "World/cw_tci_binary.tif"))
cw_wtd = terra::rast(file.path(dat_loc, "World/cw_wtd_binary.tif"))

# extend all rasters to same extent
rzi = terra::extend(rzi, laks)
cw_tci = terra::extend(cw_tci, laks)
cw_wtd = terra::extend(cw_wtd, laks)

# ensure all NAs are 0 for superimposing (already done for lakes)
rivs[is.nan(rivs)] = 0
rzi[is.nan(rzi)] = 0
cw_tci[is.nan(rzi)] = 0
cw_wtd[is.nan(rzi)] = 0

# mosaic together lentic ecosystems (i.e. wetlands, lakes)
lentic = terra::mosaic(cw_tci, cw_wtd, laks, fun = 'max')

# create a composite index raster for the type of GDE
gde_class = (rzi * 1e2) + (lentic * 1e1) + (rivs)

# 1xx : terrestrial GDE
# x1x : lentic aquatic GDE
# xx1 : lotic aquatic GDE

# write to file
terra::writeRaster(x = gde_class,
                   filename = file.path(dat_loc, "World/GDE_classes.tif"),
                   filetype = "GTiff", overwrite = T)

# create binary representation
gde_bin = gde_class
gde_bin[gde_bin >= 1] = 1
gde_bin[gde_bin != 1] = NA

terra::writeRaster(x = gde_bin,
                   filename = file.path(dat_loc, "World/GDE_binary.tif"),
                   filetype = "GTiff", overwrite = T)

# mask by protected areas raster
protplan = terra::rast(file.path(dat_loc,  "World/protected_areas_ID.tif"))

gde_bin_pa = gde_bin
gde_bin_pa[is.nan(protplan)] = NA

terra::writeRaster(x = gde_bin_pa,
                   filename = file.path(dat_loc, "World/GDE_binary_in_PA.tif"),
                   filetype = "GTiff", overwrite = T)