# Name: packages-in.R
# Description: Import all packages used in workflow

# general
library(tidyverse)
library(magrittr)

# spatial
library(raster) 
library(terra) 
library(sf)
library(spatstat.geom) # check if used anywhere in workflow, remove if not
library(rasterDT)
library(rgeos) 
library(gdalUtilities)

# plotting
library(scico) 
library(MetBrewer)
library(viridisLite)
library(RColorBrewer)
library(scales)
library(ggridges)
library(cowplot)

# Spatial plotting
library(rnaturalearth)
library(tmaptools)
library(tmap)

# stats
library(DescTools)