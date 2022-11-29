# Name: p2-protected-areas.R
# Description: Flatten global map of protected areas into global raster of spatially contiguous protected areas with unique identifiers

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# step 1: WDPA data comes in 3 extraction sets. Loop through each, export subsets, and then merge.
for (i in 1:3) {
  
  # read in batch of WDPA protected areas
  wdpa_t = sf::read_sf(paste0("D:/Geodatabase/Ecological/WDPA/Extracted_", i, 
                               "/WDPA_Jun2021_Public_shp-polygons.shp"))
  message("shapefile imported")
  
  # strings for "high" levels of protection
  keep_classes_high = c("Ia", "Ib", "II", "III", "Not Reported", "Not Assigned")
  
  # filter for these high levels
  wdpa_t_high = wdpa_t %>% 
    filter(IUCN_CAT %in% keep_classes_high) %>% 
    filter(GIS_AREA > 1) # filter also by reported surface area as min. 1 km2
  
  # strings for "low" levels of protection
  keep_classes_low = c("IV", "V", "VI", "Not Applicable")
  
  # filter for these low levels
  wdpa_t_low = wdpa_t %>% 
    filter(IUCN_CAT %in% keep_classes_low) %>% 
    filter(GIS_AREA > 1) # filter also by reported surface area as min. 1 km2
  
  message("classes filtered")
  
  # write sets of both low and high levels of protection
  sf::st_write(obj = wdpa_t_high, 
               dsn = file.path(wdpa_wd),
               layer = paste0("iucn_", i, "_1to3.shp"),
               driver = "ESRI Shapefile")
  
  sf::st_write(obj = wdpa_t_low, 
               dsn = file.path(wdpa_wd),
               layer = paste0("iucn_", i, "_4to6.shp"),
               driver = "ESRI Shapefile")
  
  message(paste0("shapefile written; loop ", i, " has finished successfully..."))
}

# step 2: rasterize shapefiles exported above (this step could benefit from parallelization, though not implemented here)

# loop through each batch
for (j in 1:3) {
  gdalUtils::gdal_rasterize(src_datasource = file.path(wdpa_wd, paste0("iucn_", j, "_1to3.shp")), 
                            dst_filename = file.path(wdpa_wd,  paste0("iucn_wdpa", j, "_1to3.tif")), 
                            at = TRUE,
                            burn = 1,
                            te = c(-180, -90, 180, 90),
                            tr = c((1/120), (1/120)))
  
  gdalUtils::gdal_rasterize(src_datasource = file.path(wdpa_wd, paste0("iucn_", j, "_4to6.shp")), 
                            dst_filename   = file.path(wdpa_wd,  paste0("iucn_wdpa", j, "_4to6.tif")), 
                            at = TRUE,
                            burn = 1,
                            te = c(-180, -90, 180, 90),
                            tr = c((1/120), (1/120)))
  
  message(paste0("batch ", j, " has successfully converted to raster"))
}

# import each raster of high protection
wdpa_r1 = terra::rast(file.path(wdpa_wd,  "iucn_wdpa1_1to3.tif"))
wdpa_r2 = terra::rast(file.path(wdpa_wd,  "iucn_wdpa2_1to3.tif"))
wdpa_r3 = terra::rast(file.path(wdpa_wd,  "iucn_wdpa3_1to3.tif"))

# combine into one binary raster
wdpa_r_all = wdpa_r1+wdpa_r2+wdpa_r3
wdpa_r_all[wdpa_r_all>=1] = 1
wdpa_r_all[wdpa_r_all != 1] = NA

terra::writeRaster(x = wdpa_r_all, 
                   filename = file.path(wdpa_wd,  "protected_areas_classes_13_filtered_ATgrids.tif"),
                   filetype = "GTiff",
                   overwrite = T)

# clean variables for re-use below
wdpa_r1 = wdpa_r2 = wdpa_r3 = wdpa_r_all = NULL

# import each raster of low protection 
wdpa_r1 = terra::rast(file.path(wdpa_wd,  "iucn_wdpa1_4to6.tif"))
wdpa_r2 = terra::rast(file.path(wdpa_wd,  "iucn_wdpa2_4to6.tif"))
wdpa_r3 = terra::rast(file.path(wdpa_wd,  "iucn_wdpa3_4to6.tif"))

# combine into one binary raster
wdpa_r_all = wdpa_r1+wdpa_r2+wdpa_r3
wdpa_r_all[wdpa_r_all >= 1] = 1
wdpa_r_all[wdpa_r_all != 1] = NA

terra::writeRaster(x = wdpa_r_all, 
                   filename = file.path(wdpa_wd,  "protected_areas_classes_46_filtered_ATgrids.tif"),
                   filetype = "GTiff",
                   overwrite = T)

# mask out oceans for each protected area tile set
wdpa_13 = terra::rast(file.path(wdpa_wd,  "protected_areas_classes_13_filtered_ATgrids.tif"))
wdpa_46 = terra::rast(file.path(wdpa_wd,  "protected_areas_classes_46_filtered_ATgrids.tif"))
mask = terra::rast(file.path(wdpa_wd,  "land_mask.tif"))

wdpa_13[mask != 1] = NA
wdpa_46[mask != 1] = NA

wdpa_13[is.na(mask)] = NA
wdpa_46[is.na(mask)] = NA

wdpa_46[wdpa_13 == 1] = NA # in case there are cells with overlap, let cell be represented by higher protection class

terra::writeRaster(x = wdpa_13, 
                   filename = file.path(wdpa_wd,  "protected_areas_classes_13_filtered_AT_land.tif"),
                   filetype = "GTiff",
                   overwrite = T)

terra::writeRaster(x = wdpa_46, 
                   filename = file.path(wdpa_wd,  "protected_areas_classes_46_filtered_AT_land.tif"),
                   filetype = "GTiff",
                   overwrite = T)

# identify contiguous "high" protected areas by dissolving polygons and provide each with a unique ID 
wdpa_v = terra::as.polygons(x = wdpa_13, dissolve = T)
wdpa_v = terra::disagg(wdpa_v)
wdpa_v$FID = seq(1, nrow(wdpa_v))

terra::writeVector(wdpa_v, 
                   file.path(wdpa_wd, "contiguous_protected_areas.shp"),
                   filetype = "ESRI Shapefile",
                   overwrite = T)

# import world grid area as raster template, and rasterize the protected areas with unique ID values
world_grdarea = terra::rast(file.path(wd, "data/World/input/wgs-area-ras-30-arcsec.tif"))

wdpa_r_FID = terra::rasterize(x = wdpa_v, y = world_grdarea, field = 'FID')

terra::writeRaster(x = wdpa_r_FID, 
                   filename = file.path(wdpa_wd,  "protected_areas_ID.tif"),
                   filetype = "GTiff",
                   overwrite = T)