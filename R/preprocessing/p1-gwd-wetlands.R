# Name: p1-gwd-wetlands.R
# Description: Extract groundwater-driven wetlands from Tootchi et al. (https://doi.org/10.1594/PANGAEA.892657) and resample to 30 arc-second resolution

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import wetland extent data
cw_wtd = terra::rast("D:/Geodatabase/Ecological/Global-wetlands-map/Tootchi_etal_2019/TIFF/CW-WTD/CW_WTD.tif")
cw_tci = terra::rast("D:/Geodatabase/Ecological/Global-wetlands-map/Tootchi_etal_2019/TIFF/CW-TCI/CW_TCI.tif")

for (i in 1:length(topo_folders)) {
  
  # pull extent for region
  set_ext = extent_ranges %>% 
    filter(Region == extent_ranges$Region[i]) %>% 
    pull(Extents) %>% 
    unlist()
  
  # crop global rasters to regional extent
  cw_wtd_t = terra::crop(x = cw_wtd, y = set_ext[[1]])
  cw_tci_t = terra::crop(x = cw_tci, y = set_ext[[1]])
  
  # reclassify to extract only groundwater-related wetland classes (ids: 1 and 3)
  rcl_df = matrix(c(c(0,1,2,3,4), c(0,1,0,1,0)), nrow = 5, ncol = 2)
  cw_wtd_t = terra::classify(x = cw_wtd_t, rcl = rcl_df, othersNA = TRUE)
  cw_tci_t = terra::classify(x = cw_tci_t, rcl = rcl_df, othersNA = TRUE)
  
  # create template raster for resampling at 30 arc-seconds
  temp_r = terra::rast(extent = set_ext[[1]], res = 0.5/60)
  
  # aggregate the wetland map to 30 arc-seconds using maximum value 
  cw_wtd_t = terra::resample(x = cw_wtd_t, y = temp_r, method = 'max')
  cw_tci_t = terra::resample(x = cw_tci_t, y = temp_r, method = 'max')
  
  terra::writeRaster(x = cw_wtd_t, 
                     filename = file.path(dat_loc, world_regions[i], "cw_wtd.tif"),
                     filetype = "GTiff", overwrite = T)
  
  terra::writeRaster(x = cw_tci_t,
                     filename = file.path(dat_loc, world_regions[i], "cw_tci.tif"),
                     filetype = "GTiff", overwrite = T)
  
  message(paste0(world_regions[i], " groundwater related wetlands done!"))
}

# mosaic all world region groundwater-driven wetlands  
# for cw_tci
cw_tci_na = terra::rast(file.path(dat_loc, "NorthAmerica/cw_tci.tif"))
cw_tci_sa = terra::rast(file.path(dat_loc, "SouthAmerica/cw_tci.tif"))
cw_tci_oc = terra::rast(file.path(dat_loc, "Oceania/cw_tci.tif"))
cw_tci_af = terra::rast(file.path(dat_loc, "Africa/cw_tci.tif"))
cw_tci_eu = terra::rast(file.path(dat_loc, "Eurasia/cw_tci.tif"))

cw_tci <- terra::mosaic(cw_tci_na, cw_tci_sa, cw_tci_oc, cw_tci_af, cw_tci_eu, fun = 'max')

terra::writeRaster(x = cw_tci,
                   filename = file.path(dat_loc, "World/cw_tci_binary.tif"),
                   filetype = "GTiff", overwrite = T)

# for cw_wtd
cw_wtd_na = terra::rast(file.path(dat_loc, "NorthAmerica/cw_wtd.tif"))
cw_wtd_sa = terra::rast(file.path(dat_loc, "SouthAmerica/cw_wtd.tif"))
cw_wtd_oc = terra::rast(file.path(dat_loc, "Oceania/cw_wtd.tif"))
cw_wtd_af = terra::rast(file.path(dat_loc, "Africa/cw_wtd.tif"))
cw_wtd_eu = terra::rast(file.path(dat_loc, "Eurasia/cw_wtd.tif"))

cw_wtd = terra::mosaic(cw_wtd_na, cw_wtd_sa, cw_wtd_oc, cw_wtd_af, cw_wtd_eu, fun = 'max')

terra::writeRaster(x = cw_wtd,
                   filename = file.path(dat_loc, "World/cw_wtd_binary.tif"),
                   filetype = "GTiff", overwrite = T)