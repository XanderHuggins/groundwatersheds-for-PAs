# Name: ps1-hydrobasins.R
# Description: Generates raster of HydroBASINS level 10

library(here)
invisible(sapply(paste0(here("scripts/setup"), "/", list.files(here("scripts/setup"))), source))

# step 1: rasterize all hydrobasins at level 10, using pfaf_id as burn value

# list regional hydrobasin level 10 files
hybas_files = list.files("D:/Geodatabase/Basins/HydroBASINS/", recursive = T, pattern = "*.shp", full.names = T) |> 
  as.character() |>
  as.data.frame() |> 
  set_colnames(c("name")) |> 
  dplyr::filter(grepl("*lev10_v1c*", name)) |> dplyr::filter(!grepl(".xml*", name))
hybas_files$name = gsub("//", "/", hybas_files$name, fixed = TRUE)
hybas_files = hybas_files$name |> as.vector()


# for each file, rasterize at 30 arc-second
for (i in 1:length(hybas_files)) {
  terraOptions(datatype="FLT8S") # need this option set to preserve precision to 10 digits
  vect_in = sf::st_read(hybas_files[i]) |> terra::vect()

  temp_ras = terra::rast(crs = terra::crs(vect_in), extent = terra::ext(vect_in), resolution = 1/120)
  hybas_r = terra::rasterize(x = vect_in, 
                             y = temp_ras,
                             field = "PFAF_ID",
                             touches = TRUE,
                             wopt=list(datatype="FLT8S"))
  hybas_r = as.int(hybas_r)
  
  terra::writeRaster(hybas_r, 
                     paste0("D:/projects/global-groundwatersheds/data/preparation/hybas/", 
                            substr(hybas_files[i], 44,51), ".tif"), 
                     overwrite = T,
                     wopt=list(datatype="FLT8S"))
  
  message(paste(i, "is done"))
  
}

# step 2: merge all hydrobasin regions into a global raster
hybas_r_list = list.files("D:/projects/global-groundwatersheds/data/preparation/hybas/", 
                          pattern = ".tif", full.names = T)

# need a reference raster at the desired global resolution & extent (so use our pre-derived area raster)
area_r = terra::rast("D:/projects/global-groundwatersheds/data/World/input/wgs-area-ras-30-arcsec.tif")

# initiate mosiaced raster with first region from list
mosaic_r = terra::rast(hybas_r_list[1])

# ensure raster is 'snapped' to global grid
mosaic_r = terra::resample(x = mosaic_r, y = area_r, method = 'near')

# loop through other regions and mosaic together
for (i in 2:length(hybas_r_list)) {
  message(paste("starting", i))
  mosaic_add = terra::rast(hybas_r_list[i])
  mosaic_add = terra::resample(x = mosaic_add, y = area_r, method = 'near')
  mosaic_r = terra::mosaic(mosaic_r, mosaic_add, fun = "min")
  print(i)
}

terra::writeRaster(mosaic_r, "D:/projects/global-groundwatersheds/data/preparation/hybas_lev10_flt8s.tif", 
                   overwrite = T,
                   wopt=list(datatype="FLT8S"))

# step 3: splice the hydrobasins global raster into 5 regions used in the study
mosaic_world = terra::rast("D:/projects/global-groundwatersheds/data/preparation/hybas_lev10_flt8s.tif")

for (w in 1:length(world_regions)) {
  # w = 1
  terraOptions(datatype="FLT8S")
  
  message(paste0("starting: ", world_regions[w], "..."))
  
  crop_ext = extent_ranges |>  
    dplyr::filter(Region == world_regions[w]) |> 
    dplyr::pull(Extents)
  crop_ext = crop_ext[[1]]
  crop_ext
  
  # crop global raster
  region_hybas10 = terra::crop(x = mosaic_world,   y = crop_ext, wopt=list(datatype="FLT8S"))
  
  # ensure all masked by same layer
  mask  = terra::rast(paste0("D:/Geodatabase/Groundwater/Fan_depthtowatertable/Raw/Monthly_means/",
                             mask_folders[w], "_WTD_monthlymeans.nc"))
  mask = mask[[1]]
  terra::ext(mask) = crop_ext
  
  region_hybas10_m = terra::mask(x = region_hybas10, mask = mask, maskvalues = 0, wopt=list(datatype="FLT8S"))
  
  # hydrobasins 
  terra::writeRaster(x = region_hybas10_m, 
                     filename = file.path(dat_loc, world_regions[w], "hybas_l10_flt8s.tif"),
                     filetype = "GTiff", overwrite = T,
                     wopt=list(datatype="FLT8S"))
  message(paste0("hydrobasins done"))
}