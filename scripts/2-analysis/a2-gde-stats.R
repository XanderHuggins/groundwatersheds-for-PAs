# Name: a2-gde-stats.R
# Description: Calculate summary statistics for our derived groundwater-dependent ecosystems

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# load gde tiles and area raster
gde_c = terra::rast(file.path(dat_loc, "World/GDE_classification_composite.tif"))
sarea = terra::rast(file.path(dat_loc, "World/input/wgs-area-ras-30-arcsec.tif"))

# calculate area sums 
stat_df = rasterDT::zonalDT(x = raster(sarea), z = raster(gde_c), fun = sum, na.rm = T) |> 
  as.data.frame()
readr::write_rds(stat_df, file = file.path(dat_loc, "World/gde_class_area.rds"))

# read writted .rds so no need to re-compute each run
stat_df = readr::read_rds(file.path(dat_loc, "World/gde_class_area.rds"))
stat_df = stat_df |> filter(z != 0) # filter out areas with no GDEs

stat_df$plot_col = c("#EC2B31", # 001 
                     "#3153A4", # 010
                     "#7E287F", # 011
                     "#5CB953", # 100
                     "#FFE520", # 101
                     "#137A8D", # 110
                     "#00E6FF" # 111
                     )

stat_df$rank = rank(-stat_df$lyr.1)
stat_df = stat_df[order(stat_df$rank),] 

stat_df$pct = stat_df$lyr.1 / sum(stat_df$lyr.1, na.rm = T)
denom = sum(stat_df$lyr.1, na.rm = T)

ggplot(data = stat_df, aes(x = as.factor(rank), y = pct, fill = as.factor(rank))) +
  geom_bar(stat = 'identity', color = 'black', linewidth = 3, width = 1) +
  scale_fill_manual(values = c(stat_df$plot_col)) +
  coord_cartesian(expand = 0, ylim=c(0, 0.65),clip = "off") +
  cus_theme + theme(axis.ticks.x = element_line(size = 1)) 

ggsave(plot = last_plot(), 
       file.path(plot_sv, "gde_class_area.pdf"), 
       dpi = 500, width = 6, height = 4, units = "in")


# create plot of percent of GDEs that are protected 

# load protection rasters
pa_hi = terra::rast(file.path(wdpa_wd,  "protected_areas_classes_13_filtered_AT_land.tif"))
pa_lo = terra::rast(file.path(wdpa_wd,  "protected_areas_classes_46_filtered_AT_land.tif"))

# create high-low protected area raster:
pa_id = pa_lo
pa_id[pa_hi == 1] = 2
pa_id[is.na(pa_id)] = 0

terra::writeRaster(x = pa_id,
                   filename = file.path(dat_loc, "World/PA_high_low_id.tif"),
                   filetype = "GTiff", overwrite = T)


# create bivariate raster that combined pa_id with gde_c
pa_gde = (pa_id * 1e3) + gde_c

terra::writeRaster(x = pa_gde,
                   filename = file.path(dat_loc, "World/GDE_PA_bivariate_id.tif"),
                   filetype = "GTiff", overwrite = T)

stat_df = rasterDT::zonalDT(x = raster(sarea), z = raster(pa_gde), fun = sum, na.rm = T) |> 
  as.data.frame()

readr::write_rds(stat_df, file = file.path(dat_loc, "World/PA_gde_bivariate_area.rds"))
stat_df = readr::read_rds(file.path(dat_loc, "World/PA_gde_bivariate_area.rds"))

stat_df = stat_df |> filter(z != 0) |> set_colnames(c('z', 'area'))

stat_df$pa = stat_df$z %/% 1e3
stat_df$gde = stat_df$z - (stat_df$pa * 1e3)

# create a unique gde df to store summary data
plot_df = data.frame(z = unique(stat_df$gde), pa_high = rep(NA), pa_low = rep(NA), pa_none = rep(NA))
plot_df = plot_df |> filter(z != 0)

for (i in 1:nrow(plot_df)) {
  # i = 1
  plot_df$pa_none[i] = stat_df |> filter(gde == plot_df$z[i] & pa == 0) |> pull(area) |> sum(na.rm = T)
  plot_df$pa_low[i]  = stat_df |> filter(gde == plot_df$z[i] & pa == 1) |> pull(area) |> sum(na.rm = T)
  plot_df$pa_high[i] = stat_df |> filter(gde == plot_df$z[i] & pa == 2) |> pull(area) |> sum(na.rm = T)
}

# sort by total area again
plot_df$pa_all = plot_df$pa_high + plot_df$pa_low + plot_df$pa_none
plot_df$rank = rank(-plot_df$pa_all)
plot_df = plot_df[order(plot_df$rank),] 

plot_df_m = plot_df |> 
  dplyr::select(!pa_all) |>
  melt(id.vars = c('z', 'rank'))
plot_df_m = plot_df_m |> filter(variable != "pa_none")

ggplot(data = plot_df_m, aes(x = as.factor(rank), y = value/denom, 
                             fill = forcats::fct_rev(as.factor(variable)))) +
  geom_bar(position = 'stack', stat = 'identity', color = 'black', linewidth = 3, width = 1) +
  scale_fill_manual(values = c('#FFB000','#008F26')) +
  coord_cartesian(expand = 0, ylim = c(0, 0.1), clip = "off") +
  cus_theme + theme(axis.ticks.x = element_line(size = 1), axis.line = element_blank()) 

ggsave(plot = last_plot(), 
       file.path(plot_sv, "gde_class_protected_area.pdf"), 
       dpi = 500, width = 6, height = 4, units = "in")


# radial plot of percent protected
plot_df$frac = ((plot_df$pa_all - plot_df$pa_none) / plot_df$pa_all )|> round(2)

radial_df = data.frame(id = c('high', 'low', 'none'),
                       values = c(sum(plot_df$pa_high), sum(plot_df$pa_low), sum(plot_df$pa_none)))
radial_df$frac = radial_df$values / sum(radial_df$values)
radial_df$frac_cumsum = cumsum(radial_df$frac)
radial_df$frac_min = c(0, head(radial_df$frac_cumsum, n=-1))

ggplot(radial_df, aes(ymax=frac_cumsum, ymin=frac_min, xmax=4, xmin=3, fill=id)) +
  geom_rect() +
  scale_fill_manual(values = c('#008F26', '#FFB000', '#BEBEBE')) +
  coord_polar(theta="y") + # Try to remove that to understand how the chart is built initially
  xlim(c(2, 4)) + theme_void() + theme(legend.position = "none")

ggsave(plot = last_plot(), 
       file.path(plot_sv, "gde_protected_percentage.pdf"), 
       dpi = 500, width = 6, height = 6, units = "in")


# z        lyr.1 plot_col rank         pct
# 2  10 4.629814e+13  #3153A4    1 0.598859417
# 6 110 1.261650e+13  #137A8D    2 0.163192546
# 7 111 7.814046e+12  #00E6FF    3 0.101073510
# 3  11 7.032300e+12  #7E287F    4 0.090961741
# 4 100 3.099186e+12  #5CB953    5 0.040087500
# 1   1 2.927401e+11  #EC2B31    6 0.003786549
# 5 101 1.576159e+11  #FFE520    7 0.002038738