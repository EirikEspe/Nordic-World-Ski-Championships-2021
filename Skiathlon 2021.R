#####################################################
#
# FIS Nordic World Ski Championship 
# 
# Oberstdorf 2021 Skiathlon
#
#####################################################

# Calling on libraries
library(readr)
library(lubridate)
library(ggplot2)
library(dplyr)


# Load the data
skiathlon <- readr::read_csv2("Results_Skiathlon_Oberstdorf_2021.csv")


# Look at data types
sapply(skiathlon, class)


# Formatting of columns (time and date), and add data for start of race
skiathlon <- skiathlon %>% mutate(across(matches("Time_[[:digit:]][^6]"), ms),
                                  across(c(Time_26.3km, Time_Finish), hms),
                                  Born = dmy(Born),
                                  Time_Start = seconds(0),
                                  Rank_Start = BIB) %>%
  # Rename 'Rank' column, in order to make it easier to convert to long format
  rename(Rank_Finish = Rank) %>% 
  # Convert to long format
  tidyr::pivot_longer(cols = matches("^time|rank"),
                      names_to = c(".value", "Dist"), 
                      names_sep = "_") %>% 
  relocate(any_of(c("Dist", "Rank", "Time")))


# Top 15 skiers
top_names <- skiathlon %>% filter(Dist == "Finish") %>% 
  slice_min(Time, n = 10) %>% pull(Name)


# Plot
skiathlon %>% filter(Name %in% top_names) %>%  
  ggplot(aes(x = Time, y = Rank, colour = Nation, group = Name)) +
  geom_vline(xintercept = hms("00:35:55"), linetype = "dashed", size = 0.2) +
  geom_point(show.legend = FALSE) + geom_line(size = 0.2, show.legend = FALSE) + 
  geom_text(data = skiathlon %>% filter(Dist == "Finish" & Name %in% top_names), 
            aes(label = Name, x = Time + minutes(1), y = Rank, colour = Nation),
            size = 2, hjust = 0, show.legend = FALSE) +
  scale_x_time(limits = c(hms("00:00:00"), hms("1:25:00"))) + 
  scale_y_reverse(breaks = c(1, 5, 10, 15, 20, 25),
                  expand = expansion(mult = c(0.05, 0.02))) +
  labs(title = "Timing Skiathlon - Oberstdorf 2020", 
       x = "Race time", y = "Rank") +
  annotate(geom = "segment", x = 0, xend = hms("00:13:00"), y = 29, yend = 29,
           arrow = arrow(length = unit(0.2, "cm"), ends = "first"), size = 0.8) +
  annotate(geom = "text", x = hms("00:17:00"), y = 29, label = "15 km\nclassic",
           lineheight = 0.8) +
  annotate(geom = "segment", x = hms("00:21:00"), xend = hms("00:35:45"), 
           y = 29, yend = 29, arrow = arrow(length = unit(0.2, "cm"), ends = "last"),
           size = 0.8) +
  annotate(geom = "segment", x = hms("00:36:05"), xend = hms("00:50:00"),
           y = 29, yend = 29, arrow = arrow(length = unit(0.2, "cm"), ends = "first"),
           size = 0.8) +
  annotate(geom = "text", x = hms("00:55:00"), y = 29, label = "15 km\nfreestyle",
           lineheight = 0.8) +
  annotate(geom = "segment", x = hms("1:00:00"), xend = hms("1:11:30"),
           y = 29, yend = 29, arrow = arrow(length = unit(0.2, "cm"), ends = "last"),
           size = 0.8) +
  annotate(geom = "text", x = hms("00:35:00"), y = 22.5, label = "Change of skis",
           size = 3, angle = 90) +
  annotate(geom = "text", x = c(hms("00:00:00"), hms("00:12:23.1"), hms("00:23:24.6"), 
                                hms("00:35:48"), hms("00:48:37"), hms("1:2:53.2"), 
                                hms("1:11:33.9")), 
           y = -0.5, label = c("Start", "5.1 km", "9.7 km", "15 km", 
                               "20 km", "26.3 km", "Finish"), size = 2) +
  theme_light()


# Create the same plot, but highlight the top 3 skiers
skiathlon %>% filter(Name %in% top_names) %>%  
  ggplot(aes(x = Time, y = Rank, group = Name)) +
  geom_vline(xintercept = hms("00:35:55"), linetype = "dashed", size = 0.2) +
  # Background grey points
  geom_point(colour = "grey", alpha = 0.7) + 
  geom_line(colour = "grey", alpha = 0.7, size = 0.2) +
  # Top 3 colour points
  geom_point(data = skiathlon %>% filter(Name %in% top_names[1:3]), 
             aes(colour = Name), show.legend = FALSE) +
  geom_line(data = skiathlon %>% filter(Name %in% top_names[1:3]),
            aes(colour = Name), size = 0.2, show.legend = FALSE) +
  geom_text(data = skiathlon %>% filter(Dist == "Finish" & Name %in% top_names), 
            aes(label = Name, x = Time + minutes(1), y = Rank),
            colour = c("#F8766D", "#619CFF", "#00BA38", rep("grey", 7)),
            size = 2, hjust = 0, show.legend = FALSE) +
  scale_x_time(limits = c(hms("00:00:00"), hms("1:25:00"))) + 
  scale_y_reverse(breaks = c(1, 5, 10, 15, 20, 25),
                  expand = expansion(mult = c(0.05, 0.02))) +
  labs(title = "Split-timing top 10 skiers - Skiathlon Oberstdorf 2021", 
       x = "Race time", y = "Rank") +
  # Annotate arrows
  annotate(geom = "segment", x = 0, xend = hms("00:13:00"), y = 29, yend = 29,
           arrow = arrow(length = unit(0.2, "cm"), ends = "first"), size = 0.8) +
  annotate(geom = "text", x = hms("00:17:00"), y = 29, label = "15 km\nclassic",
           lineheight = 0.8, size = 3.7) +
  annotate(geom = "segment", x = hms("00:21:00"), xend = hms("00:35:40"), 
           y = 29, yend = 29, arrow = arrow(length = unit(0.2, "cm"), ends = "last"),
           size = 0.8) +
  annotate(geom = "segment", x = hms("00:36:10"), xend = hms("00:50:00"),
           y = 29, yend = 29, arrow = arrow(length = unit(0.2, "cm"), ends = "first"),
           size = 0.8) +
  annotate(geom = "text", x = hms("00:55:00"), y = 29, label = "15 km\nfreestyle",
           lineheight = 0.8, size = 3.7) +
  annotate(geom = "segment", x = hms("1:00:00"), xend = hms("1:11:30"),
           y = 29, yend = 29, arrow = arrow(length = unit(0.2, "cm"), ends = "last"),
           size = 0.8) +
  annotate(geom = "text", x = hms("00:35:00"), y = 22.5, label = "Change of skis",
           size = 3, angle = 90) +
  annotate(geom = "text", x = c(hms("00:00:00"), hms("00:12:23.1"), hms("00:23:24.6"), 
                                hms("00:35:48"), hms("00:48:37"), hms("1:2:53.2"), 
                                hms("1:11:33.9")), 
           y = -0.5, label = c("Start", "5.1 km", "9.7 km", "15 km", 
                               "20 km", "26.3 km", "Finish"), size = 2) +
  theme_light()