# Name: p2-water-table-elev.R
# Description: Convert mean annual water table depth data to water table elevation

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

for (i in 1:length(topo_folders)) {
  topo_in = terra::rast(paste0("D:/Geodatabase/Terrain/wtddata/", topo_folders[i], "_TOPO.nc"))
  wtd_in  = terra::rast(paste0("D:/Geodatabase/Terrain/wtddata/", topo_folders[i], "_WTD_annualmean.nc"))
  
  # ensure extents are snapped and identical
  set_ext = extent_ranges %>% 
    filter(Region == extent_ranges$Region[i]) %>% 
    pull(Extents) %>% 
    unlist()
  
  ext(topo_in) = set_ext[[1]]
  ext(wtd_in) = set_ext[[1]]
  
  # convert
  wtelev = topo_in + wtd_in[[2]] # add because wtd is negative (i.e. -100m is 100 mbgs)
  
  wtelev[wtd_in[[1]] == 0] = NA # apply world region mask to water table depth raster
  
  terra::writeRaster(x = wtelev, 
                     filename = file.path(wd, paste0("data/", world_regions[i], "/wt_elev.tif")),
                     filetype = "GTiff", overwrite = T)
  message(paste0(wr_folders[i], " WT elev is done"))
}