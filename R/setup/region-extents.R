# Name: region-extents.R
# Description: Set bounding boxes of the five world regions, analyzed individually to lower memory demands of workflow

world_regions = c("NorthAmerica", "SouthAmerica", "Oceania", "Africa", "Eurasia")
topo_folders = c("NAMERICA", "SAMERICA", "AUSTRALIA", "AFRICA", "EURASIA")
mask_folders = c("NAMERICA", "SAMERICA", "OCEANIA", "AFRICA", "EURASIA")
rd_names = c("North_America", "South_America", "Australia", "Africa", "Europe_and_Asia")

extent_ranges = tibble(Region = world_regions,
                       Extents = c(terra::ext(c(-180, -52, 5, 84)),
                                   terra::ext(c(-93, -32, -56, 15)),
                                   terra::ext(c(95, 180, -47.66666666, 7.5)),
                                   terra::ext(c(-19, 55, -35, 38)),
                                   terra::ext(c(-14, 180, 0, 83))))
