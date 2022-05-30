# Name: a4-stat-reporting.R
# Description: Calculate select statistics for reporting in manuscript. 

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import main data sheet
s_df <- readr::read_csv(file.path(wd, paste0("data/STATS.csv")))

head(s_df)
nrow(s_df) # 43544

sum(s_df$gwshed_area/1e6, na.rm = T)/1e6 # 19.1 million km2 - area of groundwatersheds of protected areas considered
sum(s_df$area/1e6, na.rm = T)/1e6 # 12.6 million km2 - area of protected areas considered

s_df |> filter(unprot_gwshed_area > 0) |> nrow() / # 26743 
  s_df |> filter(ecolcond_area > 0) |> nrow() # 30801, frac = 87%

s_df |> filter(unprot_gwshed_area > 0) |> nrow() / # 26743 
  s_df |> nrow() # 43544, frac = 61%

s_df |> filter(unprot_gwshed_area/area > 0.5) |> nrow() / # 18818 
  s_df |> nrow() # 43%

# proportion of groundwatersheds in protected areas
1 - sum(s_df$unprot_gwshed_area, na.rm = T)/sum(s_df$gwshed_area, na.rm = T)

# frequency of transboundary groundwatersheds and transboundary protected areas
s_df |> filter(prot_area_transbound == 1) |> nrow() # 995 protected areas are transboundary
s_df |> filter(gw_sheds_transbound == 1) |> nrow() # 1332 groundwatersheds are transboundary

s_df |> filter(gw_sheds_transbound == 1 & prot_area_transbound == 0) |> nrow() # 439