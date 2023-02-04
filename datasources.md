### Sources and descriptions of data used in "Overlooked risks and opportunities in groundwatersheds of the world’s protected areas"

Each data source is described using the following template: **Data source**, **Persistent web-link**, **Temporal range**, **Spatial Resolution**, **Description and Justification**, **Preprocessing**, and **Preprocessing script**. 

## Protected areas
**Data source**: World database on protected areas (WDPA) <br>
**Persistent web-link**: <https://www.protectedplanet.net> <br>
**Temporal range**: Last accessed 7 June 2021. <br>
**Spatial resolution**: Vector data. <br>
**Description and justification**. The WDPA is the most extensive database of protected areas and is the standard data source for global studies considering protected areas. <br>
**Preprocessing**: Protected areas were filtered for their protected area class and reported surface area (see 3. Methodology), and subsequently rasterized in a binary representation of protected area presence/non-presence at 30 arcsecond (~1 km) resolution, including all grid cells touched by a protected area. All spatially contiguous protected areas were then identified and provided a unique ID for analysis. <br>
**Preprocessing script**: [p1-protected-areas.R](https://github.com/XanderHuggins/groundwatersheds-for-PAs/blob/main/scripts/1-preprocessing/p1-protected-areas.R) <br>

## Water table depth
**Data source**: Fan et al.(2017) <br>
**Persistent web-link**: <http://thredds-gfnl.usc.es/thredds/catalog/GLOBALWTDFTP/catalog.html> <br>
**Temporal range**: Mean monthly results over 2004-2013 model run. <br>
**Spatial resolution**: 30 arcsecond <br>
**Description and justification**: The leading global water table depth dataset. We also select this dataset as it is produced in the same study as the maximum rooting depth data. <br>
**Preprocessing**: Water table depths were converted to water table elevations by subtracting the water table depth from the land surface elevation. <br>
**Preprocessing script**: [p1-water-table-elev.R](https://github.com/XanderHuggins/groundwatersheds-for-PAs/blob/main/scripts/1-preprocessing/p1-water-table-elev.R) <br>

## Rooting depth
**Data source**: Fan et al. (2017) <br>
**Persistent web-link**: <https://wci.earth2observe.eu/thredds/catalog/usc/root-depth/catalog.html>  <br>
**Temporal range**: Averaged over 2004-2013 model run. <br>
**Spatial resolution**: 30 arcsecond <br>
**Description and justification**: To our knowledge, this is the only spatially distributed dataset of maximum rooting depth with full global terrestrial surface area coverage. <br>
**Preprocessing**: N/A <br>
**Preprocessing script**: N/A <br>

## Land surface elevation
**Data source**: Associated with both Fan et al. data above <br>
**Persistent web-link**: Provided through direct author correspondence, and consistent with the land surface elevation dataset used for the rooting depth and water table depth data. <br>
**Temporal range**: N/A <br>
**Spatial resolution**: 30 arcsecond <br>
**Description and justification**: The land surface elevation data provided and used by the Fan et al. studies listed above. These studies mosaiced 30 arcsecond USGS HydroSHEDS digital elevation model, that hydrologically conditions NASA Shuttle Radar Topography Mission (SRTM) elevation data, for grids south of 60°N. For grids north of 60°N, the studies averaged 1 arcsecond NASA-JPL ASTER Global Digital Elevation Map within 30 arcsecond grid cells. <br> 
**Preprocessing**: None <br>
**Preprocessing script**: N/A <br>

## Perennial rivers 
**Data source**: Messager et al. (2021) <br>
**Persistent web-link**: <https://figshare.com/articles/dataset/Global_prevalence_of_non-perennial_rivers_and_streams/14633022> <br>
**Temporal range**: N/A <br>
**Spatial resolution**: Vector data <br>
**Description and justification**: A global prediction of river flow intermittence probability, using the river network of the global RiverATLAS database (Linke et al. 2019) (15) for all stream reaches with a mean annual flow of 0.1 m3s-1. <br>
**Preprocessing**: Rasterized all perennial rivers, which are identified at the individual river reach level, to a 30 arcsecond (~1 km) grid including all grid cells touched by a perennial river. <br>
**Preprocessing script**: [p1-hydrosheds-ires.R](https://github.com/XanderHuggins/groundwatersheds-for-PAs/blob/main/scripts/1-preprocessing/p1-hydrosheds-ires.R) <br>

## Groundwater-dependent wetlands
**Data source**: Tootchi et al. (2019) <br>
**Persistent web-link**: <https://doi.pangaea.de/10.1594/PANGAEA.892657> <br>
**Temporal range**: N/A <br>
**Spatial resolution**: 15 arcsecond <br>
**Description and justification**: Global composite wetland maps that specify sub-classes of routinely flooded wetlands (RFW) and groundwater-driven wetlands (GWD). Though other global wetland maps exist, this is the only dataset to our knowledge that explicitly identifies groundwater-driven wetlands. <br>
**Preprocessing**: Groundwater-driven wetlands were isolated from the composite wetland maps and aggregated to 30 arcsecond (~1 km) resolution based on a binary evaluation of if a groundwater-driven wetland grid cell at the original resolution was contained within the grid cell at the aggregated resolution.  <br>
**Preprocessing script**: [p1-gwd-wetlands.R](https://github.com/XanderHuggins/groundwatersheds-for-PAs/blob/main/scripts/1-preprocessing/p1-gwd-wetlands.R) <br>

## Lakes
**Data source**: Messager et al. (2016) <br>
**Persistent web-link**: <https://www.hydrosheds.org/products/hydrolakes> <br>
**Temporal range**: N/A <br>
**Spatial resolution**: Vector data. <br>
**Description and justification**: The leading global lakes dataset, which aims to include all lakes with a minimum surface area of 10 ha. <br>
**Preprocessing**: All lakes included in the database are rasterized to a 30 arc-second (\~1 km) grid, including all grid cells touched by a lake polygon. <br>
**Preprocessing script**: [p1-hydrolakes.R](https://github.com/XanderHuggins/groundwatersheds-for-PAs/blob/main/scripts/1-preprocessing/p1-hydrolakes.R) <br>

## Aridity
**Data source**: Trabucco and Zomer (2018) <br>
**Persistent web-link**: <https://figshare.com/articles/dataset/Global_Aridity_Index_and_Potential_Evapotranspiration_ET0_Climate_Database_v2/7504448/3> <br>
**Temporal range**: 1970-2000 <br>
**Spatial resolution**: 30 arcsecond  <br>
**Description and justification**: Aridity data from the Global Aridity Index and Potential Evapotranspiration Database that provides spatially distributed aridity index data based on the 1970-2000 period using the Penman-Montieth Reference Evapotranspiration equation. <br>
**Preprocessing**: None <br>
**Preprocessing script**: N/A <br>

## Human modification gradient
**Data source**: Kennedy et al. (2019) <br>
**Persistent web-link**: <https://figshare.com/articles/dataset/Global_Human_Modification/7283087> <br>
**Temporal range**: Median indicator year of 2016. <br>
**Spatial resolution**: 1 km <br>
**Description and justification**: A global representation of the degree of human modification made to terrestrial lands based on 13 stressors, that include human settlement, agriculture, transportation, mining, and energy datasets. To our knowledge, this is the most recent and comprehensive mapping of anthropogenic stressors to terrestrial lands available. <br>
**Preprocessing**: Reprojected from 1 km resolution in the Mollweide projection to WGS 84 and resampled at 30 arcsecond (~1 km) resolution using nearest neighbor cell value assignment. <br>
**Preprocessing script**: included in:  [ps2-region-crop-post-hoc.R](https://github.com/XanderHuggins/groundwatersheds-for-PAs/blob/main/scripts/1-preprocessing/ps2-region-crop-post-hoc.R) <br>
