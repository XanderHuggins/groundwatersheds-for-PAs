# Name: p5-region-cropping-core-gwshed-data.R
# Description: Crop core data for groundwatershed delineation for each world region

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# data to crop 
world_grdarea <- terra::rast(file.path(wd, "data/World/input/wgs-area-ras-30-arcsec.tif"))
world_protars <- terra::rast(file.path(wdpa_wd, "protected_areas_ID.tif"))
eco_cells_pp <- terra::rast(file.path(wd, paste0("data/World/eco_cells_for_gwshed_pourpoints.tif")))

# loop through world regions
for (w in 1:length(world_regions)) {
  
  message(paste0("starting: ", world_regions[w], "..."))
  
  crop_ext <- extent_ranges %>% 
    filter(Region == world_regions[w]) %>% 
    pull(Extents) 
  crop_ext <- crop_ext[[1]]
  crop_ext
  
  region_grdarea <- terra::crop(x = world_grdarea,   y = crop_ext)
  region_protars <- terra::crop(x = world_protars,   y = crop_ext)
  region_ecocond <- terra::crop(x = eco_cells_pp,   y = crop_ext)
  
  # ensure all masked by same layer
  mask  <- terra::rast(paste0("D:/Geodatabase/Groundwater/Fan_depthtowatertable/Raw/Monthly_means/",
                              mask_folders[w], "_WTD_monthlymeans.nc"))
  
  mask <- mask[[1]]
  ext(mask) <- crop_ext
  
  region_grdarea[mask == 0] <- NA
  region_protars[mask == 0] <- NA
  region_ecocond[mask == 0] <- NA
  
  # grid area cropping
    terra::writeRaster(x = region_grdarea, 
                       filename = file.path(wd, paste0("data/", world_regions[w], "/grid_area.tif")),
                       filetype = "GTiff", overwrite = T)
    message(paste0("grid area done"))
  
  # protected area cropping
    terra::writeRaster(x = region_protars, 
                       filename = file.path(wd, paste0("data/", world_regions[w], "/protected_areas_ID.tif")),
                       filetype = "GTiff", overwrite = T)
    message(paste0("protected areas done"))
    
  # ecologically connected pour points cropping
    terra::writeRaster(x = region_ecocond, 
                       filename = file.path(wd, paste0("data/", world_regions[w], "/ecologically_connected_cells.tif")),
                       filetype = "GTiff", overwrite = T)
    message(paste0("ecologically connected cells for pour points are done"))

  crop_ext <- NULL # just to ensure crop_ext is not carried over to next region
  print(paste0(world_regions[w], " complete!"))
  
}