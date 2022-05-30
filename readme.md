### Groundwatersheds of the world's protected areas

This repository documents the workflow of Serrano, Huggins et al. (in review). **Overlooked risks and opportunities for global protected areas revealed by mapping groundwatersheds.**

The repository is organized by four folders, representing stages of the analysis workflow: 1: setup, 2: preprocessing, 3: analysis, and 4:plotting.

#### R/setup

*All setup scripts are called at the beginning of each preprocessing,
analysis, and plotting script.*

|                         |                                                                  |
|-----------------------|-------------------------------------------------|
| `wd-args.R`             | Sets working directory strings                                   |
| `packages-in.R`         | Imports necessary packages                                       |
| `region-extents.R`      | Sets region extents for looping in analysis                      |
| `wgs-area-calculator.R` | Derives global raster with cell areas represented by cell value. |

#### **R/preprocessing**

*Preprocessing scripts are numbered into five sections (p1, p2, ..., p5). These indicate the sequence scripts need to be executed in (i.e.scripts in p2 will depend on output from p1). However, scripts within the same section can be executed in any order.*

|                                         |                                                                       |
|---------------------------|---------------------------------------------|
| `p1-area-ras.R`                         | Generates area raster at 30 arc-seconds                               |
| `p1-feow-rasterize.R`                   | Rasterizes freshwater ecoregions of the world                         |
| `p1-hydrosheds-data.R`                  | Rasterizes perennial streams and HydroLAKES                           |
| `p1-iso3-protected-pct-rast.R`          | Rasterizes national protected area statistics                         |
| `p1-slope-preparation.R`                | Generates surface slope raster                                        |
| `p1-land-borders-rast.R`                | Generates raster indicating presence of international land border     |
| `p2-max-root-depth-elev.R`              | Converts rooting depth to elevation                                   |
| `p2-protected-areas.R`                  | Subsets and rasterizes protected areas                                |
| `p2-water-table-elev.R`                 | Converts water table depths to elevation                              |
| `p3-root-zone-int-wt.R`                 | Identifies where root zones intersect the water table                 |
| `p4-eco-cells.R`                        | Merges root zone intersections with perennial stream and lake extents |
| `p5-region-cropping-core-gwshed-data.R` | Crops core data for groundwatershed delineation to five world regions |
| `p5-region-cropping-post-hoc-data.R`    | Crops data for post-hoc analysis to five world regions                |

#### **R/analysis**

*Analysis scripts are similarly numbered according the sequence they
should be executed in.*

|                                     |                                                                       |
|--------------------------------|----------------------------------------|
| `a1-groundwatersheds-delineation.R` | Core methods to delineate groundwatersheds for global protected areas |
| `a2-summary-stats.R`                | Calculates summary statistics                                         |
| `a3-stats-merging.R`                | Merges summary statistics across regions and datasets                 |
| `a4-stat-reporting.R`               | Calculates statistics reported in manuscript                          |

#### **R/plotting**

*Includes a number of scripts that generate plots used in manuscript figures.*
