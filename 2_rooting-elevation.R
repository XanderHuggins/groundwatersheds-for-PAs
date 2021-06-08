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

# Import Fan rooting depth
rootdepth <- terra::rast('D:/!! Geodatabase/Rooting-depth/Global_raw.tif')
rootdepth <- terra::crop(rootdepth, ext_crop) # will take ~1-2 minutes

# Now mask gmted and d2wt with the ocean layer
gmted[ocean_mask == 1] <- NA  # will take ~1-2 minutes
rootdepth[ocean_mask == 1] <- NA # will take ~1-2 minutes

# Calculate elevation of water table
root_elev <- gmted - rootdepth # will take ~1-2 minutes
terra::writeRaster(root_elev, 
                   "D:/!! Geodatabase/Rooting-depth/Root-elevation-masl.tif",
                   overwrite = T)
