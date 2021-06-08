# identify where to establish pour points
# which would be where (1) there are protected places, (2) the root zone is below the water table

library(tidyverse)
library(terra)

# Import all iucn categories
iucn_rs <- list.files('D:/!! Geodatabase/Biodiversity-Ecosystems/WDPA/Groundwatersheds/', 
                      pattern = "*.tif")

for (i in 1:length(iucn_rs)) {
    temp_in <- terra::rast(paste0('D:/!! Geodatabase/Biodiversity-Ecosystems/WDPA/Groundwatersheds/',
                                  iucn_rs[i], sep = ''))
    if (i == 1) {
        iucn_ras <- temp_in
    } else {
        iucn_ras <- c(iucn_ras, temp_in)   
    }
}

# add all together
iucn_sum <- app(iucn_ras, fun = sum, na.rm = T)

terra::writeRaster(iucn_sum, 
                   "D:/!! Geodatabase/Biodiversity-Ecosystems/WDPA/Groundwatersheds/Sum/iucn_sum.tif")

# Identify where root zone intersects water table
wt_elev <- terra::rast('D:/!! Geodatabase/Groundwater/Fan_depthtowatertable/Processed/WT_elevation.tif')
rz_elev <- terra::rast('D:/!! Geodatabase/Rooting-depth/Root-elevation-masl.tif')


# pour-point rasters are (1) ecologically connected and (2) in protected areas
pp_ras <- rast(iucn_sum) # initialize
pp_ras[rz_elev < wt_elev & iucn_sum >= 1] <- 1 

plot(pp_ras)

terra::writeRaster(pp_ras, 
                   "D:/!! Geodatabase/Groundwater/Groundwatersheds/iucn_ecol_conn.tif")

pp_vect <- terra::as.points(pp_ras)

terra::writeVector(pp_vect,
                   'D:/!! Geodatabase/Groundwater/Groundwatersheds/iucn_ecol_conn.shp')

## checking below to see the number of pour-points being generated
# sum_r <- terra::aggregate(x = pp_ras, fact = 60, fun = sum, na.rm = T)
# sum(sum_r[], na.rm = T)/1e6
# ~2.2 million pour points ... 