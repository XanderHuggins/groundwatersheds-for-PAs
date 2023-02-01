# Name: ps2-region-crop.R
# Description: Crop post-hoc analysis data for groundwatershed delineation for each world region

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# # datasets to crop
aridity_index = terra::rast("D:/Geodatabase/Climate/Aridity/ai_et0/ai_et0.tif")
feow = terra::rast("D:/Geodatabase/Ecological/Ecoregions/Freshwater/feow_1km.tif")
prot_46 = terra::rast(file.path(wdpa_wd,  "protected_areas_classes_46_filtered_AT_land.tif"))
land_border = terra::rast("D:/Geodatabase/Admin-ocean-boundaries/ne_10m_admin_0_countries_borders.tif")
nat_ID = terra::rast("D:/Geodatabase/Admin-ocean-boundaries/ne10m_ID_extend.tif")

# # human modification gradient needs snapping to 30 arc-second grid (generated at 1km resolution globally) 
humanmodgrad = terra::rast("D:/Geodatabase/Land-use/lulc-human-modification-terrestrial-systems_geographic.tif")
area_r = terra::rast(file.path(dat_loc, "World/input/wgs-area-ras-30-arcsec.tif"))
humanmodgrad_r = terra::resample(x = humanmodgrad, y = area_r, method = 'near')
terra::writeRaster(x = humanmodgrad_r,
                   filename = "D:/Geodatabase/Land-use/lulc-human-modification-terrestrial-systems_0d5arcmin.tif",
                   filetype = "GTiff", overwrite = T)

# Loop through and crop and write each cropped raster
for (w in 1:length(world_regions)) {
  # w = 3
  message(paste0("starting: ", world_regions[w], "..."))
  
  crop_ext = extent_ranges %>% 
    filter(Region == world_regions[w]) %>% 
    pull(Extents) 
  crop_ext = crop_ext[[1]]
  crop_ext
  
  region_aridind = terra::crop(x = aridity_index,   y = crop_ext)
  region_modgrad = terra::crop(x = humanmodgrad_r,   y = crop_ext)
  region_natID = terra::crop(x = nat_ID,   y = crop_ext)
  # region_natID[,23281] = NA                 ### only needed for Africa and Eurasia
  # region_natID = terra::trim(region_natID) ### only needed for Africa and Eurasia
  region_prot46 = terra::crop(x = prot_46,   y = crop_ext)
  ext(region_natID) = crop_ext
  
  region_land_border = terra::crop(x = land_border,   y = crop_ext)
  ext(region_land_border) = crop_ext
  
  mask  = terra::rast(paste0("D:/Geodatabase/Groundwater/Fan_depthtowatertable/Raw/Monthly_means/",
                              mask_folders[w], "_WTD_monthlymeans.nc"))
  
  mask = mask[[1]]
  plot(mask)
  ext(mask) = crop_ext
  region_aridind[mask == 0] = NA
  region_modgrad[mask == 0] = NA
  region_natID[mask == 0] = NA
  region_prot46[mask == 0] = NA
  region_land_border[mask == 0] = NA
  
  # grid area cropping
  terra::writeRaster(x = region_aridind,
                     filename = file.path(dat_loc, world_regions[w], "aridity_index.tif"),
                     filetype = "GTiff", overwrite = T)
  message(paste0("aridity index done"))
  
  # modgrad
  terra::writeRaster(x = region_modgrad,
                     filename = file.path(dat_loc, world_regions[w], "human-modgrad.tif"),
                     filetype = "GTiff", overwrite = T)
  message(paste0("mod grad done"))

  # protected classes 4-6
  terra::writeRaster(x = region_prot46,
                     filename = file.path(dat_loc, world_regions[w], "protected_classes_4to6.tif"),
                     filetype = "GTiff", overwrite = T)
  message(paste0("prot class 4to6 done"))

  # land border
  terra::writeRaster(x = region_land_border,
                     filename = file.path(dat_loc, world_regions[w], "land_border.tif"),
                     filetype = "GTiff", overwrite = T)
  message(paste0("land border done"))
  
  # nation ID
  terra::writeRaster(x = region_natID,
                     filename = file.path(dat_loc, world_regions[w], "nation-ID.tif"),
                     filetype = "GTiff", overwrite = T)
  message(paste0("nation ID done"))
}
