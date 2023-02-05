# Name: a4-stat-reporting.R
# Description: Print statistics for reporting in manuscript

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# import main data sheet
s_df = readr::read_csv(file.path(dat_loc, "report_STATS.csv"))
nrow(s_df) # 32,490

round(sum(s_df$gwshed_area)/1e12, 1)  # 22.0 million km2 - area of groundwatersheds
round(sum(s_df$area)/1e12, 1) # 12.6 million km2 - area of protected areas
round(sum(s_df$gwshed_area)/sum(s_df$area), 2) # 1.75

# calculate median and IQR of RGS:
median(s_df$RGS) |> round(2) # 1.46
quantile(s_df$RGS, 0.25) |> round(2) # 1.17
quantile(s_df$RGS, 0.75) |> round(2) # 1.94

# calculate median and IQR of UGR:
median(s_df$UGR) |> round(2) # 0.52
quantile(s_df$UGR, 0.25) |> round(2) # 0.17
quantile(s_df$UGR, 0.75) |> round(2) # 0.80

# frequency of transboundary groundwatersheds and transboundary protected areas
s_df |> dplyr::filter(prot_area_transbound == 1) |> nrow() # 940 protected areas are transboundary
s_df |> dplyr::filter(gw_sheds_transbound == 1) |> nrow() # 1,379 groundwatersheds are transboundary
s_df |> filter(gw_sheds_transbound == 1 & prot_area_transbound == 0) |> nrow() # 454 groundwatersheds are TB but the PA is not TB

# Groundwatersheds that are partially underprotected
s_df |> dplyr::filter(unprot_gwshed_area > 0) |> nrow() / # 27,651 
  s_df |> dplyr::filter(gde_area > 0) |> nrow() # 32,490
round(27651/32490, 2) # 85%

# proportion of groundwatersheds in protected areas
round(1 - sum(s_df$unprot_gwshed_area)/sum(s_df$gwshed_area), 2) # 54%