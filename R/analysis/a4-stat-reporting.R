# Name: a4-stat-reporting.R
# Description: Calculate statistics for reporting in manuscript. 

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import main data sheet
s_df = readr::read_csv(file.path(dat_loc, "rev_STATS.csv"))
nrow(s_df) # 43544

s_df = s_df |> filter(log10(area/1e6) > 0)
nrow(s_df) ## 37782

s_df |> filter(RGS >= 0) |> nrow() # 34719
s_df |> filter(UGR >= 0) |> nrow() # 34719

# clean and calculate median and IQR of RGS:
s_df = s_df |> filter(RGS >= 0)
median(s_df$RGS) ## > 1.39112
quantile(s_df$RGS, 0.25) # 1.146544 
quantile(s_df$RGS, 0.75) # 1.815177

# calculate median and IQR of UGR:
s_df = readr::read_csv(file.path(dat_loc, "rev_STATS.csv"))
s_df = s_df |> filter(UGR >= 0 & log10(area/1e6) > 0)
median(s_df$UGR) # 0.5183657
quantile(s_df$UGR, 0.25) # 0.1665859 
quantile(s_df$UGR, 0.75) # 0.7963404

# PA size vs groundwatershed size
s_df = readr::read_csv(file.path(dat_loc, "rev_STATS.csv"))
s_df = s_df |> filter(log10(area/1e6) > 0 & gwshed_area >= 0)
# calculate a moving average of groundwatershed size : protected area size 

# calculate moving range of percentiles 
line_df <- data.frame(
  x = seq(-1,6, length.out = 20), mp = rep(NA), p90 = rep(NA), p50 = rep(NA), p10 = rep(NA)
)

# calculate how these percentiles change through distribution
for (i in 1:(nrow(line_df)-1)) {
  # i = 1
  lowlim <- line_df$x[i]
  uplim <- line_df$x[i+1]
  
  line_df$mp[i] <- (lowlim+uplim)/2
  
  temp_df <- s_df |> dplyr::filter((log(area/1e6) >= lowlim) & (log(area/1e6) < uplim))
  
  line_df$p90[i] <- quantile(x = temp_df$gwshed_area / temp_df$area, probs = 0.75, na.rm = T)
  line_df$p50[i] <- quantile(x = temp_df$gwshed_area / temp_df$area, probs = 0.5, na.rm = T)
  line_df$p10[i] <- quantile(x = temp_df$gwshed_area / temp_df$area, probs = 0.25, na.rm = T)
  print(i)
}

# set origin
top_df <- line_df[1,]
# top_df[1,] <- c(0,0,0,0,0)
line_df <- rbind(top_df, line_df)

ggplot(s_df, aes(x = log10(area/1e6), y = log10(gwshed_area/1e6) )) +
  geom_point(shape = 21, fill = "#5EB1BC", alpha = 0.1, col = "#5EB1BC") +
  # scale_x_continuous(breaks = c(0,1,2,3), labels = c(1,10,100, '')) +
  my_theme + theme(axis.text=element_text(colour="black")) +
  ylab('') + xlab('') + geom_abline() +
  coord_cartesian(xlim=c(0,6), ylim=c(-2,6),expand = 0, clip = 'on')

ggsave(file = file.path(plot_sv,"logPAarea_logGWSHEDarea.png"), 
       plot = last_plot(), device = "png",
       width = 500/3, height = 500/4, units = "mm", dpi = 400) #saves g

ggplot() + 
  geom_line(data = line_df, aes(x = mp, y = p10), lwd = 0.5, col = 'black', lty = 'dashed') +
  geom_line(data = line_df, aes(x = mp, y = p50), lwd = 0.8, col = 'black') +
  geom_line(data = line_df, aes(x = mp, y = p90), lwd = 0.5, col = 'black', lty = 'dashed') +
  ylab('') + xlab('') + 
  my_theme + theme(axis.text=element_text(colour="black")) +
  coord_cartesian(xlim=c(0,6), ylim=c(0,8),expand = 0, clip = 'on')

ggsave(file = file.path(plot_sv,"RATIO_logPAarea_logGWSHEDarea.png"), 
       plot = last_plot(), device = "png",
       width = 500/3, height = 500/6, units = "mm", dpi = 400) #saves g


# plot PA size vs. UPR ratio
# calculate how these percentiles change through distribution
for (i in 1:(nrow(line_df)-1)) {
  # i = 1
  lowlim <- line_df$x[i]
  uplim <- line_df$x[i+1]
  
  line_df$mp[i] <- (lowlim+uplim)/2
  
  temp_df <- s_df |> dplyr::filter((log10(area/1e6) >= lowlim) & (log10(area/1e6) < uplim))
  
  line_df$p90[i] <- quantile(x = temp_df$UGR, probs = 0.75, na.rm = T)
  line_df$p50[i] <- quantile(x = temp_df$UGR, probs = 0.5, na.rm = T)
  line_df$p10[i] <- quantile(x = temp_df$UGR, probs = 0.25, na.rm = T)
  print(i)
}

# set origin
top_df <- line_df[1,]
# top_df[1,] <- c(0,0,0,0,0)
line_df <- rbind(top_df, line_df)

