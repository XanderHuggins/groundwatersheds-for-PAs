# Name: f2-RGS-UPR.R
# Description: Plot RGS vs UPR for all protected areas

library(here)
invisible(sapply(paste0(here("R/setup"), "/", list.files(here("R/setup"))), source)) 

# import data sheet
s_df <- readr::read_csv(file.path(wd, paste0("data/STATS.csv")))

# generate moving percentiles 
line_df <- data.frame(
    x = seq(0,4, length.out = 20),
    mp = rep(NA),
    p90 = rep(NA),
    p50 = rep(NA),
    p10 = rep(NA)
  )

# calculate how these percentiles change through distribution
for (i in 1:(nrow(line_df)-1)) {
  
  lowlim <- line_df$x[i]
  uplim <- line_df$x[i+1]
  
  line_df$mp[i] <- (lowlim+uplim)/2
  
  temp_df <- s_df |> dplyr::filter(log10(RGS) >= lowlim & log10(RGS) < uplim)
  
  line_df$p90[i] <- quantile(x = temp_df$UPR, probs = 0.9, na.rm = T)
  line_df$p50[i] <- quantile(x = temp_df$UPR, probs = 0.5, na.rm = T)
  line_df$p10[i] <- quantile(x = temp_df$UPR, probs = 0.1, na.rm = T)
  
  print(i)
}

# set origin
top_df <- line_df[1,]
top_df[1,] <- c(0,0,0,0,0)
line_df <- rbind(top_df, line_df)

# plot
p_a11 <- ggplot(s_df, aes(x = log10(RGS), y = UPR)) +
  geom_point(shape = 21, fill = "#5EB1BC", alpha = 0.1, col = "#5EB1BC") +
  geom_line(data = line_df, aes(x = mp, y = p10), lwd = 0.5, col = 'black', lty = 'dashed') +
  geom_line(data = line_df, aes(x = mp, y = p50), lwd = 0.8, col = 'black') +
  geom_line(data = line_df, aes(x = mp, y = p90), lwd = 0.5, col = 'black', lty = 'dashed') +
  scale_x_continuous(breaks = c(0,1,2,3), labels = c(1,10,100, '')) +
  my_theme + theme(axis.text=element_text(colour="black")) +
  ylab('') + xlab('')+
  coord_cartesian(ylim = c(0,1), xlim = c(0,3), expand = c(0,0), clip = 'off')
p_a11

ggsave(file = file.path(plot_sv,"log10RGS-UPR-scatter.png"), 
       plot = p_a11, device = "png",
       width = 500/4, height = 250/4, units = "mm", dpi = 400) #saves g