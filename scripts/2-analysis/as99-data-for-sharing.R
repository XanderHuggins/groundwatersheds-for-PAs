
library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 


# import the final data csv
s_df = readr::read_csv(file.path(dat_loc, "report_STATS.csv"))

# import the protected areas vector file
contig_pa = terra::vect(file.path(wdpa_wd, "contiguous_protected_areas_FID.sqlite"))

# select only the attributes to share and then merge with vector file 
s_df = s_df |> dplyr::select(CPA_ID, RGS, UGR, modgrad)
contig_pa = merge(x = contig_pa, y = s_df, by.x = 'fid', by.y = 'CPA_ID')
contig_pa$fid = seq(1:nrow(contig_pa))

# simplify output to 3 decimal places
contig_pa$RGS = contig_pa$RGS |> round(3)
contig_pa$UGR = contig_pa$UGR |> round(3)
contig_pa$modgrad = contig_pa$modgrad |> round(3)

# write to geopackage file for sharing
terra::writeVector(x = contig_pa, 
                   filename = file.path(dat_loc,  "share/pa_groundwatershed_summary.gpkg"),
                   filetype = "GPKG",
                   overwrite = T)


# Import GDE raster, set all non-GDEs to NA, and write to GeoTIFF
gde_r = terra::rast(file.path(dat_loc, "World/GDE_classification_composite.tif"))
gde_r[gde_r == 0] = NA
names(gde_r) = "GDE_type"

terra::writeRaster(x = gde_r, 
                   filename = file.path(dat_loc,  "share/gde-map.tif"),
                   filetype = "GTiff",
                   overwrite = T)

# Import groundwatershed raster, convert to binary, and export
gwshed_1 = terra::rast(file.path(dat_loc, world_regions[1], "gwsheds_individual.tif"))
gwshed_2 = terra::rast(file.path(dat_loc, world_regions[2], "gwsheds_individual.tif"))
gwshed_3 = terra::rast(file.path(dat_loc, world_regions[3], "gwsheds_individual.tif"))
gwshed_4 = terra::rast(file.path(dat_loc, world_regions[4], "gwsheds_individual.tif"))
gwshed_5 = terra::rast(file.path(dat_loc, world_regions[5], "gwsheds_individual.tif"))
area_ras = terra::rast(file.path(dat_loc, "World/input/wgs-area-ras-30-arcsec.tif"))

gwshed_1 = terra::resample(x = gwshed_1, y = area_ras, method = "near", threads = TRUE)
gwshed_2 = terra::resample(x = gwshed_2, y = area_ras, method = "near", threads = TRUE)
gwshed_3 = terra::resample(x = gwshed_3, y = area_ras, method = "near", threads = TRUE)
gwshed_4 = terra::resample(x = gwshed_4, y = area_ras, method = "near", threads = TRUE)
gwshed_5 = terra::resample(x = gwshed_5, y = area_ras, method = "near", threads = TRUE)

gwshed_c = c(gwshed_1, gwshed_2, gwshed_3, gwshed_4, gwshed_5)
gwshed_c = max(gwshed_c, na.rm = T)
gwshed_c[gwshed_c >= 1] = 1
names(gwshed_c) = "GWSHED"

terra::writeRaster(x = gwshed_c, 
                   filename = file.path(dat_loc,  "share/groundwatersheds.tif"),
                   filetype = "GTiff",
                   overwrite = T)


# check that geopackage produces same results
s_df = terra::vect(file.path(dat_loc,  "share/pa_groundwatershed_summary.gpkg"))

s_df$RGS |> median()
s_df$UGR |> median()
s_df$modgrad |> median(na.rm = T)
