# Name: as2-stat-uncertainty.R
# Description: Calculate summary statistics for groundwatersheds per protected area across twelve monthly mean water tables

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# loop through world regions
for (w in 1:length(world_regions)) {
  
  message(paste0("starting: ", world_regions[w], "..."))
  
  for (m in 1:12) {
    
    # import data 
    surfarea = terra::rast(file.path(dat_loc, world_regions[w], "grid_area.tif"))
    prot_1t3 = terra::rast(file.path(dat_loc, world_regions[w], "protected_areas_ID.tif"))
    gw_sheds_mo  = terra::rast(file.path(dat_loc, world_regions[w], paste0("gwsheds_cpa_grouped_month_", m, ".tif")))
    
    # groundwatershed area for the given month
    stat_df = terra::zonal(x = surfarea, z = gw_sheds_mo, fun = sum, na.rm = T)
    colnames(stat_df) = c("CPA_ID", "gwshed_area")
    readr::write_csv(stat_df, file = file.path(dat_loc, world_regions[w], paste0("STAT_groundwatershed_area_month_", m, ".csv")))
    
    print(m)
  }
}
