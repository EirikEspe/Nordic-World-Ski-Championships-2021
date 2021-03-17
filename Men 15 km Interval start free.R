#####################################################
#
# FIS Nordic World Ski Championship 
# 
# Oberstdorf 2021 15.0 km Interval Start Free
#
#####################################################

# Calling on libraries
library(readr)
library(lubridate)
library(ggplot2)
library(dplyr)
library(ggrepel)


# Load the data
individual15km <- readr::read_csv2("Results_15km_Oberstdorf_2021.csv")


# Look at data types
sapply(individual15km, class)


# Convert to time and date format
individual15km <- individual15km %>% 
  mutate(across(contains("time"), ms),
         Born = dmy(Born))


# Convert dataframe to long format
individual15km <- individual15km %>% 
  select(-Start_time) %>% 
  # Rename 'Finish_Time' column, in order to make it easier to convert to long format
  rename(Time_Finish = Finish_time) %>% 
  # Convert to long format
  tidyr::pivot_longer(cols = matches("^time|rank"),
                      names_to = c(".value", "Dist"), 
                      names_sep = "_") %>% 
  relocate(any_of(c("Dist", "Rank", "Time")))


# Make Dist column a factor, in order to control order of levels
individual15km$Dist <- factor(individual15km$Dist, 
                              levels = c("1.8km", "6.6km", "10.0km", "12.9km", "Finish"))


# Order dataframe by name/rank and chronological order of distance
individual15km <- individual15km %>% arrange(match(Name, Name), Dist)


# Create a variable for interim distance and time, and a variable for segment speed
individual15km <- individual15km %>% 
  mutate(Int_dist = case_when(Dist == "1.8km" ~ 1.8,
                              Dist == "6.6km" ~ 4.8,
                              Dist == "10.0km" ~ 3.4,
                              Dist == "12.9km" ~ 2.9,
                              Dist == "Finish" ~ 2.1),
         Int_time = case_when(Dist == "1.8km" ~ Time,
                              TRUE ~ Time - lag(Time)),
         # Roll smaller units over to higher units if they exceed conventional time
         # (Fixing negative seconds), using the roll parameter
         Int_time = ms(as.character(Int_time), roll = TRUE),
         # Speed in km/h
         Speed = Int_dist / (as.numeric(Int_time) / (60 * 60)),
         .after = Time)


# Create a table with names of top 5 skiers to annotate the plot
plot_table <- individual15km %>% filter(Dist == "Finish") %>% 
  select(Dist, Rank, Name) %>% 
  slice_min(Rank, n = 5) %>% 
  mutate(Speed = seq(24, 22, by = -0.5),
         Time = ms("34:00"))

# Title for the table
table_title <- individual15km %>% filter(Dist == "Finish") %>% 
  select(Dist) %>%
  slice(1) %>% 
  mutate(Speed = 24.5, Time = ms("33:50"))

# Dataframe - rectangle background for the table
rectangle <- individual15km %>% filter(Dist == "Finish") %>% 
  select(Dist) %>% slice(1) %>% 
  mutate(xmin = ms("33:45"), xmax = ms("35:15"), ymin = 21.5, ymax = 25)


# Plot fastest segment speeds
individual15km %>% group_by(Dist) %>% slice_max(Speed, n = 5) %>% ungroup() %>%   
  
  ggplot(aes(x = Time, y = Speed)) +
  geom_point(aes(colour = Name), alpha = 0.7, show.legend = FALSE) +
  # Add names to the points
  geom_text_repel(aes(label = stringr::str_wrap(Name, width = 10), x = Time, y = Speed,
                      segment.colour = Name),
                  size = 1.8, seed = 142, min.segment.length = 0.3,
                  lineheight = 1.1, show.legend = FALSE) +
  ## Add a table with final results in the last panel
  # Background for the table
  geom_rect(data = rectangle, aes(xmin = xmin, xmax = xmax, 
                                  ymin = ymin, ymax = ymax), 
            fill = "ghostwhite", inherit.aes = FALSE) +
  # Name of the top 5 overall for this race
  geom_text(data = plot_table, aes(label = paste0(Rank, ". ", Name)), 
            size = 2.1, hjust = 0) +
  # Title for the table
  geom_text(data = table_title, label = "Results", size = 2.8, 
            hjust = 0, fontface = "bold") +
  facet_grid(~ Dist, scales = "free_x") +
  scale_x_time(guide = guide_axis(n.dodge = 2)) +
  scale_colour_discrete(aesthetics = c("colour", "segment.colour")) +
  labs(title = "Top 5 segment speed, Men 15 km Interval Start Oberstdorf 2021",
       subtitle = "Average speed measured between checkpoint and previous checkpoint",
       x = "Race time", y = "Speed (km/h)") +
  theme_light() +
  theme(axis.text.x = element_text(size = rel(0.7)),
        axis.text.y = element_text(size = rel(0.9)))



