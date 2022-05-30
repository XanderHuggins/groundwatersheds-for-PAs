# Name: wd-args.R
# Description: Set working directories

wd = here()
wdpa_wd = "D:/Geodatabase/Groundwater/Groundwatersheds/Int-WDPA"
plot_sv = "C:/Users/xande/Desktop/phd-root/1.active-projects/groundwatersheds/r-exports"

# Set temporary terra directory to external disk with storage availability
terraOptions(tempdir = "D://Geodatabase/Rtemp")