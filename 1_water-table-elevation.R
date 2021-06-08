# import some libraries
library(tidyverse) # for general functionality
library(terra) # for spatial functions

# you will need ~20 gb of free disk space to execute this code on your local computer

# Set extent of analysis
ext_crop <- terra::ext(c(-180, 180, -56, 80)) 

# Identify ocean location for masking
ocean_mask <- terra::rast('D:/!! Geodatabase/Admin-ocean-boundaries/oceans/ne_10m_oceans_1km.tif')
ocean_mask <- terra::crop(ocean_mask, ext_crop)

# Import global raster file of DTM
gmted <- terra::rast('D:/!! Geodatabase/Terrain/GMTED2010/mn30_grd.tif')
gmted <- terra::crop(gmted, ext_crop) # will take ~1-2 minutes

# Import Fan depth to water table
# for thinking about: monthly means also available: 
# https://aquaknow.jrc.ec.europa.eu/en/content/global-patterns-groundwater-table-depth-wtd
# perhaps should ecologically connected be for any root depth which intersects water table for any individual month (nevermind only in the annual mean depth to water table?)
d2wt <- terra::rast('D://!! Geodatabase/Groundwater/Fan_depthtowatertable/Raw/Global_wtd_fan_raw_snap.tif')
d2wt <- terra::crop(d2wt, ext_crop) # will take ~1-2 minutes

# Now mask gmted and d2wt with the ocean layer
gmted[ocean_mask == 1] <- NA  # will take ~1-2 minutes
d2wt[ocean_mask == 1] <- NA # will take ~1-2 minutes

# Calculate elevation of water table
wt_evel <- gmted - d2wt # will take ~1-2 minutes
terra::writeRaster(wt_evel, "D:/!! Geodatabase/Groundwater/Fan_depthtowatertable/Processed/WT_elevation.tif",
                   overwrite = T)
