# Name: theme.R
# Description: Set default theme arguments

my_theme = theme_minimal()+
  theme(legend.title = element_blank(),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        # panel.grid.major = element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA),
        plot.background = element_rect(fill = "transparent", colour = NA))

# and one alternative set of theme settings
cus_theme = theme(panel.background =  element_rect(fill = "transparent"),
                  plot.background = element_rect(fill = "transparent", colour = NA),
                  panel.grid = element_blank(),
                  axis.line = element_line(colour = "black"), panel.ontop = TRUE,
                  legend.position = "none") 