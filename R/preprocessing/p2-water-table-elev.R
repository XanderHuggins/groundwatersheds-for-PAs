# Name: p2-water-table-elev.R
# Description: Convert mean annual water table depth data to water table elevation

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# step 1: perform this conversion for the mean annual water table depth (for main analysis) ----
for (i in 1:length(topo_folders)) {
  # import land surface elevation (topo) and water table depth (wtd)
  topo_in = terra::rast(paste0("D:/Geodatabase/Groundwater/Fan_WTD/annualmeans/", topo_folders[i], "_TOPO.nc"))
  wtd_in  = terra::rast(paste0("D:/Geodatabase/Groundwater/Fan_WTD/annualmeans/", topo_folders[i], "_WTD_annualmean.nc"))
  
  # ensure extents are snapped and identical
  set_ext = extent_ranges %>% 
    filter(Region == extent_ranges$Region[i]) %>% 
    pull(Extents) %>% 
    unlist()
  
  ext(topo_in) = set_ext[[1]]
  ext(wtd_in) = set_ext[[1]]
  
  # convert water table dpeth to an elevation
  wtelev = topo_in + wtd_in[[2]] # add because wtd is negative (i.e. -100m is 100 mbgs)
  
  wtelev[wtd_in[[1]] == 0] = NA # apply world region mask to water table depth raster
  
  terra::writeRaster(x = wtelev, 
                     filename = file.path(dat_loc, world_regions[i], "wt_elev.tif"),
                     filetype = "GTiff", overwrite = T)
  message(paste0(wr_folders[i], " WT elev is done"))
}


# step 2: repeat this conversion for the monthly water table depths (used in sensitivity analysis) ----
for (i in 1:length(mask_folders)) {
  
  # loop through each month
  for (m in 1:12) {  
    
    topo_in = terra::rast(paste0("D:/Geodatabase/Groundwater/Fan_WTD/annualmeans/",  topo_folders[i], "_TOPO.nc"))
    wtd_in  = terra::rast(paste0("D:/Geodatabase/Groundwater/Fan_WTD/monthlymeans/", mask_folders[i], "_WTD_monthlymeans.nc"))
    
    # ensure extents are snapped and identical
    set_ext = extent_ranges %>% 
      filter(Region == extent_ranges$Region[i]) %>% 
      pull(Extents) %>% 
      unlist()
    
    ext(topo_in) = set_ext[[1]]
    ext(wtd_in) = set_ext[[1]]
    
    # convert (need m+1 because first layer of wtd_in is a land mask)
    wtelev = topo_in + wtd_in[[m+1]] # add because wtd is negative (i.e. -100m is 100 mbgs)
    
    wtelev[wtd_in[[1]] == 0] = NA # apply world region mask to water table depth raster
    
    terra::writeRaster(x = wtelev, 
                       filename = file.path(dat_loc, world_regions[i], paste0("wt_elev_month_", m, ".tif")),
                       filetype = "GTiff", overwrite = T)
    message(paste0(world_regions[i], " month ", m, " is done"))
    
    wtelev = topo_in = wtd_in = NULL
    
  }
}