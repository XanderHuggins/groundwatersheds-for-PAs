# Name: f4-si-misc-plotting.R
# Description: Plot GDP per capita against UPR.

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import main data sheet
s_df = readr::read_csv(file.path(dat_loc, "STATS.csv"))

# merge with shapefile, calcaulate centroids
protarea = terra::vect(file.path(wdpa_wd, "contiguous_protected_areas.shp"))
protarea = merge(protarea, s_df, by.x='FID', by.y='CPA_ID')
protarea_v = terra::centroids(protarea)
prot_pts = st_as_sf(protarea_v)

# extract the nation ID for each protected point centroid
gdp = terra::rast("D:/Geodatabase/GDP/Kummu/GDP_per_capita_PPP_1990_2015_v2.nc")
gdp = gdp[[26]] # extract data for year 2015
prot_pts$gdppercap = rep(NA)
prot_pts$gdppercap = raster::extract(x = raster(gdp), y = prot_pts)

prot_pts = prot_pts |> as.data.frame()

# generate GDP per capita classes
prot_pts$GDPclass <- rep(NA)
prot_pts$GDPclass[prot_pts$gdppercap <= 1000] <- 1 # 
prot_pts$GDPclass[prot_pts$gdppercap > 1000] <- 2 # 
prot_pts$GDPclass[prot_pts$gdppercap > 2500] <- 3 # 
prot_pts$GDPclass[prot_pts$gdppercap > 10000] <- 4 # 
prot_pts$GDPclass[prot_pts$gdppercap > 25000] <- 5 # 
prot_pts$GDPclass <- as.numeric(prot_pts$GDPclass)

p_df <- prot_pts |> dplyr::filter(GDPclass >= 1)
p_df$GDPclass <- as.factor(p_df$GDPclass)

# plot
p_a11 <- ggplot(p_df, aes(x = GDPclass, y = UPR)) +
  geom_boxplot(data = p_df, aes(x = GDPclass, y = UPR), width = 0.35, fill = 'grey',
               outlier.alpha = 0, position= position_nudge(y=0)) +
  scale_x_discrete(labels = c('<$1,000', '$1,000-\n$2,500', 
                              '$2500-\n$10,000', '$10,000-\n$25,000', '>$25,000')) +
  my_theme + theme(axis.text=element_text(colour="black")) +
  theme(axis.text=element_text(colour="black"),
        plot.margin = unit(c(2,5,2,2), "mm")) +
  ylab('') + xlab('')
p_a11

ggsave(file = file.path(plot_sv,"GDPpercap-vs-UPR.png"), 
       plot = p_a11, device = "png",
       width = 500/4, height = 250/4, units = "mm", dpi = 400) 
