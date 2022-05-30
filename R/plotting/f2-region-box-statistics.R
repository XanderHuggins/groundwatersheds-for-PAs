# Name: f2-callout-region-stats.R
# Description: Calculate metrics for callout boxes in figures.

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import data sheet
s_df <- readr::read_csv(file.path(wd, paste0("data/STATS.csv")))

# Import boxes for each plot (done manually)
region <- sf::read_sf("C:/Users/xande/Desktop/iberia-box-cpa-1.sqlite")
cpa_list <- region$fid

box_df <- s_df |> filter(CPA_ID %in% cpa_list)

# calculate RGS
all_gws <- box_df$gwshed_area |> sum(na.rm = T)
ecoarea <- box_df$ecolcond_area |> sum(na.rm = T)
message("RGS is ", all_gws/ecoarea)

# calculate UPR
all_gws <- box_df$gwshed_area |> sum(na.rm = T)
unprot <- box_df$unprot_gwshed_area |> sum(na.rm = T)
message("UPR is ", unprot/all_gws)