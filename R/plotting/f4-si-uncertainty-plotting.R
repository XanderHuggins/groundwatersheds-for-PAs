# Name: f4-uncertainty-plotting.R
# Description: Uncertainty boxplots revealing range in groundwatershed extents per world region across monthly water tables.

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source))

for (w in 1:length(world_regions)) {
  
  df_gwshed = readr::read_csv(file.path(dat_loc, world_regions[w], "uncertainty_gwshed.csv"))
  df_unprot = readr::read_csv(file.path(dat_loc, world_regions[w], "uncertainty_unprot.csv"))
  df_protar = readr::read_csv(file.path(dat_loc, world_regions[w], "STAT_protected_area_area.csv"))
  
  df_gwshed_uncert = data.frame(month = seq(1, 12), area = rep(NA))
  df_unprot_uncert = data.frame(month = seq(1, 12), area = rep(NA))
  
  for (m in 1:12) {
    df_gwshed_uncert[m,2] = sum(df_gwshed[,m+1], na.rm = T)
    df_unprot_uncert[m,2] = sum(df_unprot[,m+1], na.rm = T)
    df_protarea_sum = sum(df_protar$area, na.rm = T) 
  }
  
  assign(paste0("gwshed_uncert_", world_regions[w]), df_gwshed_uncert)
  assign(paste0("unprot_uncert_", world_regions[w]), df_unprot_uncert)
  assign(paste0("prot_area_", world_regions[w]), df_protarea_sum)
}

aa = 0.2
ggplot() +
  annotate("rect", xmin=0,  xmax=Inf,   ymin=0,    ymax=1.5,  fill="grey50", alpha=aa) + 
  annotate("rect", xmin=0,  xmax=Inf,   ymin=2.5,  ymax=3.5,  fill="grey50", alpha=aa) + 
  annotate("rect", xmin=0,  xmax=Inf,   ymin=4.5,  ymax=5.5,  fill="grey50", alpha=aa) + 
  
  geom_boxplot(data = gwshed_uncert_NorthAmerica, aes(x = area, y = 2)) +
  geom_point(aes(x = prot_area_NorthAmerica, y = 2), shape = 18, color = "green4", size = 8)+
  
  geom_boxplot(data = gwshed_uncert_Africa, aes(x = area, y = 4)) +
  geom_point(aes(x = prot_area_Africa, y = 4), shape = 18, color = "green4", size = 8)+
  
  geom_boxplot(data = gwshed_uncert_Eurasia, aes(x = area, y = 5)) +
  geom_point(aes(x = prot_area_Eurasia, y = 5), shape = 18, color = "green4", size = 8)+
  
  geom_boxplot(data = gwshed_uncert_Oceania, aes(x = area, y = 1)) +
  geom_point(aes(x = prot_area_Oceania, y = 1), shape = 18, color = "green4", size = 8)+
  
  geom_boxplot(data = gwshed_uncert_SouthAmerica, aes(x = area, y = 3)) +
  geom_point(aes(x = prot_area_SouthAmerica, y = 3), shape = 18, color = "green4", size = 8)+
  
  scale_y_continuous(breaks = seq(1,5), labels = c('Oceania', 'North America', 'South America', 'Africa', 'Eurasia')) +
  
  cus_theme + theme(axis.text=element_text(colour="black"),
                    plot.margin = unit(c(2,5,2,2), "mm")) +
  ylab('') + xlab('') + 
  coord_cartesian(xlim = c(0, 8e12), ylim = c(0.5,5.5), clip = "on", expand=c(0))

ggsave(file = file.path(plot_sv, "uncertainty-boxplot-gwshed-size.png"), 
       plot = last_plot(), device = "png", width = 400/2.5, height = 200/2, units = "mm", dpi = 400) #saves g
