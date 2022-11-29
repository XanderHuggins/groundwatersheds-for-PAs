# Name: wd-args.R
# Description: Set working directories

wd = here()
wdpa_wd = "D:/Geodatabase/Groundwater/Groundwatersheds/Int-WDPA"
dat_loc = "D:/projects/global-groundwatersheds/data"
plot_sv = "C:/Users/xande/Documents/1.projects/1.active-projects/groundwatersheds/r-exports"

# Set temporary terra directory to external disk with storage availability
terraOptions(tempdir = "D://Geodatabase/Rtemp")
tmpFiles(current=TRUE, remove=TRUE) 