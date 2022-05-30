### Groundwatersheds of the world's protected areas

This repository documents the workflow of Serrano, Huggins et al. (in review). **Overlooked risks and opportunities for global protected areas revealed by mapping groundwatersheds.**

The repository is organized by four folders, representing stages of the analysis workflow: 1: setup, 2: preprocessing, 3: analysis, and 4:plotting.

* **R/** -- 
    * **setup/** -- 
      * *All setup scripts are called at the beginning of each preprocessing, analysis, and plotting script.*
      * `wd-args.R` sets working directory strings
      * `packages-in.R` imports necessary packages
      * `region-extents.R` sets region extents to loop through
      * `wgs-area-calculator.R` derives global raster representing cell areas
    * **preprocessing/** 
      * *Preprocessing scripts are numbered into five stages (p1, p2, ..., p5). These indicate the sequence scripts need to be executed in (e.g. scripts labelled **p2** will depend on output from **p1** scripts). However, scripts within the same stage can be executed in any order.*
      *   `p1-area-raster.R` generates a global area raster at 30 arc-second
      *   `p1-feow-rasterize.R` rasterizes freshwater ecoregions of the world
      *   `p1-hydrosheds-data.R` rasterizes perennial streams and HydroLAKES
      *   `p1-iso3-protected-pct-rast.R` rasterizes national protected area statistics
      *   `p1-slope-preparation.R` generates surface slope raster
      *   `p1-land-borders-rast.R` generates raster representing presence of international land border
      *   `p2-max-root-depth-elev.R` converts rooting depths to elevations
      *   `p2-protected-areas.R` subsets and rasterizes World Database on Protected Areas
      *   `p2-water-table-elev.R` converts water table depths to elevations
      *   `p3-root-zone-int-wt.R` identifies cells where root zones intersect the water table
      *   `p4-eco-cells.R` merges root zone intersections, perrennial streams, and lakes
      *   `p5-region-cropping-core-gwshed-data.R` crops core data for groundwatershed delineation to world regions
      *   `p5-region-cropping-post-hoc-data.R` crops data for post-hoc analysis to world regions
    * **analysis/** -- 
      * *Analysis scripts are similarly numbered according the sequence they should be executed in.*
      * `a1-groundwatersheds-delineation.R` delineates groundwatersheds for global protected areas
      * `a2-summary-stats.R` calculates summary statistics
      * `a3-stats-merging.R` merges summary statistics across regions and datasets
      * `a4-stats-reporting.R` calculates select statistics reported in the manuscript.
    * **plotting+stats/**
      * *Includes a number of scripts that generate plots used in manuscript figures.*
