# Name: a1-groundwatersheds-delineation.R
# Description: Generate groundwatersheds for the world's protected areas using ecologically connected cells as outlets

# Set working directory and load necessary libraries
library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# loop through world regions individually
for (w in 1:length(world_regions)) {
  
  message(paste0("starting: ", world_regions[w], "..."))
  
  # import region-specific datasets
      wtelv_rgn <- terra::rast(file.path(wd, paste0("data/", world_regions[w], "/wt_elev.tif")))
      ecopp_rgn <- terra::rast(file.path(wd, paste0("data/", world_regions[w], "/ecologically_connected_cells.tif")))
      prot_area <- terra::rast(file.path(wd, paste0("data/", world_regions[w], "/protected_areas_ID.tif")))
      message(paste0("data import done"))
      
  # derive D8 flow direction raster
      whitebox::wbt_d8_pointer(dem = file.path(wd, paste0("data/", world_regions[w], "/wt_elev.tif")), 
                               output = file.path(wd, paste0("data/", world_regions[w], "/d8.tif")))
      message(paste0("raw d8 done"))
      
  # clean D8 by setting ocean values to NaN
      d8 <- terra::rast(file.path(wd, paste0("data/", world_regions[w], "/d8.tif")))
      d8[is.na(wtelv_rgn)] <- NaN
      terra::writeRaster(x = d8, 
                         filename = file.path(wd, paste0("data/", world_regions[w], "/d8_ocean_rm.tif")),
                         filetype = "GTiff",
                         overwrite = T)
      message(paste0("d8 cleaning done"))
      
  # identify ecologically connected areas and set to pour points vector file
      pp_p <- terra::as.points(ecopp_rgn) # Convert to points
      pp_ID <- terra::extract(x = prot_area, y = pp_p,  method = 'simple') # Extract FID per point
      pp_p$FID <- pp_ID$FID # Write to vector file
      pp_p$hydrorivers_1km_AT <- NULL # drop row ID
      terra::writeVector(pp_p, 
                         file.path(wd, paste0("data/", world_regions[w], "/pour_points_protected_contigID.shp")),
                         filetype = "ESRI Shapefile",
                         overwrite = T)
      message(paste0("pour points done"))
  
  # derive groundwatersheds using derived D8 flow direction raster and pour points
      whitebox::wbt_watershed(d8_pntr = file.path(wd, paste0("data/", world_regions[w], "/d8_ocean_rm.tif")), 
                              pour_pts = file.path(wd, paste0("data/", world_regions[w], "/pour_points_protected_contigID.shp")), 
                              output = file.path(wd, paste0("data/", world_regions[w], "/gwsheds_individual.tif")), 
                              esri_pntr = FALSE)
      message(paste0("individual groundwatersheds done"))
  
  # reclassify groundwatersheds based on WDPDA membership
      rcl_df <- data.frame(pp_ID$FID, 
                           pp_ID$ID)
      rcl_df$pp_ID.FID <- rcl_df$pp_ID.FID 
      colnames(rcl_df) <- NA
      
      readr::write_delim(x = rcl_df, 
                         file = file.path(wd, paste0("data/", world_regions[w], "/basin_assign.txt")), 
                         delim = ",", 
                         col_names = F)
    
      whitebox::wbt_reclass_from_file(input = file.path(wd, paste0("data/", world_regions[w], "/gwsheds_individual.tif")), 
                                      reclass_file = file.path(wd, paste0("data/", world_regions[w], "/basin_assign.txt")), 
                                      output = file.path(wd, paste0("data/", world_regions[w], "/gwsheds_cpa_grouped.tif")))
      message(paste0("contiguous protected area grouped groundwatersheds done"))
      
      print(paste0(world_regions[w], " complete!"))
  
}