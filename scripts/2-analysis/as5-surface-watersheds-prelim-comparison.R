# Name: as5-surface-watershed-prelim-comparison.R
# Description: A very preliminary/rudimentary analysis enabling a rough comparison to surface watersheds

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# calculate areas of hydrobasin level 10 and write to RDS
for (w in 1:length(world_regions)) {
  
  message(paste0("starting: ", world_regions[w], "..."))

  # import region-specific datasets
  hybas10   = raster::raster(file.path(dat_loc, world_regions[w], "hybas_l10_flt8s.tif")) # hydrobasins level 10
  grid_area = raster::raster(file.path(dat_loc, world_regions[w], "grid_area.tif")) # grid cell surface area in m2
  
  message(paste0("data import done"))
  
  # zonalDT as faster function than terra::zonal() for large files
  area_df = rasterDT::zonalDT(x = grid_area, z = hybas10, fun = sum, na.rm = T) |> 
    as.data.frame() |> set_colnames(c('hybas10_id', 'area_m2'))
  area_df$area_km2 = area_df$area_m2/1e6
  
  readr::write_rds(area_df, file = file.path(dat_loc, world_regions[w], "hybas_l10_flt8s_surface_area.rds"))
  message("rds writing done")
  area_df = hybas10 = grid_area = NULL
}
 
# calculate under-protected areas of hydrobasin level 10 and write to RDS
for (w in 1:length(world_regions)) {
  
  message(paste0("starting: ", world_regions[w], "..."))
  
  # import region-specific datasets
  hybas10   = terra::rast(file.path(dat_loc, world_regions[w], "hybas_l10_flt8s.tif")) # hydrobasins level 10
  grid_area = terra::rast(file.path(dat_loc, world_regions[w], "grid_area.tif")) # grid cell surface area in m2
  prot_area = terra::rast(file.path(dat_loc, world_regions[w], "protected_areas_ID.tif"))
  message(paste0("data import done"))
  
  # create reclassification matrix to convert prot_area to binary
  id_list = unique(prot_area)
  rcl_df = data.frame(rep(1, length(id_list)), id_list) |> set_colnames(c('to', 'from'))
  colnames(rcl_df) = NA
  
  readr::write_delim(x = rcl_df, file = file.path(dat_loc, world_regions[w], "prot_area_binary.txt"), delim = ";", col_names = F)
  
  whitebox::wbt_reclass_from_file(input = file.path(dat_loc, world_regions[w], "protected_areas_ID.tif"), 
                                  output = file.path(dat_loc, world_regions[w], "protected_areas_bool.tif"),
                                  reclass_file = file.path(dat_loc, world_regions[w], "prot_area_binary.txt"))
  
  prot_area = terra::rast(file.path(dat_loc, world_regions[w], "protected_areas_bool.tif"))
  
  # remove hybas cells in protected areas
  region_hybas10_m = terra::mask(x = hybas10, mask = prot_area, maskvalues = 1, wopt=list(datatype="FLT8S"))
  
  # zonalDT as faster function than terra::zonal() for large files
  area_df = rasterDT::zonalDT(x = raster(grid_area), z = raster(region_hybas10_m), fun = sum, na.rm = T) |> 
    as.data.frame() |> set_colnames(c('hybas10_id', 'area_m2'))
  area_df$area_km2 = area_df$area_m2/1e6
  
  readr::write_rds(area_df, file = file.path(dat_loc, world_regions[w], "hybas_l10_flt8s_underprot_surface_area.rds"))
  message("rds writing done")
} 

# create unique combinations of protected areas and hydrobasins, based on common intersection with GDEs
for (w in 1:length(world_regions)) {
  
  message(paste0("starting: ", world_regions[w], "..."))
  w = 1
  # import region-specific datasets
  hybas10   = terra::rast(file.path(dat_loc, world_regions[w], "hybas_l10_flt8s.tif")) # hydrobasins level 10
  
  ecopp_rgn = terra::rast(file.path(dat_loc, world_regions[w], "gde_pourpoint.tif"))
  # ecopp_rgn[ecopp_rgn == 0] = NA
  
  prot_area_ID = terra::rast(file.path(dat_loc, world_regions[w], "protected_areas_ID.tif"))
  prot_area_bool = terra::rast(file.path(dat_loc, world_regions[w], "protected_areas_bool.tif"))
  message(paste0("data import done"))
  
  # identify intersection of ecologically connected cells + protected areas
  pp_ID = ecopp_rgn * prot_area_ID
  
  hybas_mask = ecopp_rgn * prot_area_bool
  hybas_mask[is.na(hybas_mask)] = 0
  
  hybas_ID = terra::mask(x = hybas10, mask = hybas_mask, maskvalues = 0, wopt=list(datatype="FLT8S"))
  message("masked ID rasters done")
  
  # identify unique combinations of protected area IDs and hybas IDs
  stack_r = c(pp_ID, hybas_ID)
  names(stack_r) = c('PA_ID', 'hybas_ID')
  unique_combs = terra::unique(stack_r) |> drop_na()
  message("unique combinations identified")
  
  readr::write_rds(unique_combs, file = file.path(dat_loc, world_regions[w], "PA_hybas_combs_flt8s.rds"))
  message("rds writing done")
}

