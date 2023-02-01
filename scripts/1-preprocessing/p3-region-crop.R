# Name: p3-region-crop-.R
# Description: Crop core data for individual world regions, used for groundwatershed delineation

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# data to crop 
world_grdarea = terra::rast(file.path(dat_loc, "World/input/wgs-area-ras-30-arcsec.tif"))
world_protars = terra::rast(file.path(wdpa_wd,  "protected_areas_ID.tif"))
gde_pourpts   = terra::rast(file.path(dat_loc, "World/GDE_in_WDPA_high.tif"))
all_gdes      = terra::rast(file.path(dat_loc,  "World/GDE_1km_binary.tif"))

# loop through world regions
for (w in 1:length(world_regions)) {
  
  message(paste0("starting: ", world_regions[w], "..."))
  
  crop_ext = extent_ranges %>% 
    filter(Region == world_regions[w]) %>% 
    pull(Extents) 
  crop_ext = crop_ext[[1]]
  crop_ext
  
  # crop each global raster
  region_grdarea = terra::crop(x = world_grdarea,   y = crop_ext)
  region_protars = terra::crop(x = world_protars,   y = crop_ext)
  region_gdepp   = terra::crop(x = gde_pourpts,   y = crop_ext)
  region_gde     = terra::crop(x = all_gdes,   y = crop_ext)
  
  # ensure all masked by same layer
  mask  = terra::rast(paste0("D:/Geodatabase/Groundwater/Fan_depthtowatertable/Raw/Monthly_means/",
                             mask_folders[w], "_WTD_monthlymeans.nc"))
  
  mask = mask[[1]]
  ext(mask) = crop_ext
  
  region_grdarea[mask == 0] = NA
  region_protars[mask == 0] = NA
  region_gdepp[mask == 0] = NA
  region_gde[mask == 0] = NA
  
  # grid area
  terra::writeRaster(x = region_grdarea,
                     filename = file.path(dat_loc, world_regions[w], "grid_area.tif"),
                     filetype = "GTiff", overwrite = T)
  message(paste0("grid area done"))
  
  # protected area 
  terra::writeRaster(x = region_protars, 
                     filename = file.path(dat_loc, world_regions[w], "protected_areas_ID.tif"),
                     filetype = "GTiff", overwrite = T)
  message(paste0("protected areas done"))
  
  # gde pour points 
  terra::writeRaster(x = region_gdepp, 
                     filename = file.path(dat_loc, world_regions[w], "gde_pourpoint.tif"),
                     filetype = "GTiff", overwrite = T)
  message(paste0("ecologically connected cells for pour points are done"))
  
  # all groundwater-dependent ecosystems
  terra::writeRaster(x = region_gde,
                     filename = file.path(dat_loc, world_regions[w], "all_gde.tif"),
                     filetype = "GTiff", overwrite = T)
  message(paste0("all ecologically connected cells are done"))
  
  crop_ext = NULL # just to ensure crop_ext is not carried over to next region
  print(paste0(world_regions[w], " complete!"))
  
}