# Name: p3-max-root-depth-elev.R
# Description: Convert rooting depths to elevations. 

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

for (i in 1:length(topo_folders)) {
  topo_in = terra::rast(paste0("D:/Geodatabase/Terrain/wtddata/", topo_folders[i], "_TOPO.nc"))
  mrd_in  = terra::rast(paste0("D:/Geodatabase/Rooting-depth/Raw/maxroot_", rd_names[i], "_CF.nc"))
  
  # ensure extents are snapped and identical
  set_ext = extent_ranges %>% 
    filter(Region == extent_ranges$Region[i]) %>% 
    pull(Extents) %>% 
    unlist()
  
  ext(topo_in) = set_ext[[1]]
  ext(mrd_in) = set_ext[[1]]
  
  # convert
  mrd_elev = topo_in - mrd_in # derive max root depth elevation by subtracting root depth from DEM
  
  terra::writeRaster(x = mrd_elev, 
                     filename = file.path(dat_loc, world_regions[i], "max_rd_elev.tif"),
                     filetype = "GTiff", overwrite = T)
  message(paste0(wr_folders[i], " max root depth elev is done :) "))
}