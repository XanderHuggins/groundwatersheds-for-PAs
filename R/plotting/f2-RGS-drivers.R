# Name: f2-RGS-drivers.R
# Description: Plot distribution of RGS against possible drivers: aridity, surface slope.

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import data
s_df <- readr::read_csv(file.path(wd, paste0("data/STATS.csv")))

# RGS vs. aridity class ---
# create aridity classes
s_df$aridityClass <- rep(NA)
s_df$aridityClass[s_df$aridity/1e5 <= 0.03] <- 1 # hyper arid
s_df$aridityClass[s_df$aridity/1e5 > 0.03] <- 2 # arid
s_df$aridityClass[s_df$aridity/1e5 > 0.2] <- 3 # semi-arid
s_df$aridityClass[s_df$aridity/1e5 > 0.5] <- 4 # dry sub-humid
s_df$aridityClass[s_df$aridity/1e5 > 0.65] <- 5 # humid
s_df$aridityClass <- as.numeric(s_df$aridityClass)

p_df <- s_df |> dplyr::filter(aridityClass >= 1)
p_df$aridityClass <- as.factor(p_df$aridityClass)

p_aridity <- ggplot(p_df, aes(x=log10(RGS), y=aridityClass, fill = ..x..)) + 
  geom_density_ridges_gradient(scale = 3, rel_min_height = 0.001, lwd =0.5, bounds = c(0, Inf)) +
  # scale_fill_viridis_d(limits = c(0,2), oob = scales::squish) +
  scale_fill_gradientn(colors = c(scico(n = 100, palette = "batlow")),
                       limits = c(0, 2), oob = scales::squish) +
  scale_y_discrete(labels = c('Hyper-arid', 'Arid', 'Semi-arid', 'Dry sub-humid', 'Humid')) +
  scale_x_continuous(breaks = c(0,1,2,3), labels = c(1,10,100, '')) +
  my_theme + theme(axis.text=element_text(colour="black")) +
  ylab('') + xlab('')+
  coord_cartesian(xlim = c(0, 3), expand = c(0,0), clip = 'on')
p_aridity

# RGS vs. slope class ----
# create slope classes
s_df$slopeClass <- rep(NA)
s_df$slopeClass[s_df$slope <= 1] <- 1 # hyper arid
s_df$slopeClass[s_df$slope > 1] <- 2 # arid
s_df$slopeClass[s_df$slope > 2] <- 3 # semi-arid
s_df$slopeClass[s_df$slope > 4] <- 4 # dry sub-humid
s_df$slopeClass[s_df$slope > 8] <- 5 # humid
s_df$slopeClass <- as.numeric(s_df$slopeClass)

p_df <- s_df |> dplyr::filter(slopeClass >= 1)
p_df$slopeClass <- as.factor(p_df$slopeClass)

p_slope <- ggplot(p_df, aes(x=log10(RGS), y=slopeClass, fill = ..x..)) + 
  geom_density_ridges_gradient(scale = 3, rel_min_height = 0.001, lwd =0.5) +
  scale_fill_gradientn(colors = c(scico(n = 100, palette = "batlow")),
                       limits = c(0, 2), oob = scales::squish) +
  scale_y_discrete(labels = c('<1%', '1-2%', '2-4%', '4-8%', '>8%')) +
  scale_x_continuous(breaks = c(0,1,2,3), labels = c(1,10,100, '')) +
  my_theme + theme(axis.text=element_text(colour="black")) +
  ylab('') + xlab('log RGS')+
  coord_cartesian(xlim = c(0, 3), expand = c(0,0), clip = 'on')
p_slope

pp1 <- list(p_aridity, p_slope)
g <- plot_grid(plotlist=pp1, ncol=1, align='v')
g

ggsave(file = file.path(plot_sv, "ridgelines-RGS-stacked-slope-aridity.png"), 
       plot = g, device = "png", width = 500/4, height = 250/2, units = "mm", dpi = 400) #saves g