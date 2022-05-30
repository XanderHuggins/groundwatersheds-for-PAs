# Name: a2-summary-stats.R
# Description: Derives summary statistics for groundwatersheds and protected areas per protected area ID. 

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# loop through world regions
for (w in 1:length(world_regions)) {
  
  message(paste0("starting: ", world_regions[w], "..."))
  
  # import data 
  surfarea = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/grid_area.tif")))
  prot_1t3 = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/protected_areas_ID.tif")))
  prot_4t6 = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/protected_classes_4to6.tif")))
  ecolcond = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/ecologically_connected_cells.tif")))
  gw_sheds = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/gwsheds_cpa_grouped.tif")))
  land_brd = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/land_border.tif")))
  
  # set ecologically connected cells to CPA ID for summarizing
  ecolcond = ecolcond*prot_1t3
  
  # identify unprotected groundwatershed areas
  gwshed_unprot = gw_sheds
  gwshed_unprot[prot_1t3 >= 1] = NA
  
  terra::writeRaster(x = gwshed_unprot, 
                     filename = file.path(wd, paste0("data/", world_regions[w], "/gwshed_unprotected.tif")),
                     filetype = "GTiff", overwrite = T)
  
  # identify unprotected groundwatersheds that are also not under WDPA class 4 to 6 protection
  gwshed_unprot_all = gwshed_unprot
  gwshed_unprot_all[prot_4t6 == 1] = NA
  terra::writeRaster(x = gwshed_unprot_all, 
                     filename = file.path(wd, paste0("data/", world_regions[w], "/gwshed_unprotected_allclass.tif")),
                     filetype = "GTiff", overwrite = T)
  
  # calculate zonal statistics for each contiguous protected area
 
  # area of protected areas
  stat_df = terra::zonal(x = surfarea, z = prot_1t3, fun = sum, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "area")
  readr::write_csv(stat_df, file = file.path(wd, paste0("data/", world_regions[w], "/STAT_protected_area_area.csv")))

  # area of groundwatersheds
  stat_df = terra::zonal(x = surfarea, z = gw_sheds, fun = sum, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "gwshed_area")
  readr::write_csv(stat_df, file = file.path(wd, paste0("data/", world_regions[w], "/STAT_groundwatershed_area.csv")))

  # area of ecologically connected areas in protected areas
  stat_df = terra::zonal(x = surfarea, z = ecolcond, fun = sum, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "ecolcond_area")
  readr::write_csv(stat_df, file = file.path(wd, paste0("data/", world_regions[w], "/STAT_ecolcond_area.csv")))

  # area of unprotected groundwatersheds
  stat_df = terra::zonal(x = surfarea, z = gwshed_unprot, fun = sum, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "unprot_gwshed_area")
  readr::write_csv(stat_df, file = file.path(wd, paste0("data/", world_regions[w], "/STAT_unprotgwshed_area.csv")))
  
  # area of unprotected groundwatersheds considerall all protected area classes
  stat_df = terra::zonal(x = surfarea, z = gwshed_unprot_all, fun = sum, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "unprot_gwshed_area_c1to6")
  readr::write_csv(stat_df, file = file.path(wd, paste0("data/", world_regions[w], "/STAT_unprotgwshed_c1to6_area.csv")))
  
  # determine if protected area is transboundary
  stat_df = terra::zonal(x = land_brd, z = prot_1t3, fun = max, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "prot_area_transbound")
  stat_df$prot_area_transbound[is.nan(stat_df$prot_area_transbound)] = 0
  readr::write_csv(stat_df, file = file.path(wd, paste0("data/", world_regions[w], "/STAT_transbound_protectedarea.csv")))
  
  # determine if groundwatershed is transboundary
  stat_df = terra::zonal(x = land_brd, z = gw_sheds, fun = max, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "gw_sheds_transbound")
  stat_df$gw_sheds_transbound[is.nan(stat_df$gw_sheds_transbound)] = 0
  readr::write_csv(stat_df, file = file.path(wd, paste0("data/", world_regions[w], "/STAT_transbound_groundwatershed.csv")))
}

# now calculate summary statistics of three possible drivers (limitation is these are currently not area-weighted, but this will not make a significant difference as all protected areas are quite localized and thus the impact of different grid cell areas will be negligible to very minor)
# area weights are not considered as weighted statistics not currently enabled in terra::zonal or other alternatives (such as zonalDT); and otherwise would require a custom function with likely a much longer run-time for these high-resolution (thus large in size) rasters
for (w in 1:length(world_regions)) {
  
  message(paste0("starting: ", world_regions[w], "..."))
  
  # import data 
  surfarea = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/grid_area.tif")))
  protarea = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/protected_areas_ID.tif")))
  slope_r   = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/terra_slope.tif")))
  aridity_r = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/aridity_index.tif")))
  permeab_r = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/permeability.tif")))
  
  stat_df = terra::zonal(x = slope_r, z = protarea, fun = mean, na.rm = T) 
  colnames(stat_df) = c("CPA_ID", "slope")
  readr::write_csv(stat_df, file = file.path(wd, paste0("data/", world_regions[w], "/STAT_slope.csv")))
  
  stat_df = terra::zonal(x = aridity_r, z = protarea, fun = mean, na.rm = T) 
  colnames(stat_df) = c("CPA_ID", "aridity")
  readr::write_csv(stat_df, file = file.path(wd, paste0("data/", world_regions[w], "/STAT_aridity.csv")))
  
  stat_df = terra::zonal(x = permeab_r, z = protarea, fun = min, na.rm = T) 
  colnames(stat_df) = c("CPA_ID", "min_permeability")
  readr::write_csv(stat_df, file = file.path(wd, paste0("data/", world_regions[w], "/STAT_permeability.csv")))
}

# Now calculate human mod grad per unprotected groundwatersheds
for (w in 1:length(world_regions)) {
  # w = 1
  message(paste0("starting: ", world_regions[w], "..."))
  
  protarea = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/protected_areas_ID.tif")))
  gw_sheds = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/gwsheds_cpa_grouped.tif")))
  modgrad  = terra::rast(file.path(wd, paste0("data/", world_regions[w], "/human-modgrad.tif")))
  
  gwshed_unprot = gw_sheds
  gwshed_unprot[protarea >= 1] = NA
  
  stat_df = terra::zonal(x = modgrad, z = gwshed_unprot, fun = mean, na.rm = T) 
  colnames(stat_df) = c("CPA_ID", "modgrad")
  readr::write_csv(stat_df, file = file.path(wd, paste0("data/", world_regions[w], "/STAT_modgrad.csv")))
}