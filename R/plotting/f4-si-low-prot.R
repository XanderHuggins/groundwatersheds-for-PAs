# Name: f3-si-low-prot.R
# Description: Determine degree that 'unprotected' groundwatersheds are in fact protected by lower classes of protected areas.

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import main data sheet
s_df = readr::read_csv(file.path(dat_loc, "STATS.csv"))

# merge with shapefile, calculate centroids
protarea = terra::vect(file.path(wdpa_wd, "contiguous_protected_areas.shp"))
protarea = merge(protarea, s_df, by.x='FID', by.y='CPA_ID')
protarea_v = terra::centroids(protarea)
prot_pts = st_as_sf(protarea_v)

# extract the nation ID for each protected point centroid
nat_ID = raster("D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_merge.tif")
prot_pts$nat_ID = rep(NA)
prot_pts$nat_ID = raster::extract(x = nat_ID, y = prot_pts)

# summarize unprotected groundwatershed area by national ID 
prot_summary = prot_pts |> 
  as.data.frame() |> 
  group_by(nat_ID) |> 
  summarize(
    unprot_GWS = sum(unprot_gwshed_area, na.rm = T),
    unprot_GWS_c16 = sum(unprot_gwshed_area_c1to6, na.rm = T),
    GWS_area = sum(gwshed_area, na.rm = T)
  )

# calculate proportion of unprotected groundwatershed area that is under lower levels of protection
prot_summary$lowlevelprot  = prot_summary$unprot_GWS - prot_summary$unprot_GWS_c16
prot_summary$lowlevelprotPct = prot_summary$lowlevelprot / prot_summary$unprot_GWS
summary(prot_summary$lowlevelprotPct)

# import Aichi target tracking data from Protected Planet csv
nat_temp = sf::read_sf("D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_merge.shp")
nat_temp = merge(x = nat_temp, y = prot_summary, by.x = "ID", by.y = "nat_ID", all.x = T)

nat_temp |> dplyr::filter(lowlevelprotPct > 0.5 & unprot_GWS > 0) 
nat_temp$unprot_GWS[nat_temp$unprot_GWS == 0] = NA

nat_temp$lowlevelprotclass = rep(NA)
nat_temp$lowlevelprotclass[nat_temp$lowlevelprotPct < 0.05] = 1
nat_temp$lowlevelprotclass[nat_temp$lowlevelprotPct >= 0.05] = 2
nat_temp$lowlevelprotclass[nat_temp$lowlevelprotPct >= 0.10] = 3
nat_temp$lowlevelprotclass[nat_temp$lowlevelprotPct >= 0.15] = 4
nat_temp$lowlevelprotclass[nat_temp$lowlevelprotPct >= 0.30] = 5

stat_df = nat_temp |> dplyr::filter(unprot_GWS > 0 & prot_area > 0)
summary(stat_df$lowlevelprotPct)
stat_df |> dplyr::filter(lowlevelprotPct > 0.3) |> pull(ISO_A3)

#  plot
lowprot <- tm_shape(rnaturalearth::ne_countries(), projection = "+proj=robin") +
  tm_polygons(border.col = "grey", col = "grey") +
  tm_shape(st_as_sf(nat_temp)) + 
  tm_polygons(col = "lowlevelprotclass",
              border.alpha = 0,
              palette = rev(met.brewer(name = "Hokusai1", type = "continuous", n = 5, direction = -1)),
              breaks = c(0, 0.15),
              style = "cat",
              colorNA = NULL) +
  tm_shape(rnaturalearth::ne_countries()) +
  tm_borders(col = "black") +
  tm_layout(legend.show = T, 
            earth.boundary = c(-179, -60, 179, 88),
            earth.boundary.color = "white", space.color = "white",
            legend.frame = F, frame = F)
lowprot

tmap_save(lowprot, file.path(plot_sv, "lowprot_gwshed.png"), dpi = 400, units = "in")
