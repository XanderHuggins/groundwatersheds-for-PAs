### Data sources used in "Overlooked risks and opportunities for global protected areas revealed by mapping groundwatersheds"

Each data source is described using the following template: **Data source**, **Persistent web-link**, **Temporal range**, **Spatial Resolution**, **Description and Justification**, **Preprocessing**, and **Preprocessing script**. Note that this markdown file is a replica of Supplementary Table 1. 

## Protected areas
**Data source**: World database on protected areas (WDPA) <br>
**Persistent web-link**: <https://www.protectedplanet.net> <br>
**Temporal range**: Last accessed 7 June 2021. <br>
**Spatial resolution**: Vector data. <br>
**Description and justification**. The WDPA is the most extensive database of protected areas and is the standard data source for global studies considering protected areas. <br>
**Preprocessing**: Protected areas were filtered for their protected area class and reported surface area (see 3. Methodology), and subsequently rasterized in a binary representation of protected area presence/non-presence at 0.5 arc-minute (\~1 km) resolution, including all grid cells touched by a protected area retained after filtering. All spatially contiguous protected areas were then identified and provided a unique ID for analysis and summarizing. This filtering, flattening, and joining of the WDPA dataset based on spatial contiguity reduced the global protected areas count from \~270,000 to \~43,500. <br>
**Preprocessing script**: p2-protected-areas.R <br>

## Water table depth
**Data source**: Fan et al. <br>
**Persistent web-link**: <http://thredds-gfnl.usc.es/thredds/catalog/GLOBALWTDFTP/catalog.html> <br>
**Temporal range**: Mean monthly results over a 2000-2010 model run. <br>
**Spatial resolution**: 30 arc-second (\~1 km) <br>
**Description and justification**: The leading global water table depth dataset, however others do exist. We also select this dataset as it is produced at the same resolution and by the same core authorship team as the maximum rooting depth dataset. Here, we use the 2020 update of this data (not the original 2013 data), which made model improvements and provided mean monthly water table depth values in addition to the annual mean over the model run. <br>
**Preprocessing**: Water table depths were converted to water table elevations by subtracting the WTD from the land surface elevation (see below). <br>
**Preprocessing script**: p2-water-table-elev.R <br>

## Maximum rooting depth
**Data source**: Fan et al. <br>
**Persistent web-link**: <https://wci.earth2observe.eu/thredds/catalog/usc/root-depth/catalog.html>  <br>
**Temporal range**: Average value of 2004-2013 model run. <br>
**Spatial resolution**: 30 arc-second (\~1 km) <br>
**Description and justification**: To our knowledge, this is the only spatially distributed dataset of maximum rooting depth with full global terrestrial surface area coverage. <br>
**Preprocessing**: Maximum rooting depths were converted to root zone base elevations by subtracting the maximum rooting depth from the land surface elevation (see below). <br>
**Preprocessing script**: p2-max-root-depth-elev.R <br>

## Land surface elevation
**Data source**: Associated with both Fan et al. datasets above <br>
**Persistent web-link**: Provided through direct author correspondence, and consistent with the land surface elevation dataset used for the rooting depth and water table depth data products. <br>
**Temporal range**: N/A <br>
**Spatial resolution**: 30 arc-second (\~1 km) <br>
**Description and justification**: The land surface elevation data provided and used by the Fan et al. studies listed above. <br> 
**Preprocessing**: None <br>
**Preprocessing script**: N/A <br>

## Perennial rivers 
**Data source**: Messager et al. <br>
**Persistent web-link**: <https://figshare.com/articles/dataset/Global_prevalence_of_non-perennial_rivers_and_streams/14633022> <br>
**Temporal range**: N/A <br>
**Spatial resolution**: Vector data <br>
**Description and justification**: A global prediction of river flow intermittence probability, using the river network of the global RiverATLAS database (Linke et al. 2019) (15) for all stream reaches with a mean annual flow of 0.1 m3s-1. <br>
**Preprocessing**: Rasterized all perennial rivers, which are identified at the individual river reach level, to a 30 arc-second (\~1 km) grid including all grid cells touched by a perennial river. <br>
**Preprocessing script**: p1-hydrosheds.R <br>

## Groundwater-driven wetlands
**Data source**: Tootchi et al. <br>
**Persistent web-link**: <https://doi.pangaea.de/10.1594/PANGAEA.892657> <br>
**Temporal range**: N/A <br>
**Spatial resolution**: 15 arc-second (\~500 m) <br>
**Description and justification**: Global composite wetland maps that specify sub-classes of routinely flooded wetlands (RFW) and groundwater-driven wetlands (GWD). Though other global wetland maps exist, this is the only dataset to our knowledge that explicitly identifies groundwater-driven wetlands. <br>
**Preprocessing**: Groundwater-driven wetlands were isolated from the composite wetland maps, and aggregated to 30 arc-second (\~1 km) resolution based on a binary evaluation of if a groundwater-driven wetland grid cell at the original resolution was contained within the grid cell at the aggregated resolution. <br>
**Preprocessing script**: p1-gwd-wetlands.R <br>

## Lakes
**Data source**: Messager et al. <br>
**Persistent web-link**: <https://www.hydrosheds.org/products/hydrolakes> <br>
**Temporal range**: N/A <br>
**Spatial resolution**: Vector data. <br>
**Description and justification**: The leading global lakes dataset, which aims to include all lakes with a minimum surface area of 10 ha. <br>
**Preprocessing**: All lakes included in the database are rasterized to a 30 arc-second (\~1 km) grid, including all grid cells touched by a lake polygon. <br>
**Preprocessing script**: p1-hydrosheds.R <br>

## Aridity
**Data source**: Trabucco and Zomer <br>
**Persistent web-link**: <https://figshare.com/articles/dataset/Global_Aridity_Index_and_Potential_Evapotranspiration_ET0_Climate_Database_v2/7504448/3> <br>
**Temporal range**: 1970-2000 <br>
**Spatial resolution**: 30 arc-second (\~1 km) <br>
**Description and justification**: Aridity data from the Global Aridity Index and Potential Evapotranspiration Database that provides spatially distributed aridity index data based on the 1970-2000 period using the Penman-Montieth Reference Evapotranspiration equation. <br>
**Preprocessing**: None <br>
**Preprocessing script**: N/A <br>

## Human modification gradient
**Data source**: Kennedy et al. <br>
**Persistent web-link**: <https://figshare.com/articles/dataset/Global_Human_Modification/7283087> <br>
**Temporal range**: Median indicator year of 2016. <br>
**Spatial resolution**: 1 km <br>
**Description and justification**: A global representation of the degree of human modification made to terrestrial lands based on 13 stressors, that include human settlement, agriculture, transportation, mining, and energy datasets. To our knowledge, this is the most recent and comprehensive mapping of anthropogenic stressors to terrestrial lands available. <br>
**Preprocessing**: Reprojected from 1 km resolution in Mollweide Projection to WGS 84 and resampled at 30 arc-second (\~1 km) resolution using nearest neighbor cell value assignment. <br>
**Preprocessing script**: p5-region-crop-post-hoc.R <br>
