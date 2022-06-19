# Name: p1-land-borders-rast.R
# Description: Generate a binary raster indicating all cells that touch an international land border. 

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

ne_10m = sf::read_sf("D:/Geodatabase/Admin-ocean-boundaries/boundaries/ne_10m_admin_0_boundary_lines_land.shp")
ne_10m_line_r = terra::rasterize(x = terra::vect(ne_10m), 
                                  y = terra::rast(file.path(wd, "data/World/input/wgs-area-ras-30-arcsec.tif")),
                                  field = 1,
                                  touches = TRUE)
writeRaster(ne_10m_line_r, "D:/Geodatabase/Admin-ocean-boundaries/ne_10m_admin_0_countries_borders.tif", overwrite = T)