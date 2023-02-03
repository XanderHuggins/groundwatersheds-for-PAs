# Name: as4-stat-reporting-uncertainty.R
# Description: Calculate uncertainty statistics for reporting in supplementary information. 

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# import main data sheet
for (i in 1:length(world_regions)) {
  assign(paste0("gwshed_size_", world_regions[i]), 
         readr::read_csv(file.path(dat_loc, world_regions[i], "uncertainty_gwshed.csv")))
}

for (i in 1:12){
  tot_size = rep(0, 1)
  for (w in 1:length(world_regions)) {
    stat_df = readr::read_csv(file.path(dat_loc, world_regions[w], paste0("STAT_groundwatershed_area_month_", i, ".csv")))
    tot_size = tot_size + stat_df$gwshed_area |> sum()
    
  }
  message("for month ", i, " the total groundwatershed size is: ", tot_size/1e12)
}

# now calculate sums for every month
month_sums = rep(NA, 12)

for (i in 1:12) {

  na_size = gwshed_size_NorthAmerica[,i+1] |> sum(na.rm = T)
  sa_size = gwshed_size_SouthAmerica[,i+1] |> sum(na.rm = T)
  eu_size = gwshed_size_Eurasia[,i+1] |> sum(na.rm = T)
  oc_size = gwshed_size_Oceania[,i+1] |> sum(na.rm = T)
  af_size = gwshed_size_Africa[,i+1] |> sum(na.rm = T)
  
  month_sums[i] = sum(na_size, sa_size, eu_size, oc_size, af_size)
}


# compare to annual
s_df = readr::read_csv(file.path(dat_loc, "report_STATS.csv"))
sum(s_df$gwshed_area, na.rm = T)/1e12

(month_sums-sum(s_df$gwshed_area, na.rm = T))/1e12

sd(month_sums) / mean(month_sums) # 0.00623855
max(month_sums)
min(month_sums)