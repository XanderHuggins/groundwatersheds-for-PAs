# Name: p1-iso3-protected-pct-rast.R
# Description: Generate raster that represents nation-based levels of terrestrial protection.

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import protected area statistics from world database on protected areas
pa_stat = readr::read_csv(file.path(dat_loc, "World/input/", "chapter3_national_pa_statistics.csv"))
pa_stat = pa_stat |> dplyr::select(ISO3, pa_land_area, percentage_pa_land_cover, land_area)
pa_stat$ID = seq(1, nrow(pa_stat))

# import country shapefile
ne_10m = sf::read_sf("D:/Geodatabase/Admin-ocean-boundaries/ne_10m_admin_0_countries.shp")
ne_10m$ISO_A3[ne_10m$SOVEREIGNT == "France"] = "FRA" # Corrected as needed to reconcile datasets
ne_10m$ISO_A3[ne_10m$SOVEREIGNT == "Norway"] = "NOR" # Corrected as needed to reconcile datasets
ne_10m = ne_10m |> dplyr::select(ISO_A3, geometry)

# merge country shapefile with protected area statistics
ne_10m = merge(x = ne_10m, y = pa_stat, by.x = "ISO_A3", by.y = "ISO3")
names(ne_10m) = c('ISO_A3', 'prot_area', 'p_pcnt', 'l_area', 'ID', 'geometry')

# write sf
sf::write_sf(obj=ne_10m,
             dsn = "D:/Geodatabase/Admin-ocean-boundaries",
             layer = "ne10m_prot_area_merge.shp",
             driver = "ESRI Shapefile")

# rasterize using country ID
gdalUtils::gdal_rasterize(src_datasource = "D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_merge.shp",
                          dst_filename = "D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_merge.tif",
                          at = T,
                          a = "ID",
                          tr = c((1/120), (1/120)),
                          verbose = T)

# rasterize current national level of protection
gdalUtils::gdal_rasterize(src_datasource = "D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_merge.shp",
                          dst_filename = "D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_percent.tif",
                          at = T,
                          a = "p_pcnt",
                          tr = c((1/120), (1/120)),
                          verbose = T)

# ensure exported national ID dataset is snapped to grid correctly and overwrite
nat_ID = terra::rast("D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_merge.tif")
nat_ID = terra::extend(x = nat_ID, y = terra::rast(WGS84_areaRaster(1)))  
nat_ID[is.na(nat_ID)] = 0
ext(nat_ID) = round(ext(nat_ID), 2)

terra::writeRaster(x = nat_ID, 
                   filename = "D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_merge_extend.tif",
                   filetype = "GTiff", overwrite = T)