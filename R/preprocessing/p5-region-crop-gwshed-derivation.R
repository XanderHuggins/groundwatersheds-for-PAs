# Name: p5-region-crop-gwshed-derivation.R
# Description: Crop core data for groundwatershed delineation for each world region.

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# data to crop 
world_grdarea = terra::rast(file.path(dat_loc, "World/input/wgs-area-ras-30-arcsec.tif"))
world_protars = terra::rast(file.path(dat_loc, "World/protected_areas_ID.tif"))
eco_cells_pp = terra::rast(file.path(dat_loc,  "World/eco_cells_for_gwshed_pourpoints.tif"))
all_eco_cell = terra::rast(file.path(dat_loc,  "World/eco_cells_binary_perrivs_rzi_wlands_lakes.tif"))

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
  region_ecocond = terra::crop(x = eco_cells_pp,   y = crop_ext)
  region_alleco  = terra::crop(x = all_eco_cell,   y = crop_ext)
  
  # ensure all masked by same layer
  mask  = terra::rast(paste0("D:/Geodatabase/Groundwater/Fan_depthtowatertable/Raw/Monthly_means/",
                              mask_folders[w], "_WTD_monthlymeans.nc"))
  
  mask = mask[[1]]
  ext(mask) = crop_ext
  
  region_grdarea[mask == 0] = NA
  region_protars[mask == 0] = NA
  region_ecocond[mask == 0] = NA
  region_alleco[mask == 0] = NA
  
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
    
  # ecologically connected pour points 
    terra::writeRaster(x = region_ecocond, 
                       filename = file.path(dat_loc, world_regions[w], "ecologically_connected_cells.tif"),
                       filetype = "GTiff", overwrite = T)
    message(paste0("ecologically connected cells for pour points are done"))
    
  # all ecologically connected cells 
  terra::writeRaster(x = region_alleco, 
                     filename = file.path(dat_loc, world_regions[w], "all_ecological_areas.tif"),
                     filetype = "GTiff", overwrite = T)
  message(paste0("all ecologically connected cells are done"))

  crop_ext = NULL # just to ensure crop_ext is not carried over to next region
  print(paste0(world_regions[w], " complete!"))
  
}
