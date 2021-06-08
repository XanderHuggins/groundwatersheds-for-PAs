# import some libraries
library(tidyverse) # for general functionality
library(terra) # for spatial functions
library(fasterize)
library(sf)

# Import three files comprising WDPA -- these will take several minutes to import
wdpa_1 <- sf::read_sf("D:/!! Geodatabase/Biodiversity-Ecosystems/WDPA/Extracted_1/WDPA_Jun2021_Public_shp-polygons.shp")
wdpa_2 <- sf::read_sf("D:/!! Geodatabase/Biodiversity-Ecosystems/WDPA/Extracted_2/WDPA_Jun2021_Public_shp-polygons.shp")
wdpa_3 <- sf::read_sf("D:/!! Geodatabase/Biodiversity-Ecosystems/WDPA/Extracted_3/WDPA_Jun2021_Public_shp-polygons.shp")

# merge and create flag for rasterizing
wdpa_merge <- rbind(wdpa_1, wdpa_2, wdpa_3)
wdpa_merge$flag <- 1 

# Isolate individual types of IUCN categories
# loop through these individually, for Ia, Ib, II, III, Not Reported, Not Assigned
iucn_ss <- wdpa_merge %>% filter(IUCN_CAT == 'Not Assigned' & REP_AREA > 10) %>% terra::vect()

# Import raster as base for rasterizing
temp_ras <- terra::rast('D:/!! Geodatabase/Groundwater/Fan_depthtowatertable/Processed/WT_elevation.tif')

# Rasterize each of the IUCN categories
iucn_ss_r <- terra::rasterize(x = iucn_ss, y = temp_ras, field = 'flag')

# write these rasters so don't need to repeat above
terra::writeRaster(iucn_ss_r, 
                   "D:/!! Geodatabase/Biodiversity-Ecosystems/WDPA/Groundwatersheds/iucn_NA.tif")
