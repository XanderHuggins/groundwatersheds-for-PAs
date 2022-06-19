# Name: a3-stats-merging.R
# Description: Merge regional stats into single data set. 

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# loop through world regions
for (w in 1:length(world_regions)) {
  
  if (w == 1) {
    df1  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_protected_area_area.csv"))
    df2  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_groundwatershed_area.csv"))
    df3  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_ecolcond_area.csv"))
    df4  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_unprotgwshed_area.csv"))
    df5  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_slope.csv"))
    df6  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_aridity.csv"))
    df7  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_modgrad.csv"))
    df8  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_unprotgwshed_c1to6_area.csv"))
    df9  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_transbound_protectedarea.csv"))
    df10 = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_transbound_groundwatershed.csv"))
  }
  
  if (w > 1) {
    a_df1  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_protected_area_area.csv"))
    a_df2  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_groundwatershed_area.csv"))
    a_df3  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_ecolcond_area.csv"))
    a_df4  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_unprotgwshed_area.csv"))
    a_df5  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_slope.csv"))
    a_df6  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_aridity.csv"))
    a_df7  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_modgrad.csv"))
    a_df8  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_unprotgwshed_c1to6_area.csv"))
    a_df9  = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_transbound_protectedarea.csv"))
    a_df10 = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_transbound_groundwatershed.csv"))
    
    df1  = rbind(df1, a_df1)
    df2  = rbind(df2, a_df2)
    df3  = rbind(df3, a_df3)
    df4  = rbind(df4, a_df4)
    df5  = rbind(df5, a_df5)
    df6  = rbind(df6, a_df6)
    df7  = rbind(df7, a_df7)
    df8  = rbind(df8, a_df8)
    df9  = rbind(df9, a_df9)
    df10 = rbind(df10, a_df10)
    }
}

# Handle 'duplicates' in summary df (occurs if groundwatersheds are "split" between world regions)
# Need to sum by CPA_ID for features that span two regions:
df1  = df1 |> group_by(CPA_ID) |> summarize(area = sum(area, na.rm = T))
df2  = df2 |> group_by(CPA_ID) |> summarize(gwshed_area = sum(gwshed_area, na.rm = T))
df3  = df3 |> group_by(CPA_ID) |> summarize(ecolcond_area = sum(ecolcond_area, na.rm = T))
df4  = df4 |> group_by(CPA_ID) |> summarize(unprot_gwshed_area = sum(unprot_gwshed_area, na.rm = T))
df8  = df8 |> group_by(CPA_ID) |> summarize(unprot_gwshed_area_c1to6 = sum(unprot_gwshed_area_c1to6, na.rm = T))
df9  = df9 |> group_by(CPA_ID) |> summarize(prot_area_transbound = max(prot_area_transbound, na.rm = T))
df10 = df10 |> group_by(CPA_ID) |> summarize(gw_sheds_transbound = max(gw_sheds_transbound, na.rm = T))

# The following need area-weighting to merge
df5 = merge(x = df5, y = df1, by = "CPA_ID", all.x = T)
df5 = df5 |> group_by(CPA_ID) |> summarize(slope = weighted.mean(x = slope, w = area, na.rm = T))   

df6 = merge(x = df6, y = df1, by = "CPA_ID", all.x = T)
df6 = df6 |> group_by(CPA_ID) |> summarize(aridity = weighted.mean(x = aridity, w = area, na.rm = T))   

df7 = merge(x = df7, y = df1, by = "CPA_ID", all.x = T)
df7 = df7 |> group_by(CPA_ID) |> summarize(modgrad = weighted.mean(x = modgrad, w = area, na.rm = T))   

# merge all summary statistics together
c_df = base::merge(x = df1,  y = df2, by = "CPA_ID", all = T)
c_df = base::merge(x = c_df, y = df3, by = "CPA_ID", all = T)
c_df = base::merge(x = c_df, y = df4, by = "CPA_ID", all = T)
c_df = base::merge(x = c_df, y = df5, by = "CPA_ID", all = T)
c_df = base::merge(x = c_df, y = df6, by = "CPA_ID", all = T)
c_df = base::merge(x = c_df, y = df7, by = "CPA_ID", all = T)
c_df = base::merge(x = c_df, y = df8, by = "CPA_ID", all = T)
c_df = base::merge(x = c_df, y = df9, by = "CPA_ID", all = T)
c_df = base::merge(x = c_df, y = df10, by = "CPA_ID", all = T)

# check no duplicates in final dataset
freqdf = table(c_df$CPA_ID) %>% as.data.frame() %>% filter(Freq > 1) %>% pull(Var1)
freqdf # confirmed - no duplicate CPA ID entries over 43544 continguous protected areas

# set NA values to 0 for select datasets
c_df$unprot_gwshed_area[is.na(c_df$unprot_gwshed_area)] = 0
c_df$gwshed_area[is.na(c_df$gwshed_area)] = 0
c_df$ecolcond_area[is.na(c_df$ecolcond_area)] = 0
c_df$unprot_gwshed_area_c1to6[is.na(c_df$unprot_gwshed_area_c1to6)] = 0
c_df$prot_area_transbound[is.na(c_df$prot_area_transbound)] = 0
c_df$gw_sheds_transbound[is.na(c_df$gw_sheds_transbound)] = 0

# calculate metrics
c_df$RGS = c_df$gwshed_area / c_df$ecolcond_area # Relative groundwater size (RGS)
# c_df$ECD = c_df$ecolcond_area / c_df$area # Ecological connectivity density (ECD) - not used 
# c_df$GAR = c_df$gwshed_area / c_df$area # Groundwatershed area ratio (GAR) - not used
c_df$UPR = c_df$unprot_gwshed_area / c_df$gwshed_area # Unprotected ratio (UPR)

readr::write_csv(c_df, file = file.path(dat_loc, "STATS.csv"))
