# Name: ps1-iso3-protected-pct-rast.R
# Description: Generate raster that represents nation-based levels of terrestrial protection.

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# import protected area statistics from world database on protected areas
pa_stat = readr::read_csv("D:/Geodatabase/Ecological/protected_area_percentages_world_bank.csv")
names(pa_stat) = pa_stat[4,] |> as.character()
pa_stat = pa_stat[5:nrow(pa_stat),]

pa_stat = pa_stat |> dplyr::select(`Country Code`, Latest)
pa_stat$ID = seq(1, nrow(pa_stat))

# import country shapefile
ne_10m = sf::read_sf("D:/Geodatabase/Admin-ocean-boundaries/ne_10m_admin_0_countries.shp")
ne_10m$ISO_A3[ne_10m$SOVEREIGNT == "France"] = "FRA" # Corrected as needed to reconcile datasets
ne_10m$ISO_A3[ne_10m$SOVEREIGNT == "Norway"] = "NOR" # Corrected as needed to reconcile datasets
ne_10m = ne_10m |> dplyr::select(ISO_A3, geometry)

# merge country shapefile with protected area statistics
ne_10m = merge(x = ne_10m, y = pa_stat, by.x = "ISO_A3", by.y = "Country Code")

# import file with country land area size
land_stat = readr::read_csv(file.path(dat_loc, "World/input/", "chapter3_national_pa_statistics.csv"))
land_stat = land_stat |> dplyr::select(ISO3, land_area)

ne_10m = merge(x = ne_10m, y = land_stat, by.x = "ISO_A3", by.y = "ISO3")
names(ne_10m) = c('ISO_A3', 'prot_pct', 'ID','land_area', 'geometry')

# write sf
sf::write_sf(obj=ne_10m,
             dsn = "D:/Geodatabase/Admin-ocean-boundaries",
             layer = "ne10m_prot_area_merge.shp",
             driver = "ESRI Shapefile")

# rasterize using country ID
gdalUtilities::gdal_rasterize(src_datasource = "D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_merge.shp",
                              dst_filename = "D:/Geodatabase/Admin-ocean-boundaries/ne10m_ID.tif",
                              at = T,
                              a = "ID",
                              tr = c((1/120), (1/120)))

# rasterize current national level of protection
gdalUtilities::gdal_rasterize(src_datasource = "D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_area_merge.shp",
                              dst_filename = "D:/Geodatabase/Admin-ocean-boundaries/ne10m_prot_percent.tif",
                              at = T,
                              a = "prot_pct",
                              tr = c((1/120), (1/120)))

# ensure exported national ID dataset is snapped to grid correctly and overwrite
nat_ID = terra::rast("D:/Geodatabase/Admin-ocean-boundaries/ne10m_ID.tif")
nat_ID = terra::extend(x = nat_ID, y = terra::rast(WGS84_areaRaster(1)))  
nat_ID[is.na(nat_ID)] = 0
ext(nat_ID) = round(ext(nat_ID), 2)

terra::writeRaster(x = nat_ID, 
                   filename = "D:/Geodatabase/Admin-ocean-boundaries/ne10m_ID_extend.tif",
                   filetype = "GTiff", overwrite = T)