# Calculate unprotected surface watershed ratio (USR) for HydroBASINS level 10

# get requisite areas for each protected area
for (w in 2:length(world_regions)) {
  
  # w = 1
  message(paste0("starting: ", world_regions[w], "..."))
  
  # read in data
  comb_df = readr::read_rds(file.path(dat_loc, world_regions[w],  "PA_hybas_combs_flt8s.rds")) # combinations
  hyb_area = readr::read_rds(file.path(dat_loc, world_regions[w], "hybas_l10_flt8s_surface_area.rds")) # all hybas surface area
  unp_area = readr::read_rds(file.path(dat_loc, world_regions[w], "hybas_l10_flt8s_underprot_surface_area.rds")) # underprotected hybas surface area

  # Create hybas IDs at levels 9 -> 6 
  # for comb_df 
  comb_df$hybas_ID_l9 = comb_df$hybas_ID %/% 1e1
  comb_df$hybas_ID_l8 = comb_df$hybas_ID %/% 1e2
  comb_df$hybas_ID_l7 = comb_df$hybas_ID %/% 1e3
  comb_df$hybas_ID_l6 = comb_df$hybas_ID %/% 1e4
  
  # for hyb_area
  hyb_area$hybas_ID_l9 = hyb_area$hybas10_id %/% 1e1
  hyb_area$hybas_ID_l8 = hyb_area$hybas10_id %/% 1e2
  hyb_area$hybas_ID_l7 = hyb_area$hybas10_id %/% 1e3
  hyb_area$hybas_ID_l6 = hyb_area$hybas10_id %/% 1e4
  
  # for unp_area
  unp_area$hybas_ID_l9 = unp_area$hybas10_id %/% 1e1
  unp_area$hybas_ID_l8 = unp_area$hybas10_id %/% 1e2
  unp_area$hybas_ID_l7 = unp_area$hybas10_id %/% 1e3
  unp_area$hybas_ID_l6 = unp_area$hybas10_id %/% 1e4
  
  # Create data-frame for each protected area
  summary_df = data.frame(PA_ID = unique(comb_df$PA_ID), 
                          HYB_area_l10 = rep(NA), UNP_area_l10 = rep(NA),
                          HYB_area_l9  = rep(NA), UNP_area_l9  = rep(NA),
                          HYB_area_l8  = rep(NA), UNP_area_l8  = rep(NA),
                          HYB_area_l7  = rep(NA), UNP_area_l7  = rep(NA),
                          HYB_area_l6  = rep(NA), UNP_area_l6  = rep(NA))
    
  for (i in 1:nrow(summary_df)) {
    # i = 3
    # hybas "list" (vector of touching basins)
    hyb_list_up10 = comb_df |> dplyr::filter(PA_ID == summary_df$PA_ID[i]) |> dplyr::pull(hybas_ID)
    hyb_list_up9  = comb_df |> dplyr::filter(PA_ID == summary_df$PA_ID[i]) |> dplyr::pull(hybas_ID_l9)
    hyb_list_up8  = comb_df |> dplyr::filter(PA_ID == summary_df$PA_ID[i]) |> dplyr::pull(hybas_ID_l8)
    hyb_list_up7  = comb_df |> dplyr::filter(PA_ID == summary_df$PA_ID[i]) |> dplyr::pull(hybas_ID_l7)
    hyb_list_up6  = comb_df |> dplyr::filter(PA_ID == summary_df$PA_ID[i]) |> dplyr::pull(hybas_ID_l6)
    
    # calculate total upstream watershed area
    summary_df$HYB_area_l10[i] = hyb_area |> dplyr::filter(hybas10_id %in%  hyb_list_up10) |> dplyr::pull(area_km2) |> sum(na.rm = T) 
    summary_df$HYB_area_l9[i]  = hyb_area |> dplyr::filter(hybas_ID_l9 %in% hyb_list_up9)  |> dplyr::pull(area_km2) |> sum(na.rm = T) 
    summary_df$HYB_area_l8[i]  = hyb_area |> dplyr::filter(hybas_ID_l8 %in% hyb_list_up8)  |> dplyr::pull(area_km2) |> sum(na.rm = T) 
    summary_df$HYB_area_l7[i]  = hyb_area |> dplyr::filter(hybas_ID_l7 %in% hyb_list_up7)  |> dplyr::pull(area_km2) |> sum(na.rm = T) 
    summary_df$HYB_area_l6[i]  = hyb_area |> dplyr::filter(hybas_ID_l6 %in% hyb_list_up6)  |> dplyr::pull(area_km2) |> sum(na.rm = T) 
    
    # calculate underprotected upstream watershed area
    summary_df$UNP_area_l10[i] = unp_area |> dplyr::filter(hybas10_id  %in% hyb_list_up10) |> dplyr::pull(area_km2) |> sum(na.rm = T) 
    summary_df$UNP_area_l9[i]  = unp_area |> dplyr::filter(hybas_ID_l9 %in% hyb_list_up9)  |> dplyr::pull(area_km2) |> sum(na.rm = T) 
    summary_df$UNP_area_l8[i]  = unp_area |> dplyr::filter(hybas_ID_l8 %in% hyb_list_up8)  |> dplyr::pull(area_km2) |> sum(na.rm = T) 
    summary_df$UNP_area_l7[i]  = unp_area |> dplyr::filter(hybas_ID_l7 %in% hyb_list_up7)  |> dplyr::pull(area_km2) |> sum(na.rm = T) 
    summary_df$UNP_area_l6[i]  = unp_area |> dplyr::filter(hybas_ID_l6 %in% hyb_list_up6)  |> dplyr::pull(area_km2) |> sum(na.rm = T) 
    
    hyb_list_up10 = hyb_list_up9 = hyb_list_up8 = hyb_list_up7 = hyb_list_up6 = NULL
    
    message(world_regions[w], " | progress: ", round(i/nrow(summary_df), 2))
    
  }

  readr::write_rds(summary_df, file = file.path(dat_loc, world_regions[w], "PA_usr_inputs.rds"))
}

