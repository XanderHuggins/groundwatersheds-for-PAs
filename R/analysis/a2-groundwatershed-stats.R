# Name: a2-groundwatershed-stats.R
# Description: Calculate summary statistics for groundwatersheds per protected area. 

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# loop through world regions
for (w in 1:length(world_regions)) {
  
  message(paste0("starting: ", world_regions[w], "..."))
  
  # import data 
  surfarea = terra::rast(file.path(dat_loc, world_regions[w], "grid_area.tif"))
  prot_1t3 = terra::rast(file.path(dat_loc, world_regions[w], "protected_areas_ID.tif"))
  prot_4t6 = terra::rast(file.path(dat_loc, world_regions[w], "protected_classes_4to6.tif"))
  gde_all  = terra::rast(file.path(dat_loc, world_regions[w], "all_gde.tif"))
  gw_sheds = terra::rast(file.path(dat_loc, world_regions[w], "gwsheds_cpa_grouped.tif"))
  land_brd = terra::rast(file.path(dat_loc, world_regions[w], "land_border.tif"))
  aridity_r = terra::rast(file.path(dat_loc, world_regions[w], "aridity_index.tif"))
  modgrad  = terra::rast(file.path(dat_loc, world_regions[w], "human-modgrad.tif"))
  
  # set GDEs to CPA ID for summarizing (i.e., GDEs in PAs with have the ID of the PA)
  gde_all = gde_all*gw_sheds
  
  terra::writeRaster(x = gde_all, 
                     filename = file.path(dat_loc,world_regions[w], "gde_in_gwshed.tif"),
                     filetype = "GTiff", overwrite = T)
  
  # identify unprotected groundwatershed areas
  gwshed_unprot = gw_sheds
  gwshed_unprot[prot_1t3 >= 1] = NA
  
  terra::writeRaster(x = gwshed_unprot, 
                     filename = file.path(dat_loc, world_regions[w], "gwshed_unprotected.tif"),
                     filetype = "GTiff", overwrite = T)
  
  # identify unprotected groundwatersheds that are also not under WDPA class 4 to 6 protection
  gwshed_unprot_all = gwshed_unprot
  gwshed_unprot_all[prot_4t6 == 1] = NA
  terra::writeRaster(x = gwshed_unprot_all, 
                     filename = file.path(dat_loc, world_regions[w], "gwshed_unprotected_allclass.tif"),
                     filetype = "GTiff", overwrite = T)
  
  # calculate zonal statistics for each contiguous protected area
  
  # area of protected areas
  stat_df = terra::zonal(x = surfarea, z = prot_1t3, fun = sum, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "area")
  readr::write_csv(stat_df, file = file.path(dat_loc, world_regions[w], "STAT_protected_area_area.csv"))
  
  # area of groundwatersheds
  stat_df = terra::zonal(x = surfarea, z = gw_sheds, fun = sum, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "gwshed_area")
  readr::write_csv(stat_df, file = file.path(dat_loc, world_regions[w], "STAT_groundwatershed_area.csv"))
  
  # area of ecologically connected areas in groundwatersheds
  stat_df = terra::zonal(x = surfarea, z = gde_all, fun = sum, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "gde_area")
  readr::write_csv(stat_df, file = file.path(dat_loc, world_regions[w], "STAT_GDEinGWshed_area.csv"))
  
  # area of unprotected groundwatersheds
  stat_df = terra::zonal(x = surfarea, z = gwshed_unprot, fun = sum, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "unprot_gwshed_area")
  readr::write_csv(stat_df, file = file.path(dat_loc, world_regions[w], "STAT_unprotgwshed_area.csv"))
  
  # area of unprotected groundwatersheds considerall all protected area classes
  stat_df = terra::zonal(x = surfarea, z = gwshed_unprot_all, fun = sum, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "unprot_gwshed_area_c1to6")
  readr::write_csv(stat_df, file = file.path(dat_loc, world_regions[w], "STAT_unprotgwshed_c1to6_area.csv"))
  
  # determine if protected area is transboundary
  stat_df = terra::zonal(x = land_brd, z = prot_1t3, fun = max, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "prot_area_transbound")
  stat_df$prot_area_transbound[is.nan(stat_df$prot_area_transbound)] = 0
  readr::write_csv(stat_df, file = file.path(dat_loc, world_regions[w], "STAT_transbound_protectedarea.csv"))
  
  # determine if groundwatershed is transboundary
  stat_df = terra::zonal(x = land_brd, z = gw_sheds, fun = max, na.rm = T)
  colnames(stat_df) = c("CPA_ID", "gw_sheds_transbound")
  stat_df$gw_sheds_transbound[is.nan(stat_df$gw_sheds_transbound)] = 0
  readr::write_csv(stat_df, file = file.path(dat_loc, world_regions[w], "STAT_transbound_groundwatershed.csv"))
  
  # calculate mean aridity per protected area - need to area weight, which requires multiplying by area, summing, then removing the area in subsequent 
  stat_df = terra::zonal(x = (aridity_r*surfarea), z = gw_sheds, fun = sum, na.rm = T) 
  colnames(stat_df) = c("CPA_ID", "aridity_xArea")
  readr::write_csv(stat_df, file = file.path(dat_loc, world_regions[w], "/STAT_aridity_xArea.csv"))
  
  # calculate human modification gradient in underprotected part of groundwatersheds, which also requires area weighting
  gwshed_unprot = gw_sheds
  gwshed_unprot[prot_1t3 >= 1] = NA
  
  stat_df = terra::zonal(x = (modgrad*surfarea), z = gwshed_unprot, fun = sum, na.rm = T) 
  colnames(stat_df) = c("CPA_ID", "modgrad_xArea")
  readr::write_csv(stat_df, file = file.path(dat_loc, world_regions[w], "STAT_modgrad_xArea.csv"))
  
}
