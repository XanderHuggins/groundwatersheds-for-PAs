# Name: f1-world-plotting.R
# Description: Generate world maps with data represented by points at protected area centroids

# Set working directory and load necessary libraries
library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import data sheet and protected area shapefile, and merge
s_df <- readr::read_csv(file.path(wd, paste0("data/STATS.csv")))
protarea <- terra::vect(file.path(wdpa_wd, "contiguous_protected_areas.shp"))
protarea <- merge(protarea, s_df, by.x='FID', by.y='CPA_ID')

# get centroid for plotting 
protarea_v <- terra::centroids(protarea)


library(rnaturalearth)
rnaturalearth::ne_countries()

# plot log RGS
protarea_v$logRGS <- log10(protarea_v$RGS)
logRGS <- tm_shape(rnaturalearth::ne_countries(), projection = "+proj=robin") +
  tm_polygons(border.col = "grey", col = "grey") +
  tm_shape(st_as_sf(protarea_v)) + 
  tm_symbols(col = "logRGS",
             shape = 21,
             size = 0.05,
             border.alpha = 0,
             alpha = 1, 
             palette = scico(n = 100, palette = "batlow"),
             breaks = c(0, 2),
             style = "cont",
             colorNA = NULL) +
  tm_layout(legend.show = T, 
            earth.boundary = c(-179, -60, 179, 88),
            earth.boundary.color = "white", space.color = "white",
            legend.frame = F, frame = F)
logRGS
tmap_save(logRGS, file.path(plot_sv, "log10-RGS-map.png"), dpi = 400, units = "in")

# plot UPR
UPR <- tm_shape(rnaturalearth::ne_countries(), projection = "+proj=robin") +
  tm_polygons(border.col = "grey", col = "grey") +
  tm_shape(st_as_sf(protarea_v)) + 
  tm_symbols(col = "UPR",
             shape = 21,
             size = 0.05,
             border.alpha = 0,
             alpha = 1,
             palette = met.brewer(name = "Hokusai1", type = "continuous", n = 20, direction=-1), 
             breaks = c(0.1, 0.9),
             style = "cont",
             colorNA = NULL) +
  tm_layout(legend.show = T, 
            earth.boundary = c(-179, -60, 179, 88),
            earth.boundary.color = "white", space.color = "white",
            legend.frame = F, frame = F)
UPR
tmap_save(UPR, file.path(plot_sv, "log10-UPR-map.png"), dpi = 400, units = "in")

# human modification gradient
MODGRAD <- tm_shape(rnaturalearth::ne_countries(), projection = "+proj=robin") +
  tm_polygons(border.col = "grey", col = "grey") +
  tm_shape(st_as_sf(protarea_v)) + 
  tm_symbols(col = "modgrad",
             shape = 21,
             size = 0.05,
             border.alpha = 0,
             palette = met.brewer(name = "Tam"),
             breaks = c(0, 1),
             style = "cont") +
  tm_layout(legend.show = T, 
            earth.boundary = c(-179, -60, 179, 88),
            earth.boundary.color = "white", space.color = "white",
            legend.frame = F, frame = F)
MODGRAD
tmap_save(MODGRAD, file.path(plot_sv, "modgrad.png"), dpi = 400, units = "in")