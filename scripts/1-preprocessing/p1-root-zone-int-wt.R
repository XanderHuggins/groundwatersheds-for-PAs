# Name: p1-root-zone-int-wt.R
# Description: Identify terresrial GDEs where root zones intersect the water table for min. 1 month/year.

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# loop through world regions
for (w in 1:length(world_regions)) {
  message(paste0("starting: ", world_regions[w], " and ", mask_folders[w], "..."))
  
  # step 1: import monthly water table depths and maximum root depth 
  wtd_region = terra::rast(paste0("D:/Geodatabase/Groundwater/Fan_depthtowatertable/Raw/Monthly_means/",
                           mask_folders[w], "_WTD_monthlymeans.nc"))
  mrd_region  = terra::rast(paste0("D:/Geodatabase/Rooting-depth/Raw/maxroot_", rd_names[w], "_CF.nc"))
  
  # ensure both are correctly snapped to correct extent
  set_ext = extent_ranges %>% 
    filter(Region == extent_ranges$Region[w]) %>% 
    pull(Extents) %>% 
    unlist()
  
  ext(wtd_region) = ext(mrd_region) = set_ext[[1]]
  
  # initiate root zone intersection raster and loop through each month to populate
  rz_intsct = terra::rast(mrd_region)
  rz_intsct[] = 0 # need to initiate with values so that first month doesn't set extent of modifiable cells
  rz_intsct_t = rz_intsct
  
  # first layer is mask, so iterate layers 2-13 (months 1-12)
  for (m in 2:13) {
    
    rz_intsct_t[mrd_region[[1]] > -wtd_region[[m]]] = 1 # identify where root depth is greater than water table depth
    
    # for January, set monthly result to base raster
    if (m == 2) {
      rz_intsct = rz_intsct_t
    }
    
    # for subsequent months, add month to base raster (i.e. number of months where intersections occur)
    if (m > 2) {
      rz_intsct = rz_intsct + rz_intsct_t 
    }
    message("month ", m-1, " is done baboom")
  }
  
  terra::writeRaster(x = rz_intsct,
                     filename = file.path(dat_loc, world_regions[w], "rz_intersects_month_count.tif"),
                     filetype = "GTiff", overwrite = T)
  
  # convert monthly counts to binary (1: terrestrial GDE, 0: not a terrestrial GDE)
  rz_intsct[rz_intsct >= 1] = 1
  
  terra::writeRaster(x = rz_intsct,
                     filename = file.path(dat_loc, world_regions[w], "rz_intersects_allmonth_binary.tif"),
                     filetype = "GTiff", overwrite = T)
  
  message("world region ", world_regions[w], " is done baboom")
  
}

# manually fix an extent overlapping issue between north and south america
s_am = terra::rast(file.path(dat_loc, "SouthAmerica/rz_intersects_allmonth_binary.tif"))
mask = terra::rast(paste0("D:/Geodatabase/Groundwater/Fan_depthtowatertable/Raw/Monthly_means/SAMERICA_WTD_monthlymeans.nc"))
mask = mask[[1]]
ext(mask) = terra::ext(c(-93, -32, -56, 15))
s_am[mask == 0] = 0
terra::writeRaster(x = s_am,
                   filename = file.path(dat_loc, "SouthAmerica/rz_intersects_allmonth_binary.tif"),
                   filetype = "GTiff", overwrite = T)


# mosaic all world region root intersection binary rasters 
rzi_na = terra::rast(file.path(dat_loc, "NorthAmerica/rz_intersects_allmonth_binary.tif"))
rzi_sa = terra::rast(file.path(dat_loc, "SouthAmerica/rz_intersects_allmonth_binary.tif"))
rzi_oc = terra::rast(file.path(dat_loc, "Oceania/rz_intersects_allmonth_binary.tif"))
rzi_af = terra::rast(file.path(dat_loc, "Africa/rz_intersects_allmonth_binary.tif"))
rzi_eu = terra::rast(file.path(dat_loc, "Eurasia/rz_intersects_allmonth_binary.tif"))

rzi = terra::mosaic(rzi_na, rzi_sa, rzi_oc, rzi_af, rzi_eu, fun = 'max')

terra::writeRaster(x = rzi,
                   filename = file.path(dat_loc, "World/rz_intersects_allmonth_binary.tif"),
                   filetype = "GTiff", overwrite = T)