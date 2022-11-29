# Name: p1-hydrosheds.R
# Description: Generate raster representation of HydroLAKES and perennial HydroRIVERS

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import list of Messager et al. (2021) HydroRIVERS files
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
  gdalUtils::gdal_rasterize(src_datasource = perennial_ires_files[i],
                            dst_filename = paste0("D:/Geodatabase/HydroSHEDS/perennial_1km_",
                                                  regns_shfm[i], ".tif"),
                            at = T,
                            burn = 1,
                            tr = c((1/120), (1/120)),
                            verbose = T)
  
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

perennial_streams = terra::mosaic(p_af, p_ar, p_as, p_au, 
                                   p_eu, p_gr, p_na, p_sa, p_si,
                                   fun = 'max')

# ensure extent is snapped correctly
perennial_streams = terra::extend(x = perennial_streams,
                                   y = WGS84_areaRaster(1))
ext(perennial_streams) = round(ext(terra::rast(WGS84_areaRaster(1))), 0)

# ensure binary (likely an unnecessary step)
perennial_streams[perennial_streams > 0] = 1

terra::writeRaster(x = perennial_streams,
                   filename = "D:/Geodatabase/HydroSHEDS/perennial_1km_world_raw.tif",
                   filetype = "GTiff", overwrite = T)