ggplot(s_df, aes(x = log10(area/1e6), y = UGR)) +
  geom_point(shape = 21, fill = "#5EB1BC", alpha = 0.1, col = "#5EB1BC") +
  # scale_x_continuous(breaks = c(0,1,2,3), labels = c(1,10,100, '')) +
  my_theme + theme(axis.text=element_text(colour="black")) +
  ylab('') + xlab('')+
  coord_cartesian(ylim = c(0,1), xlim = c(0, 6), expand = 0, clip = 'on')

ggsave(file = file.path(plot_sv,"logPAarea_UGR.png"), 
       plot = last_plot(), device = "png",
       width = 500/3, height = 500/4, units = "mm", dpi = 400) #saves g

ggplot() + 
  geom_line(data = line_df, aes(x = mp, y = p10), lwd = 0.5, col = 'black', lty = 'dashed') +
  geom_line(data = line_df, aes(x = mp, y = p50), lwd = 0.8, col = 'black') +
  geom_line(data = line_df, aes(x = mp, y = p90), lwd = 0.5, col = 'black', lty = 'dashed') +
  ylab('') + xlab('') + 
  my_theme + theme(axis.text=element_text(colour="black")) +
  coord_cartesian(xlim=c(0,6), ylim=c(0,1),expand = 0, clip = 'on')

ggsave(file = file.path(plot_sv,"UPR_trend_logPAarea.png"), 
       plot = last_plot(), device = "png",
       width = 500/3, height = 500/6, units = "mm", dpi = 400) #saves g


# histogram bin plot
max.cut = 4
s_df$RGS_cut = s_df$RGS
s_df$RGS_cut[s_df$RGS_cut > max.cut] = max.cut
s_df = s_df |> filter(RGS_cut >= 1)

ggplot() +
  geom_histogram(data = s_df, aes(x = RGS_cut), bins = 20, fill = "grey50") +
  # scale_fill_gradientn(colors = c(scico(n = 100, palette = "batlow")),
  #                      limits = c(0, 4), oob = scales::squish) +
  geom_vline(xintercept = quantile(s_df$RGS, 0.5)) +
  geom_vline(xintercept = quantile(s_df$RGS, 0.25)) +
  geom_vline(xintercept = quantile(s_df$RGS, 0.75)) +
  my_theme + theme(axis.text=element_text(colour="black"), panel.grid.major = element_blank()) +
  coord_cartesian(xlim = c(1,max.cut), clip = "on") +
  theme(axis.text=element_text(colour="black"),
        plot.margin = unit(c(2,5,2,2), "mm")) +
  ylab('') + xlab('')

ggsave(file = file.path(plot_sv,"RGS_histogram.png"), 
       plot = last_plot(), device = "png",
       width = 500/4, height = 250/4, units = "mm", dpi = 400) 


ggplot() +
  geom_histogram(data = s_df, aes(x = UGR), bins = 20, fill = "grey50") +
  # scale_fill_gradientn(colors = c(scico(n = 100, palette = "batlow")),
  #                      limits = c(0, 4), oob = scales::squish) +
  geom_vline(xintercept = quantile(s_df$UGR, 0.5)) +
  geom_vline(xintercept = quantile(s_df$UGR, 0.25)) +
  geom_vline(xintercept = quantile(s_df$UGR, 0.75)) +
  my_theme + theme(axis.text=element_text(colour="black"), panel.grid.major = element_blank()) +
  coord_cartesian(xlim = c(0,1), clip = "on") +
  theme(axis.text=element_text(colour="black"),
        plot.margin = unit(c(2,5,2,2), "mm")) +
  ylab('') + xlab('')

ggsave(file = file.path(plot_sv,"UGR_histogram.png"), 
       plot = last_plot(), device = "png",
       width = 500/4, height = 250/4, units = "mm", dpi = 400) 



# basic summary statistics

s_df = readr::read_csv(file.path(dat_loc, "rev_STATS.csv"))
s_df = s_df |> filter(log10(area/1e6) > 0 & UGR >= 0 & RGS >= 0) #nrow = 34719

sum(s_df$gwshed_area, na.rm = T)/1e12 # 23.04226 million km2 - area of groundwatersheds of protected areas considered
sum(s_df$area, na.rm = T)/1e12 # 12.54961 million km2 - area of protected areas considered
23.04226/12.54961 # 1.836094

s_df |> dplyr::filter(unprot_gwshed_area > 0) |> nrow() / # 29553 
  s_df |> dplyr::filter(gde_area > 0) |> nrow() # 34719, frac = 85%

# proportion of groundwatersheds in protected areas
1 - sum(s_df$unprot_gwshed_area, na.rm = T)/sum(s_df$gwshed_area, na.rm = T)

# frequency of transboundary groundwatersheds and transboundary protected areas
s_df |> dplyr::filter(prot_area_transbound == 1) |> nrow() # 977 protected areas are transboundary
s_df |> dplyr::filter(gw_sheds_transbound == 1) |> nrow() # 1447 groundwatersheds are transboundary
s_df |> filter(gw_sheds_transbound == 1 & prot_area_transbound == 0) |> nrow() # 484 groundwatersheds are TB but the PA is not TB