# Name: f3-si-aichi-targets.R
# Description: Plot potential for groundwatersheds to support reaching protection targets

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import main data sheet
s_df <- readr::read_csv(file.path(wd, paste0("data/STATS.csv")))

# merge with shapefile, calculate centroids
protarea <- terra::vect(file.path(wdpa_wd, "contiguous_protected_areas.shp"))
protarea <- merge(protarea, s_df, by.x='FID', by.y='CPA_ID')
protarea_v <- terra::centroids(protarea)
prot_pts <- st_as_sf(protarea_v)

# extract the nation ID for each protected point centroid
nat_ID <- raster("D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_merge.tif")
prot_pts$nat_ID <- rep(NA)
prot_pts$nat_ID <- raster::extract(x = nat_ID, y = prot_pts)

# summarize unprotected groundwatershed area by national ID 
prot_summary <- prot_pts |> 
  as.data.frame() |> 
  group_by(nat_ID) |> 
  summarize(
    unprot_GWS = sum(unprot_gwshed_area, na.rm = T),
    unprot_GWS_c16 = sum(unprot_gwshed_area_c1to6, na.rm = T)
  )

# import Aichi target tracking data from Protected Planet csv
Aichi_sf <- sf::read_sf("D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_merge.shp")
Aichi_sf <- merge(x = Aichi_sf, y = prot_summary, by.x = "ID", by.y = "nat_ID", all.x = T)
Aichi_sf$unprot_GWS <- Aichi_sf$unprot_GWS/1e6 # convert from m2 to km2
Aichi_sf$unprot_GWS[is.na(Aichi_sf$unprot_GWS)] <- 0
Aichi_sf <- Aichi_sf[complete.cases(Aichi_sf$l_area),]
Aichi_sf <- Aichi_sf |> dplyr::filter(l_area > 0)

# calculate national protected coverage if all unprotected groundwatersheds became protected
Aichi_sf$GWS_add_prot_percent <- 100*(Aichi_sf$prot_area + Aichi_sf$unprot_GWS)/Aichi_sf$l_area


# separate into 3 classes (and separate objects) for plotting

Under17 <- Aichi_sf |> dplyr::filter(GWS_add_prot_percent < 17)
MiddleGround <- Aichi_sf |> dplyr::filter(GWS_add_prot_percent >= 17)
SeriouslyProtected <- Aichi_sf |> dplyr::filter(GWS_add_prot_percent >= 30)

under17pal <- rev(met.brewer(name = "Tam", type = "continuous", n = 20)[1:8])

# plot
aichi_fulfill <- tm_shape(rnaturalearth::ne_countries(), projection = "+proj=robin") +
  tm_polygons(border.col = "grey", col = "grey") +
  
  tm_shape(st_as_sf(Under17)) + 
  tm_polygons(col = "GWS_add_prot_percent",
              border.alpha = 0,
              palette = under17pal,
              breaks = c(0, 17),
              style = "cont",
              colorNA = NULL) +
  
  tm_shape(st_as_sf(MiddleGround)) + 
  tm_polygons(col = "GWS_add_prot_percent",
              border.alpha = 0,
              palette = met.brewer(name = "VanGogh3", type = "continuous", n = 24)[4:20],
              breaks = c(17, 30),
              style = "cont",
              colorNA = NULL) +
  
  tm_shape(st_as_sf(SeriouslyProtected)) +
  tm_polygons(col = "#192813", border.alpha = 0, colorNA = NULL) +
  
  
  tm_shape(rnaturalearth::ne_countries()) +
  tm_borders(col = "black") +
  
  tm_layout(legend.show = T, 
            earth.boundary = c(-179, -60, 179, 88),
            earth.boundary.color = "white", space.color = "white",
            legend.frame = F, frame = F)
aichi_fulfill

tmap_save(aichi_fulfill, file.path(plot_sv, "aichi-fulfill-potential.png"), dpi = 400, units = "in")


# histogram shift if unprotected groundwatersheds were to become protected
hist_df <- data.frame(
  ID = c(Aichi_sf$ID, Aichi_sf$ID),
  Prot_pct = c(Aichi_sf$p_pcnt, Aichi_sf$GWS_add_prot_percent),
  State = c(rep(1, nrow(Aichi_sf)), rep(2, nrow(Aichi_sf)))
)

hist_df$Prot_pct[hist_df$Prot_pct > 50] <- 50
hist_df$State <- as.factor(hist_df$State)

ggplot(data = hist_df, aes(x=Prot_pct, fill= factor(State, levels = c("2","1")))) +
  geom_density(adjust=1.5, alpha = 0.5, lwd = 1, bw = 2.5) +
  geom_vline(xintercept = median(hist_df$Prot_pct[hist_df$State == 2], na.rm = T), 
             col = 'green4', lwd = 1, lty = "dashed") +
  geom_vline(xintercept = median(hist_df$Prot_pct[hist_df$State == 1], na.rm = T), 
             col = '#0E3F62', lwd = 1, lty = "dashed") +
  # geom_histogram(binwidth = 5, alpha=0.4, position = 'identity') +
  geom_vline(xintercept = 17, col = 'grey10', lwd = 1) +
  geom_vline(xintercept = 30, col = 'grey10', lwd = 1) +
  scale_fill_manual(values=c("green4", "#0E3F62")) +
  my_theme + theme(axis.text=element_text(colour="black"),
                   plot.margin = unit(c(2,5,2,2), "mm")) +
  ylab('') + xlab('')+
  coord_cartesian(xlim = c(0, 50), ylim = c(0, 0.04), expand = c(0,0), clip = 'off') +
  labs(fill="")

ggsave(file = file.path(plot_sv, "aichi-fulfillment-potential.png"), 
       plot = last_plot(), device = "png",
       width = 500/4, height = 250/4, units = "mm", dpi = 400) #saves g