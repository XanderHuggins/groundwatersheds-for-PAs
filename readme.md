# Groundwatersheds of protected areas

This repository documents the data workflow of Huggins et al. (in review). **Groundwatersheds of protected areas: globally overlooked risks and opportunities**

The repository is organized into three folders, representing workflow stages. These are setup, preprocessing, and analysis. Plotting scripts are not included in this repository, but can be made available upon request.

To find and access all data sources used in this analysis, visit [datasources.md](https://github.com/XanderHuggins/groundwatersheds-for-PAs/blob/main/datasources.md).

-   **R/** --
    -   **setup/** --
        -   *All setup scripts are called at the beginning of each preprocessing and analysis script.*
        -   `wd-args.R` sets working directory strings
        -   `packages-in.R` imports necessary packages from CRAN
        -   `region-extents.R` sets region extents to loop through as all results are calculated in regional bins and then merged
    -   **preprocessing/**
        -   *Preprocessing scripts are numbered into sequential stages (p1, p2, etc.). The numbers indicate the sequence scripts need to be executed in (e.g. scripts labelled **p2** will depend on output from **p1** scripts). However, scripts within the same stage can be executed in any order.*
        -   `p1-area-raster.R` generates a global area raster at 30 arc-second
        -   `p1-gwd-wetlands.R` isolates and resamples groundwater-driven wetlands
        -   `p1-teow-rasterize.R` rasterizes terrestrial ecoregions of the world
        -   `p1-land-mask.R` creates land mask
        -   `p1-hydrosheds.R` rasterizes perennial streams and HydroLAKES
        -   `p1-iso3-protected-pct-rast.R` rasterizes national protected area statistics
        -   `p1-land-borders-rast.R` generates raster representing international land border
        -   `p2-max-root-depth-elev.R` converts rooting depths to elevations
        -   `p2-protected-areas.R` subsets and rasterizes World Database on Protected Areas
        -   `p2-water-table-elev.R` converts water table depths to elevations
        -   `p3-root-zone-int-wt.R` identifies cells where root zones intersect the water table
        -   `p4-gde-cells.R` identified groundwater-dependent ecosystem grid cells
        -   `p5-region-crop-gwshed-derivation.R` crops core data for groundwatershed delineation to world regions
        -   `p5-region-crop-post-hoc.R` crops data for post-hoc analysis to world regions
    -   **analysis/** --
        -   *Analysis scripts are similarly numbered according the sequence they should be executed in.*
        -   `a1-groundwatersheds-delineation.R` delineates groundwatersheds for global protected areas
        -   `a2-gde-stats.R` calculates summary statistics for GDEs
        -   `a2-groundwatershed-stats.R` calculates summary statistics for groundwatersheds
        -   `a3-stats-merging.R` merges groundwatershed statistics across regions and datasets
        -   `a4-stats-reporting.R` calculates select groundwatershed statistics reported in the manuscript
        -   `a5-groundwatersheds-delineation-uncertainty.R` repeats script `a1-...` for monthly water tables
        -   `a6-summary-stats-uncertainty.R` repeats script `a2-...` for monthly water tables
        -   `a7-stats-merging-uncertainty.R` repeats script `a3-...` for monthly water tables
        -   `a8-stats-reporting-uncertainty.R` repeats script `a4-...` for monthly water tables