# create global summary df
usr_df = readr::read_rds(file.path(dat_loc, world_regions[1], "PA_usr_inputs.rds"))

for (i in 2:length(world_regions)) { usr_df = rbind(usr_df, readr::read_rds(file.path(dat_loc, world_regions[i], "PA_usr_inputs.rds")))}

usr_df = usr_df |>
  group_by(PA_ID) |> 
  summarise(HYB_area_l10 = sum(HYB_area_l10, na.rm = T),
            UNP_area_l10 = sum(UNP_area_l10, na.rm = T),
            HYB_area_l9 =  sum(HYB_area_l9, na.rm = T),
            UNP_area_l9 =  sum(UNP_area_l9, na.rm = T),
            HYB_area_l8 =  sum(HYB_area_l8, na.rm = T),
            UNP_area_l8 =  sum(UNP_area_l8, na.rm = T),
            HYB_area_l7 =  sum(HYB_area_l7, na.rm = T),
            UNP_area_l7 =  sum(UNP_area_l7, na.rm = T),
            HYB_area_l6 =  sum(HYB_area_l6, na.rm = T),
            UNP_area_l6 =  sum(UNP_area_l6, na.rm = T)) |> as.data.frame()

usr_df$usr_10 = usr_df$UNP_area_l10 / usr_df$HYB_area_l10
usr_df$usr_9 = usr_df$UNP_area_l9 / usr_df$HYB_area_l9
usr_df$usr_8 = usr_df$UNP_area_l8 / usr_df$HYB_area_l8
usr_df$usr_7 = usr_df$UNP_area_l7 / usr_df$HYB_area_l7
usr_df$usr_6 = usr_df$UNP_area_l6 / usr_df$HYB_area_l6
summary(usr_df)

readr::write_rds(usr_df, file = file.path(dat_loc, "World/PA_usr_level7_to_10.rds"))

# Plot distribution of underprotected ratio for levels 10-7, and in comparison to groundwatershed UGR
library(ggridges)
library(forcats)

usr_df = read_rds(file.path(dat_loc, "World/PA_usr_level7_to_10.rds"))
s_df = readr::read_csv(file.path(dat_loc, "report_STATS.csv"))

# keep only surface watersheds for protected areas that also have a groundwatershed
usr_df = usr_df |> dplyr::filter(PA_ID %in% s_df$CPA_ID) # rerun above and check 
  
gw_df = readr::read_csv(file.path(dat_loc, "report_STATS.csv"))

