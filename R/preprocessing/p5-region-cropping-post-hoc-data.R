# Name: p5-region-cropping-post-hoc-data.R
# Description: Crop post-hoc analysis data for groundwatershed delineation for each world region

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# datasets to crop
aridity_index <- terra::rast("D:/Geodatabase/Climate/Aridity/ai_et0/ai_et0.tif")
feow <- terra::rast("D:/Geodatabase/Ecological/Ecoregions/Freshwater/feow_1km.tif")
prot_46 <- terra::rast(file.path(wdpa_wd,  "protected_areas_classes_46_filtered_AT_land.tif"))
land_border <- terra::rast("D:/Geodatabase/Admin-ocean-boundaries/ne_10m_admin_0_countries_borders.tif")
nat_ID <- terra::rast("D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_merge_extend.tif")

# human modification gradient needs snapping to 30 arc-second grid (generated at 1km resolution globally) 
humanmodgrad <- terra::rast("D:/Geodatabase/Land-use/lulc-human-modification-terrestrial-systems_geographic.tif")
area_r <- terra::rast(file.path(wd, "data/World/input/wgs-area-ras-30-arcsec.tif"))
humanmodgrad_r <- terra::resample(x = humanmodgrad, y = area_r, method = 'near')
terra::writeRaster(x = humanmodgrad_r,
                   filename = "D:/Geodatabase/Land-use/lulc-human-modification-terrestrial-systems_0d5arcmin.tif",
                   filetype = "GTiff", overwrite = T)

# permeability needs to be disaggregated 
permeability  <- terra::rast("D:/Geodatabase/Groundwater/GLHYMPS/Permeability_0d05.tif")
permeability <- terra::disagg(x = permeability, fact = 6, method = 'near')

# Loop through and crop and write each cropped raster
for (w in 1:length(world_regions)) {
  
  message(paste0("starting: ", world_regions[w], "..."))
  
  crop_ext <- extent_ranges %>% 
    filter(Region == world_regions[w]) %>% 
    pull(Extents) 
  crop_ext <- crop_ext[[1]]
  crop_ext
  
  region_aridind <- terra::crop(x = aridity_index,   y = crop_ext)
  region_permeab <- terra::crop(x = permeability,   y = crop_ext)
  region_modgrad <- terra::crop(x = humanmodgrad_r,   y = crop_ext)
  region_natID <- terra::crop(x = nat_ID,   y = crop_ext, snap = "near")
  region_prot46 <- terra::crop(x = prot_46,   y = crop_ext)
  
  region_land_border <- terra::crop(x = land_border,   y = crop_ext)
  ext(region_land_border) <- crop_ext
  
  # # Below is fix needed only for Africa and Eurasia for nation ID cropping due to strange cropping output n+1 columns larger than crop extent would expect 
  # # suggest exiting loop here and inspecting/performing these processes line-by-line 
  # region_natIDf <- as.matrix(raster::raster(region_natID))
  # dim(region_natIDf)
  # region_natIDf <- region_natIDf[,-1] # remove first column
  # dim(region_natIDf)
  # 
  # region_natIDf <- terra::rast(raster(region_natIDf))
  # 
  # region_natID <- region_natIDf
  # terra::crs(region_natID) <- terra::crs(terra::rast(WGS84_areaRaster(1)))
  # ext(region_natID) <- crop_ext
  # # end fix
  
  mask  <- terra::rast(paste0("D:/Geodatabase/Groundwater/Fan_depthtowatertable/Raw/Monthly_means/",
                              mask_folders[w], "_WTD_monthlymeans.nc"))
  
  mask <- mask[[1]]
  plot(mask)
  ext(mask) <- crop_ext
  region_aridind[mask == 0] <- NA
  region_permeab[mask == 0] <- NA
  region_modgrad[mask == 0] <- NA
  region_natID[mask == 0] <- NA
  region_prot46[mask == 0] <- NA
  region_land_border[mask == 0] <- NA
  
  # grid area cropping
  terra::writeRaster(x = region_aridind,
                     filename = file.path(wd, paste0("data/", world_regions[w], "/aridity_index.tif")),
                     filetype = "GTiff", overwrite = T)
  message(paste0("aridity index done"))

  # permeability
  terra::writeRaster(x = region_permeab,
                     filename = file.path(wd, paste0("data/", world_regions[w], "/permeability.tif")),
                     filetype = "GTiff", overwrite = T)
  message(paste0("permeability done"))
  
  # modgrad
  terra::writeRaster(x = region_modgrad,
                     filename = file.path(wd, paste0("data/", world_regions[w], "/human-modgrad.tif")),
                     filetype = "GTiff", overwrite = T)
  message(paste0("mod grad done"))
  
  # protected classes 4-6
  terra::writeRaster(x = region_prot46,
                     filename = file.path(wd, paste0("data/", world_regions[w], "/protected_classes_4to6.tif")),
                     filetype = "GTiff", overwrite = T)
  message(paste0("prot class 4to6 done"))
  
  # land border
  terra::writeRaster(x = region_land_border,
                     filename = file.path(wd, paste0("data/", world_regions[w], "/land_border.tif")),
                     filetype = "GTiff", overwrite = T)
  message(paste0("land border done"))
  
  # # nation ID
  terra::writeRaster(x = region_natID,
                     filename = file.path(wd, paste0("data/", world_regions[w], "/nation-ID.tif")),
                     filetype = "GTiff", overwrite = T)
  message(paste0("nation ID done"))
}