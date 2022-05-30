# Name: f2-UPR-nat-protected-coverage.R
# Description: Plot relationship between national level protected area coverage and groundwatershed UPR

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import data sheet and merge with shapefile
s_df <- readr::read_csv(file.path(wd, paste0("data/STATS.csv")))
protarea <- terra::vect(file.path(wdpa_wd, "contiguous_protected_areas.shp"))
protarea <- merge(protarea, s_df, by.x='FID', by.y='CPA_ID')

# calculate centroids, which are used to pull national protected coverage datea
protarea_v <- terra::centroids(protarea)
prot_pts <- st_as_sf(protarea_v)

# import national protection coverage data, and extract to protected area
aichi <- raster("D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_percent.tif")
prot_pts$Aichi11 <- rep(NA)
prot_pts$Aichi11 <- raster::extract(x = aichi, y = prot_pts)

# import country ID, and extract to protected area
nat_ID <- raster("D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_merge.tif")
prot_pts$nat_ID <- rep(NA)
prot_pts$nat_ID <- raster::extract(x = nat_ID, y = prot_pts)

# group by country 
s_df <- prot_pts |>
  as.data.frame() |>
  group_by(nat_ID) |>
  summarize(
    UnprotGWS = sum(unprot_gwshed_area, na.rm = T),
    AllGWS = sum(gwshed_area, na.rm = T),
    Aichi11 = max(Aichi11, na.rm = T)
  )

# calculate UPR per country 
s_df$UPR <- s_df$UnprotGWS / s_df$AllGWS

# set protected coverage classes
s_df$AichiClass <- rep(NA)
s_df$AichiClass[s_df$Aichi11 <= 1] <- 1 
s_df$AichiClass[s_df$Aichi11 > 1] <- 2 
s_df$AichiClass[s_df$Aichi11 > 5] <- 3 
s_df$AichiClass[s_df$Aichi11 > 10] <- 4 
s_df$AichiClass[s_df$Aichi11 > 17] <- 5 # Aichi biodiversity target 11 
s_df$AichiClass[s_df$Aichi11 > 30] <- 6 # 30x30 initiative
s_df$AichiClass <- as.numeric(s_df$AichiClass)

p_df <- s_df |> dplyr::filter(AichiClass >= 1 & Aichi11 > 0) # only points with Aichi data...
p_df$AichiClass <- as.factor(p_df$AichiClass)

# plot
p_a11 <- ggplot(p_df, aes(x = UPR, y = AichiClass)) +
  geom_boxplot(data = p_df, aes(x = UPR, y = AichiClass), width = 0.35, fill = 'grey',
               outlier.alpha = 0, position= position_nudge(y=0)) +
  scale_y_discrete(labels = c('<1%', '1%-5%', '5%-10%', '10%-17%', '17-30%', '>30%')) +
  my_theme + theme(axis.text=element_text(colour="black"),
                   plot.margin = unit(c(2,5,2,2), "mm")) +
  ylab('') + xlab('')+
  coord_cartesian(xlim = c(0, 1), expand = c(0,0), clip = 'on')
p_a11

ggsave(file = file.path(plot_sv,"boxplot-UPR-aichi11.png"), 
       plot = p_a11, device = "png",
       width = 500/4, height = 250/4, units = "mm", dpi = 400) #saves g