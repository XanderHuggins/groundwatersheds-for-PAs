# Name: as1-groundwatersheds-delineation-uncertainty.R
# Description: Repeat groundwatershed delineation process for mean monthly water table depths

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# loop through world regions individually
for (w in 1:length(world_regions)) {
  for (m in 1:12) {
 
    message(paste0("starting: ", world_regions[w], " for month ", m, "..."))
    
    # import region-specific data sets
    wtelv_rgn = terra::rast(file.path(dat_loc, world_regions[w], paste0("wt_elev_month_", m, ".tif"))) # mean monthly water table
    gdepp_rgn = terra::rast(file.path(dat_loc, world_regions[w], "gde_pourpoint.tif"))
    prot_area = terra::rast(file.path(dat_loc, world_regions[w], "protected_areas_ID.tif"))
    message(paste0("data import done"))
    
    # derive D8 flow direction raster
    whitebox::wbt_d8_pointer(dem = file.path(dat_loc, world_regions[w], paste0("wt_elev_month_", m, ".tif")), 
                             output = file.path(dat_loc, world_regions[w], paste0("d8_month_", m, ".tif")))
    message(paste0("d8 done"))
    
    # clean D8 by setting ocean values to NaN
    d8 = terra::rast(file.path(dat_loc, world_regions[w], paste0("d8_month_", m, ".tif")))
    d8[is.na(wtelv_rgn)] = NaN
    terra::writeRaster(x = d8, 
                       filename = file.path(dat_loc, world_regions[w], paste0("d8_ocean_rm_month_", m, ".tif")),
                       filetype = "GTiff",
                       overwrite = T)
    message(paste0("d8 cleaning done"))
    
    # identify ecologically connected areas and set to pour points vector file
    pp_p = terra::as.points(gdepp_rgn) # convert to points
    pp_ID = terra::extract(x = prot_area, y = pp_p,  method = 'simple') # Extract FID per point
    pp_p$fid = pp_ID$fid # write extracted PA ID to vector file
    pp_p[,1] = NULL # drop row ID and keep only PA ID
    terra::writeVector(pp_p,
                       paste0(dat_loc, "/", world_regions[w], "/pour_points_protected_contigID.shp"),
                       filetype = "ESRI Shapefile",
                       overwrite = T)
    message(paste0("pour points done"))
    
    # derive groundwatersheds using derived D8 flow direction raster and pour points
    whitebox::wbt_watershed(d8_pntr = file.path(dat_loc, world_regions[w], paste0("d8_ocean_rm_month_", m, ".tif")), 
                            pour_pts = file.path(dat_loc, world_regions[w], "pour_points_protected_contigID.shp"), 
                            output = file.path(dat_loc, world_regions[w], paste0("gwsheds_individual_month_", m, ".tif")), 
                            esri_pntr = FALSE)
    message(paste0("individual groundwatersheds done"))
    
    # reclassify groundwatersheds based on WDPDA membership
    rcl_df = data.frame(pp_ID$fid, # this is the protected area id (set to)
                        pp_ID$ID)  # this is the pour point index  (set from)
    colnames(rcl_df) = NA

    readr::write_delim(x = rcl_df,
                       file = file.path(dat_loc, world_regions[w], "basin_assign.txt"),
                       delim = ",",
                       col_names = F)
    
    whitebox::wbt_reclass_from_file(input = file.path(dat_loc, world_regions[w], paste0("gwsheds_individual_month_", m, ".tif")), 
                                    reclass_file = file.path(dat_loc, world_regions[w], "basin_assign.txt"), 
                                    output = file.path(dat_loc, world_regions[w], paste0("gwsheds_cpa_grouped_month_", m, ".tif")))
    message(paste0("contiguous protected area grouped groundwatersheds done"))
    
    print(paste0(world_regions[w], " month ", m, " complete!")) 
    
    wtelv_rgn = gdepp_rgn = prot_area = d8 = NULL 
  }
}
