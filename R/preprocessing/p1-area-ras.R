# Name: p1-area-ras.R
# Description: Generate grid cell area raster globally at 30 arc-second following Santini et al. 2010 https://doi.org/10.1111/j.1467-9671.2010.01200.x

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# set resolution
RES = 0.5/60

# calculate area per 'row' in global grid 
# setting resolution to c(1/120, 1/120) overwhelms RAM
# workaround: create single longitudinal 'column', then resample at desired dx resolution 
pi.g = 3.14159265358979  
Fl = 0.00335281066474 # Flattening
SMA = 6378137.0 # Semi major axis
e = sqrt((2*Fl) - (Fl^2)) # Eccentricity  

# initialize dataframe with geodetic latitudes
df_a = data.frame(LowLAT = seq(-90, 90-RES, by = RES), 
                   UppLAT = seq(-90+RES, 90, by = RES))

# convert geodetic latitudes degrees to radians
df_a$LowLATrad = df_a$LowLAT * pi.g / 180
df_a$UppLATrad = df_a$UppLAT * pi.g / 180

# Calculate q1 and q2
df_a$q1 = (1-e*e)* ((sin(df_a$LowLATrad)/(1-e*e*sin(df_a$LowLATrad)^2)) - ((1/(2*e))*log((1-e*sin(df_a$LowLATrad))/(1+e*sin(df_a$LowLATrad)))))

df_a$q2 = (1-e*e)* ((sin(df_a$UppLATrad)/(1-e*e*sin(df_a$UppLATrad)^2)) - ((1/(2*e))*log((1-e*sin(df_a$UppLATrad))/(1+e*sin(df_a$UppLATrad)))))

# calculate q constant
q_const = (1-e*e)* ((sin(pi.g/2)/(1-e*e*sin(pi.g/2)^2)) - ((1/(2*e))*log((1-e*sin(pi.g/2))/(1 + e*sin(pi.g/2)))))

# calculate authaltic latitudes
df_a$phi1 = asin(df_a$q1 / q_const)
df_a$phi2 = asin(df_a$q2 / q_const)

# calculate authaltic radius
R.adius = sqrt(SMA*SMA*q_const/2)

# calculate cell size in radians
CS = (RES) * pi.g/180

# calculate cell area in m2
df_a$area_m2 = R.adius*R.adius*CS*(sin(df_a$phi2)-sin(df_a$phi1))

# turn dataframe into a raster
wgs_30arcsec = terra::rast()
res(wgs_30arcsec) = c(360, 1/120)
wgs_30arcsec = terra::init(wgs_30arcsec, 'row')

# Set row values to grid cell areas if dy = dx in decimal degrees 
df_a$id = seq(1, nrow(df_a))

rcl_mat = c(df_a$id - 0.5, 
             df_a$id + 0.5,
             df_a$area_m2) %>% matrix(ncol = 3, byrow = F)

wgs_30arcsec = terra::classify(wgs_30arcsec, rcl_mat)

# resample to grid at proper dx resolution
wgs_new = terra::rast()
res(wgs_new) = c(1/120, 1/120)

wgs_new = terra::resample(x=wgs_30arcsec, y=wgs_new, method="near")

writeRaster(wgs_new,
            file.path(wd, "data/World/input/wgs-area-ras-30-arcsec.tif"), 
            gdal="COMPRESS=LZW",
            overwrite=TRUE)