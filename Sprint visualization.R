#####################################################
#
# FIS Nordic World Ski Championship 
# 
# Oberstdorf 2021 Sprint
# 
#####################################################

# Calling on libraries
library(readr)
library(lubridate)
library(ggplot2)
library(dplyr)


# Load results for sprint
sprint <- read.csv2("Results_Sprint_Oberstdorf_2021.csv")

# Convert Time column from character to time by replacing ',' as decimal separator,
# with '.', and using the ms() function from lubridate
sprint$Time <- ms(sub(pattern = ",", replacement = ".", sprint$Time))


# Create a factor of Stage column to control order of levels
sprint$Stage <- factor(sprint$Stage, 
                       levels = c("Qualification", "Quarterfinal 1", "Quarterfinal 2",
                                  "Quarterfinal 3", "Quarterfinal 4", "Quarterfinal 5",
                                  "Semifinal 1", "Semifinal 2", "Final"))


# Create a column indicating whether the skier is from Norway
sprint <- sprint %>% 
  mutate(Nationality = case_when(Nation == "NOR" ~ "Norwegian",
                                 TRUE ~ "Other"))


# Create a function to determine breaks for the plot
# (I want the y-axis for the Qualification panel to be [1, 10, 20, 30] instead of
# [0, 10, 20, 30], and for the others [1, 3, 5] instead of [2, 4, 6])
my_breaks <- function(x) {
  if (max(x) > 20) {
    c(1, 10, 20, 30)
  } else {
    c(1, 3, 5)
  }
}

# Plot
sprint %>% ggplot(aes(x = Time, y = Stage_rank)) + 
  geom_point(aes(colour = Nationality), alpha = 0.6) +
  geom_text(data = sprint %>% filter(Nation == "NOR" | Stage_rank == 1), 
            aes(label = Name, x = Time, y = Stage_rank),
            size = 2, hjust = 0, nudge_x = 1) +
  facet_wrap(~Stage, scales = "free_y") + 
  scale_x_time() + scale_y_reverse(breaks = my_breaks) +
  scale_colour_manual(values = c("#E62F2F", "lightskyblue4")) +
  labs(title = "Norwegian performance - Sprint Oberstdorf 2021", 
       x = "Race time", y = "Stage rank") +
  theme_light()