# Name: p1-slope-preparation.R
# Description: Generate global surface slope raster for post-hoc analysis of groundwatersheds

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# generate slope raster per world region using base 30 arc-second DEM
for (w in 1:length(world_regions)) {
  
  message(paste0("starting: ", world_regions[w], "..."))
  
  dem <- terra::rast(paste0("D:/Geodatabase/Terrain/wtddata/", topo_folders[w], "_TOPO.nc"))

  terra::terrain(x = dem, 
                 v = "slope", 
                 neighbors = 8,
                 unit = "degrees",
                 filename = file.path(wd, paste0("data/", world_regions[w], "/terra_slope.tif")),
                 overwrite = T)
}