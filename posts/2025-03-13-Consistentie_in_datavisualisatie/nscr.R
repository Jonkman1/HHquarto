# nscr.R 

# laad de pakketten
library(magick)
library(cowplot)
library(ggplot2)
library(showtext)

# definieer default thema
theme_nscr <- theme_cowplot() +
  theme_minimal() +
  theme(title = element_text(color = '#414141'), 
        plot.title = element_text(size = 20, hjust = 0.5), 
        plot.subtitle = element_text(size = 14, hjust = 0.5),
        plot.caption = element_text(size = 8),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 8, color = '#414141'),
        text = element_text(family = "Calibri"),
        line = element_line(linewidth = 0.75, color = '#B81E61')) +
  # aanpassen gridlines
  theme(axis.line = element_line(color='black'),
        plot.background = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank())

# defineer logo 
nscr_logo <- image_read('1a_NSCR_LogoBasis_RGB.jpg')

# creëer functie waarmee je logo koppelt aan de plot
add_nscr_logo_plot <- function(plot, x_position, y_position, scale_value) {
  ggdraw() +
    draw_image(nscr_logo, x = x_position, y = y_position , scale = scale_value) + 
    draw_plot(plot)
}

# Kleuren definieren
NSCR_main<- NSCR_main <- c("#B81E61")

NSCR_lighter <- c("#B81E61", "#C64A80", "#D478A0", "#E2A5BF", "#F0D2DF"
)

NSCR_two <- c("#4D7275", "#FED79D")

NSCR_three <- c("#4D7275", "#FED79D", "#DD5A5A")

NSCR_six <- c("#4D7275", "#FED79D", "#DD5A5A", "#7B0038", "#718F91", "#AF3262")

NSCR_font <- c("#414141")