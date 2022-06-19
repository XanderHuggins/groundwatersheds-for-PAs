# Name: a7-uncertainty-stats-merging.R
# Description: Merge regional stats into single data set.

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source))

for (w in 1:length(world_regions)) {
  
  for (m in 1:12) {
    if (m == 1) {
      
      df_gwshed = readr::read_csv(file.path(dat_loc, world_regions[w], paste0("STAT_groundwatershed_area_month_", m, ".csv")))
      colnames(df_gwshed) = c('CPA_ID', "gwshed_area")
      df_gwshed  = df_gwshed |> group_by(CPA_ID) |> summarize(gwshed_area = sum(gwshed_area, na.rm = T))
    }
    
    if (m > 1) {
      df_gwshed_a = readr::read_csv(file.path(dat_loc, world_regions[w], paste0("STAT_groundwatershed_area_month_", m, ".csv")))
      colnames(df_gwshed_a) = c('CPA_ID', paste0("gwshed_", m))
      df_gwshed = merge(x = df_gwshed, y = df_gwshed_a, by.x = 'CPA_ID', by.y = 'CPA_ID', all.x = TRUE)
    }
    
    readr::write_csv(df_gwshed, file = file.path(dat_loc, world_regions[w], "uncertainty_gwshed.csv"))
  
  }
}
