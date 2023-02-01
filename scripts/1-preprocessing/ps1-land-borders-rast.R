# Name: ps1-land-borders-rast.R
# Description: Generate a binary raster indicating all cells that touch an international land border. 

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# data from Natural Earth Data (https://www.naturalearthdata.com/downloads/10m-cultural-vectors/10m-admin-0-boundary-lines/)
ne_10m = sf::read_sf("D:/Geodatabase/Admin-ocean-boundaries/boundaries/ne_10m_admin_0_boundary_lines_land.shp")
ne_10m_line_r = terra::rasterize(x = terra::vect(ne_10m), 
                                  y = terra::rast(file.path(wd, "data/World/input/wgs-area-ras-30-arcsec.tif")),
                                  field = 1,
                                  touches = TRUE)
writeRaster(ne_10m_line_r, "D:/Geodatabase/Admin-ocean-boundaries/ne_10m_admin_0_countries_borders.tif", overwrite = T)