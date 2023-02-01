# Name: p2-gde-cells.R
# Description: Derive GDE grid cells

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# import perennial rivers, HydroLAKES, and root zone intersections 
rivs = terra::rast("D:/Geodatabase/HydroSHEDS/perennial_1km_world_binary.tif")
laks = terra::rast("D:/Geodatabase/HydroSHEDS/hydrolakes_1km_binary_alltouch.tif")
rzi = terra::rast(file.path(dat_loc, "World/rz_intersects_allmonth_binary.tif"))
cw_tci = terra::rast(file.path(dat_loc, "World/cw_tci_binary.tif"))
cw_wtd = terra::rast(file.path(dat_loc, "World/cw_wtd_binary.tif"))

# extend all rasters to same extent
rzi = terra::extend(rzi, laks)
cw_tci = terra::extend(cw_tci, laks)
cw_wtd = terra::extend(cw_wtd, laks)

# ensure all NAs are 0 for superimposing (already done for lakes)
rzi[is.na(rzi)] = 0
cw_tci[is.na(cw_tci)] = 0
cw_wtd[is.na(cw_wtd)] = 0

# mosaic together lentic ecosystems (i.e. wetlands, lakes)
lentic_stack = c(cw_tci, cw_wtd, laks)
lentic = max(lentic_stack)

# create a composite index raster for the type of GDE
gde_class = (rzi * 1e2) + (lentic * 1e1) + (rivs)

# 1xx : terrestrial GDE
# x1x : lentic aquatic GDE
# xx1 : lotic aquatic GDE

# write to file
terra::writeRaster(x = gde_class,
                   filename = file.path(dat_loc, "World/GDE_classification_composite.tif"),
                   filetype = "GTiff", overwrite = T)

# create binary representation
gde_bin = gde_class
gde_bin[gde_bin >= 1] = 1
gde_bin[gde_bin != 1] = NA

terra::writeRaster(x = gde_bin,
                   filename = file.path(dat_loc, "World/GDE_1km_binary.tif"),
                   filetype = "GTiff", overwrite = T)


gde_bin = terra::rast(file.path(dat_loc, "World/GDE_1km_binary.tif"))

# mask by protected areas raster
wdpa_13 = terra::rast(file.path(wdpa_wd,  "protected_areas_ID.tif"))
gde_bin_pa = gde_bin
gde_bin_pa[is.na(wdpa_13)] = NA

terra::writeRaster(x = gde_bin_pa,
                   filename = file.path(dat_loc, "World/GDE_in_WDPA_high.tif"),
                   filetype = "GTiff", overwrite = T)