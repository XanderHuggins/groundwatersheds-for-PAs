# Name: p1-hydrosheds-ires.R
# Description: Generate raster representation of HydroLAKES and perennial HydroRIVERS

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# import HydroRIVERS files
ires_files = list.files("D:/Geodatabase/HydroSHEDS/GIRES_v10_shp/", pattern = "*.shp", full.names = T)
ires_files = ires_files[-(length(ires_files))] 
regns_shfm = c("af", "ar", "as", "au", "eu", "gr", "na", "sa", "si")

# loop through each world region
for (i in 1:length(ires_files)) {
  
  message(paste("starting", regns_shfm[i], "now!"))
  
  reg_sf = sf::read_sf(ires_files[i])
  message(paste("shapefile has been read"))
  
  # Filter for probability that river reach ceases to flow for at least one month (thirty days) per year is <50% 
  reg_filt = reg_sf |> dplyr::filter(predcat30 == 0) 
  
  message("shapefile has been filtered")
  
  sf::write_sf(obj=reg_filt,
               dsn = "D:/Geodatabase/HydroSHEDS/GIRES_perennial",
               layer = paste0(regns_shfm[i],"_perennial.shp"),
               driver = "ESRI Shapefile")
  message(paste(regns_shfm[i], "is done!"))
}

# import list of files of perennial rivers and streams
perennial_ires_files = list.files("D:/Geodatabase/HydroSHEDS/GIRES_perennial/", pattern = "*.shp", full.names = T)

# loop through each world region
for (i in 1:length(ires_files)) {
  
  message(paste("starting", regns_shfm[i], "now!"))
  
  # rasterize using all touched = TRUE at 30 arc-second resolution
  gdalUtilities::gdal_rasterize(src_datasource = perennial_ires_files[i],
                                dst_filename = paste0("D:/Geodatabase/HydroSHEDS/perennial_1km_",
                                                      regns_shfm[i], ".tif"),
                                at = T,
                                burn = 1,
                                tr = c((1/120), (1/120)),
                                te = c(-180, -90, 180, 90)) # this needs to be rasterized across global domain to prevent grid-shifting
                                                            # when mosaicing with other world regions
  message(paste(regns_shfm[i], "is done!"))
}

# mosaic regional rasters together
p_af = terra::rast("D:/Geodatabase/HydroSHEDS/perennial_1km_af.tif")
p_ar = terra::rast("D:/Geodatabase/HydroSHEDS/perennial_1km_ar.tif")
p_as = terra::rast("D:/Geodatabase/HydroSHEDS/perennial_1km_as.tif")
p_au = terra::rast("D:/Geodatabase/HydroSHEDS/perennial_1km_au.tif")
p_eu = terra::rast("D:/Geodatabase/HydroSHEDS/perennial_1km_eu.tif")
p_gr = terra::rast("D:/Geodatabase/HydroSHEDS/perennial_1km_gr.tif")
p_na = terra::rast("D:/Geodatabase/HydroSHEDS/perennial_1km_na.tif")
p_sa = terra::rast("D:/Geodatabase/HydroSHEDS/perennial_1km_sa.tif")
p_si = terra::rast("D:/Geodatabase/HydroSHEDS/perennial_1km_si.tif")

global_perrennial = c(p_af, p_ar, p_as, p_au, p_eu, p_gr, p_na, p_sa, p_si)
global_perrennial = sum(global_perrennial) # combine all regional layers

# clean any overlapping grid cells
global_perrennial[global_perrennial > 1] = 1

terra::writeRaster(x = global_perrennial,
                   filename = "D:/Geodatabase/HydroSHEDS/perennial_1km_world_binary.tif",
                   filetype = "GTiff", overwrite = T)