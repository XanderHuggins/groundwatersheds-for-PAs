## Groundwatersheds

This project maps the groundwatersheds of all ecologically-connected protected places, globally.

Ecologically-connected protected areas are identified where maximum rooting depth intersects with the steady state water table. 
<br/><br/>

#### Preprocessing scripts
`1_water-table-eleveations.R` : Converts Fan et al. 2013 depth to water table estimates to masl. <br/>

`2_rooting-elevation.R` : Converts Fan et al. 2017 maximum rooting depth estimates to masl. <br/>

`3_wdpa_preprocessing.R` : Extracts all [world database on protected areas](https://www.protectedplanet.net/en/thematic-areas/wdpa?tab=WDPA) that are identified as IUCN category: Ia, Ib, II, III, Not Assigned, or Not Recognized. <br/>

`4_pour-points.R` : Creates a point point (.shp point) for all 1-km grid cells where the water table is above the maximum rooting depth, and which fall into one of the identified protected areas.
<br/><br/>

#### Groundwatershed delineations
`CatchmentDelineation.ipynb` : Uses [pysheds](https://github.com/mdbartos/pysheds) to delineate groundwatersheds for each pour point.
<br/><br/>

##### Still to do:
- debug catchment delineation
- update Fan depth to water table w/ monthly means from 2020 eLetter
- think about how to address contiguous protected areas
