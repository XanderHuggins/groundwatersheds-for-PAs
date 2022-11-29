# Name: p1-land-mask.R
# Description: Prepare a global land mask raster

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 


extent_ranges$Region = topo_folders # ensure correct naming convention

# loop through world regions to create a global land mask
for (i in 1:nrow(extent_ranges)) {
  
  # this water table depth netcdf file contains a land mask layer
  wtd_in  = terra::rast(paste0("D:/Geodatabase/Terrain/wtddata/", extent_ranges$Region[i], "_WTD_annualmean.nc"))
  
  # ensure precise regional extent
  set_ext = extent_ranges %>% 
    filter(Region == extent_ranges$Region[i]) %>% 
    pull(Extents) %>% 
    unlist()
  ext(wtd_in) = set_ext[[1]]
  
  if (i == 1) { mask = wtd_in[[1]]  }
  if (i > 1)  { mask = terra::mosaic(mask, wtd_in[[1]], fun = "max")  }
  message(i, " complete!")
}

# ensure extent is snapped 
mask = terra::extend(x = mask, y = rast(WGS84_areaRaster(1)))
terra::ext(mask) = terra::ext(rast(WGS84_areaRaster(1)))

terra::writeRaster(x = mask, 
                   filename = file.path(wdpa_wd,  "land_mask.tif"),
                   filetype = "GTiff",
                   overwrite = T)