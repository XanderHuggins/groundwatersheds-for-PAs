# Name: f4-si-uncertainty-mapping.R
# Description: Uncertainty maps of groundwatershed extents when considering monthly water tables.

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source))

# generate raster that shows number of months each grid cell is identified as part of a groundwatershed
for (w in 1:length(world_regions)) {

  for (m in 1:12) {
    gwshed_in = terra::rast(file.path(dat_loc, world_regions[w], paste0("gwsheds_individual_month_", m, ".tif")))
    
    gwshed_in[gwshed_in>1] = 1
    gwshed_in[is.na(gwshed_in)] = 0
    message("gwshed_in prepared")
    
    if (m == 1) {
      gwshed_counter = terra::rast(gwshed_in)
      gwshed_counter[] = 0 
      message("gwshed counter prepared")
    }
    
    gwshed_counter = gwshed_counter + gwshed_in
    message("gwshed counter updated for month")
    print(m)
  }
  
  terra::writeRaster(x = gwshed_counter, 
                     filename = file.path(dat_loc, world_regions[w], "gwshed_counter.tif"),
                     filetype = "GTiff",
                     overwrite = T)
  
  gwshed_in = gwshed_counter = NULL
}
