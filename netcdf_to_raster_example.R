library(tidyverse)
library(raster)
library(ncdf4)

# example workflow to convert from netcdf to raster and mosaic rasters together
dat_in <- nc_open('in_netcdf_file.nc')
lon <- ncvar_get(dat_in, "lon") # or whatever string identifies longitude in netcdf
lat <- ncvar_get(dat_in, "lat") # or whatever string identifies latitude in netcdf
dname <- "variable_of_interest" # chane to the variable name
dat_in <- ncvar_get(dat_in, dname) # extract variable from netcdf
dat_in <- raster(t(dat_in), xmn=min(lon), xmx=max(lon), 
                ymn=min(lat), ymx=max(lat), 
                crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ 
                           towgs84=0,0,0")) # convert  to raster
dat_in <- flip(dat_in, direction = 'y') # flip the raster vertically, # only if necessary
plot(dat_in) # plot the raster

# snap raster to grid, if necessary
extent(dat_in) <- extent(c(xmin, xmax, ymin, ymax)) # replace xmin, xmax etc. with bounding box coordinates

# mosaic rasters together
mosaic_1 <- mosaic(raster1, raster2, fun = max) # can see other functions by running ?mosaic
mosaic_1 <- mosaic(mosaic_1, raster3, fun = max) # can mosaic an existing mosaic

# write the mosaic to file
writeRaster(mosaic_1, 'location_to_save_to.tif',
            format = 'GTiff', overwrite = T)