merged_df = merge(x = usr_df, y = gw_df, by.x = "PA_ID", by.y = "CPA_ID")

merged_df$pa_hybas10_f = (merged_df$HYB_area_l10 - (merged_df$area/1e6) ) / merged_df$HYB_area_l10
merged_df$pa_hybas09_f = (merged_df$HYB_area_l9 - (merged_df$area/1e6) ) / merged_df$HYB_area_l9
merged_df$pa_hybas08_f = (merged_df$HYB_area_l8 - (merged_df$area/1e6) ) / merged_df$HYB_area_l8
merged_df$pa_hybas07_f = (merged_df$HYB_area_l7 - (merged_df$area/1e6) ) / merged_df$HYB_area_l7

hb7_df <- data.frame(x = 1,
                      y05 = quantile(usr_df$usr_7, 0.05),
                      y25 = quantile(usr_df$usr_7, 0.25),
                      y50 = quantile(usr_df$usr_7, 0.50),
                      y75 = quantile(usr_df$usr_7, 0.75),
                      y95 = quantile(usr_df$usr_7, 0.95)
)

hb8_df <- data.frame(x = 1,
                      y05 = quantile(usr_df$usr_8, 0.05),
                      y25 = quantile(usr_df$usr_8, 0.25),
                      y50 = quantile(usr_df$usr_8, 0.50),
                      y75 = quantile(usr_df$usr_8, 0.75),
                      y95 = quantile(usr_df$usr_8, 0.95)
)

hb9_df <- data.frame(x = 1,
                      y05 = quantile(usr_df$usr_9, 0.05),
                      y25 = quantile(usr_df$usr_9, 0.25),
                      y50 = quantile(usr_df$usr_9, 0.50),
                      y75 = quantile(usr_df$usr_9, 0.75),
                      y95 = quantile(usr_df$usr_9, 0.95)
)

hb10_df <- data.frame(x = 1,
                 y05 = quantile(usr_df$usr_10, 0.05),
                 y25 = quantile(usr_df$usr_10, 0.25),
                 y50 = quantile(usr_df$usr_10, 0.50),
                 y75 = quantile(usr_df$usr_10, 0.75),
                 y95 = quantile(usr_df$usr_10, 0.95)
)

# boxplots comparing the four hydrobasin levels

ggplot() +
  geom_boxplot(data = hb10_df, 
               aes(x = 1, ymin = y05, lower = y25, middle = y50, upper = y75, ymax = y95), stat = "identity", fill = "#511C56", width = 0.5) +
  geom_boxplot(data = hb9_df,  
               aes(x = 2, ymin = y05, lower = y25, middle = y50, upper = y75, ymax = y95), stat = "identity", fill = "#AE2A3E", width = 0.5) +
  geom_boxplot(data = hb8_df,  
               aes(x = 3, ymin = y05, lower = y25, middle = y50, upper = y75, ymax = y95), stat = "identity", fill = "#F08A38", width = 0.5) +
  geom_boxplot(data = hb7_df,  
               aes(x = 4, ymin = y05, lower = y25, middle = y50, upper = y75, ymax = y95), stat = "identity", fill = "#FFD353", width = 0.5) +
  coord_flip() +
  my_theme + 
  # theme(axis.text=element_text(colour="black")) +
  theme(axis.text=element_text(colour="black"),
        plot.margin = unit(c(2,5,2,2), "mm")) +
  # coord_cartesian(xlim = c(0.25,1)) +
  ylab('') + xlab('')

ggsave(file = file.path(plot_sv,"underprotected_surface_hybas.png"), 
       plot = last_plot(), device = "png",
       width = 500/4, height = 250/6, units = "mm", dpi = 400) 



# Compare underprotected ratio of localized groundwatersheds with overestimated hydrobasin level 10
ggplot() +
  geom_density_ridges(data = usr_df, aes(x = usr_10, y = 1), stat = "binline", bins = 20, panel_scaling = T, fill = met.brewer("Tam", 12)[10]) +
  geom_density_ridges(data = gw_df, aes(x = UPR, y = 1), stat = "binline", scale = 1, bins = 20, fill = 'navyblue', alpha = 0.8) +
  my_theme + theme(axis.text=element_text(colour="black")) +
  coord_cartesian(xlim = c(0,1)) +
  theme(axis.text=element_text(colour="black"),
        plot.margin = unit(c(2,5,2,2), "mm")) +
  ylab('') + xlab('')

ggsave(file = file.path(plot_sv,"UGR_vs_level10_hybas.png"), 
       plot = last_plot(), device = "png",
       width = 500/4, height = 250/6, units = "mm", dpi = 400) 
