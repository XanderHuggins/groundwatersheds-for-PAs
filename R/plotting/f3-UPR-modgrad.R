# Name: f3-UPR-modgrad.R
# Description: Plot UPR against human modification gradient at the scale of terrestrial ecoregions.

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import data sheet
s_df = readr::read_csv(file.path(dat_loc, "STATS.csv"))

# merge with shapefile, calculate centroids
protarea = terra::vect(file.path(wdpa_wd, "contiguous_protected_areas.shp"))
protarea = merge(protarea, s_df, by.x='FID', by.y='CPA_ID')
protarea_v = terra::centroids(protarea)
prot_pts = st_as_sf(protarea_v)

# extract the terrestrial ecoregion ID for each protected point centroid
teow = terra::rast("D:/Geodatabase/Ecological/Ecoregions/Terrestrial/teow_1km.tif")
prot_pts$teow = rep(NA)
prot_pts$teow = raster::extract(x = raster(teow), y = prot_pts)

# keep only protected areas with identified FEOW + unprotected groundwatershed areas
prot_pts = prot_pts |> as.data.frame() |> 
  filter(unprot_gwshed_area > 0 & !is.na(teow))
prot_pts$feow = prot_pts$feow |> round(0) 

# now calculate area-weighted modgrad + sum other areas
stat_df = prot_pts |> 
  group_by(teow) |> 
  summarize(
    modgrad_mean = weighted.mean(x = modgrad, w = unprot_gwshed_area, na.rm = T),
    gwshed_area = sum(gwshed_area, na.rm = T),
    unprot_gwshed_area = sum(unprot_gwshed_area, na.rm = T),
    aridity = weighted.mean(x = aridity, y = area, na.rm = T)
  )

# calculate UPR for ecoregions
stat_df$UPR = stat_df$unprot_gwshed_area / stat_df$gwshed_area

# develop color plot ID for quadrants
stat_df$colorId <- rep(NA) 
x_dif = median(stat_df$UPR, na.rm = T)
y_dif = median(stat_df$modgrad_mean, na.rm = T)

stat_df$colorId[stat_df$UPR <= x_dif & stat_df$modgrad_mean >= y_dif] <- 1 # purple or 9771B4
stat_df$colorId[stat_df$UPR <= x_dif & stat_df$modgrad_mean <  y_dif] <- 2 # grey or E8E8E8
stat_df$colorId[stat_df$UPR > x_dif  & stat_df$modgrad_mean >= y_dif] <- 3 # red or 804D36
stat_df$colorId[stat_df$UPR > x_dif  & stat_df$modgrad_mean <  y_dif] <- 4 # yellow or C7B448
stat_df$colorId = as.factor(stat_df$colorId)

# background annotation transparency 
aa = 0.5 

ggplot(data = as.data.frame(stat_df), aes(x = UPR, y = modgrad_mean, fill = colorId)) +
  
  annotate("rect", xmin=-Inf,  xmax=x_dif,  ymin=0,     ymax=y_dif, fill="#E8E8E8", alpha=aa) +
  annotate("rect", xmin=-Inf,  xmax=x_dif,  ymin=y_dif, ymax=Inf,   fill="#9771B4", alpha=aa) +
  annotate("rect", xmin=x_dif,   xmax=Inf,  ymin=0,     ymax=y_dif, fill="#C7B448", alpha=aa) +
  annotate("rect", xmin=x_dif,   xmax=Inf,  ymin=y_dif, ymax=Inf,   fill="#804D36", alpha=aa) +
  geom_point(shape = 21, size = 3, alpha = 0.9) +
  scale_fill_manual(values = c('#9771B4', '#E8E8E8', "#804D36", '#C7B448')) +
  cus_theme + theme(axis.text=element_text(colour="black"),
                    plot.margin = unit(c(2,5,2,2), "mm")) +
  ylab('') + xlab('')+ 
  coord_cartesian(xlim = c(0, 1.0), ylim = c(0,0.75), clip = "off", 
                  expand=c(0))

ggsave(file = file.path(plot_sv, "UPR-modgrad-scatter.png"), 
       plot = last_plot(), device = "png",
       width = 500/(5*0.75), height = 250/(4*0.75), units = "mm", dpi = 400) #saves g

# global map
teow_sf = sf::read_sf("D:/Geodatabase/Ecological/Ecoregions/Terrestrial/wwf_terr_ecos.shp")
teow_sf = merge(x = teow_sf, y = stat_df, by.x = "ECO_ID", by.y = "teow")
teow_sf = teow_sf %>% filter(!st_is_empty(.))

teow_tmap <- tm_shape(rnaturalearth::ne_countries(), projection = "+proj=robin") +
  tm_polygons(border.col = "grey", col = "grey") +
  tm_shape(teow_sf) + 
  tm_polygons(col = "colorId",
             # shape = 21,
             # size = 0.05,
             border.alpha = 0,
             alpha = 1, 
             palette = c('#9771B4', '#E8E8E8', "#804D36", '#C7B448'),
             # breaks = c(0, 2),
             style = "cat",
             colorNA = NULL) +
  tm_layout(legend.show = T, 
            earth.boundary = c(-179, -60, 179, 88),
            earth.boundary.color = "white", space.color = "white",
            legend.frame = F, frame = F)
teow_tmap

tmap_save(teow_tmap, file.path(plot_sv, "teow_upr-modgrad.png"), dpi = 400, units = "in")
