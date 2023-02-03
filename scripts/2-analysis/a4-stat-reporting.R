# Name: a4-stat-reporting.R
# Description: Print statistics for reporting in manuscript

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# import main data sheet
s_df = readr::read_csv(file.path(dat_loc, "report_STATS.csv"))
nrow(s_df) # 32,490

sum(s_df$gwshed_area, na.rm = T)/1e12 # 21.96611 million km2 - area of groundwatersheds of protected areas considered
sum(s_df$area, na.rm = T)/1e12 # 12.55276 million km2 - area of protected areas considered
21.96611/12.55276 # 1.749903

# calculate median and IQR of RGS:
median(s_df$RGS) ## 1.456501
quantile(s_df$RGS, 0.25) # 1.167467
quantile(s_df$RGS, 0.75) # 1.937667

# Groundwatersheds that are partially underprotected
s_df |> dplyr::filter(unprot_gwshed_area > 0) |> nrow() / # 27,651 
  s_df |> dplyr::filter(gde_area > 0) |> nrow() # 32,490, frac = 85.10619%

# proportion of groundwatersheds in protected areas
1 - sum(s_df$unprot_gwshed_area, na.rm = T)/sum(s_df$gwshed_area, na.rm = T) # 54.36881%

# frequency of transboundary groundwatersheds and transboundary protected areas
s_df |> dplyr::filter(prot_area_transbound == 1) |> nrow() # 940 protected areas are transboundary
s_df |> dplyr::filter(gw_sheds_transbound == 1) |> nrow() # 1379 groundwatersheds are transboundary
s_df |> filter(gw_sheds_transbound == 1 & prot_area_transbound == 0) |> nrow() # 454 groundwatersheds are TB but the PA is not TB

# calculate median and IQR of UGR:
median(s_df$UGR) # 0.5237834
quantile(s_df$UGR, 0.25) # 0.1666321
quantile(s_df$UGR, 0.75) # 0.7990331