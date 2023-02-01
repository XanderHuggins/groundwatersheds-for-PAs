# Name: p2-wte-ann-from-mo.R
# Description: Calculate annual water table elevataion from monthly means

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

for (i in 1:length(topo_folders)) {

  # import monthly WT elevations and weight by days in month
  month_frac = c(31, 28.25, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31) / 365.25
  
  wte_mo  = terra::rast(file.path(dat_loc, world_regions[i], paste0("wt_elev_month_", 1, ".tif"))) * month_frac[1]
  
  for (m in 2:12) {
    wte_mo = wte_mo + 
      (terra::rast(file.path(dat_loc, world_regions[i], paste0("wt_elev_month_", m, ".tif"))) * month_frac[m]) # add weighted month
    print(m)
  }
  
  terra::writeRaster(x = wte_mo, 
                     filename = file.path(dat_loc, world_regions[i], "wt_elev_annual_from_months.tif"),
                     filetype = "GTiff", overwrite = T)
  
  wte_annual = wte_mo = rast_diff = NULL 
  
  message("region ", i, " competed")

} 

