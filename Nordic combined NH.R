#####################################################
#
# FIS Nordic World Ski Championship 
# 
# Nordic Combined Normal Hill / 10.0 km
# Oberstdorf 2021
#
#####################################################

# Calling on libraries
library(readr)
library(lubridate)
library(ggplot2)
library(dplyr)


# Load the data
nordic_combined <- readr::read_csv2("nordic_CombinedNH.csv",
                                    col_types = cols(
                                      Time_diff = col_character()
                                      ))

# Convert data types
nordic_combined <- nordic_combined %>% 
  mutate(Born = dmy(Born),
         across(c(Time_diff, Time), ms))

# Add a column for start time and convert to long format
nordic_combined2 <-  nordic_combined %>% 
  mutate(Start_Time = -Time_diff) %>%
  rename(Finish_Time = Time) %>%
  tidyr::pivot_longer(cols = c(Start_Time, Finish_Time),
                      names_to = c("Boundary", ".value"),
                      names_sep = "_") %>%
  mutate(Final_rank = case_when(Boundary == "Start" ~ Points_rank,
                                TRUE ~ Final_rank))

# Set time at finish to total time
nordic_combined2$Time[nordic_combined2$Boundary == "Finish"] <- ms(as.character(
  nordic_combined2$Time[nordic_combined2$Boundary == "Finish"] + 
    nordic_combined2$Time_diff[nordic_combined2$Boundary == "Finish"]
  ), roll = TRUE)


# Name of top 10
top10 <- nordic_combined2 %>% filter(Boundary == "Finish") %>% 
  slice_min(Final_rank, n = 10) %>% pull(Name)


# Plot ski jump, including top 10 overall, and winner of the ski jump
nordic_combined %>% filter(Name %in% top10 | Points_rank == 1) %>%
  ggplot(aes(x = Points, y = Points_rank)) + 
  geom_text(aes(label = Name, x = Points + 1), 
            colour = c("#619CFF", "#F8766D", "#00BA38", rep("black", 8)), 
            size = 2, hjust = 0) + 
  geom_curve(x = 50, y = 50, xend = 137.6, yend = 1, curvature = -0.25) + 
  scale_x_continuous(limits = c(40, 160)) + 
  scale_y_continuous(breaks = c(1, 10, 20, 30, 40, 50), limits = c(1, 50)) + 
  labs(title = "Ski jump Nordic Combined normal hill - Oberstdorf 2021",
       x = "Points awarded", y = "Rank") + 
  theme_light()


# Plot cross-country skiing
nordic_combined2 %>% filter(Name %in% top10 | Points_rank == 1) %>% 
  ggplot(aes(x = Time, y = Final_rank, group = Name)) +
  geom_vline(xintercept = c(seconds(0), ms("23:01.2")), 
             linetype = "dashed", size = 0.3) +
  # Background grey points
  geom_point(colour = "grey", alpha = 0.7) + 
  geom_line(colour = "grey", alpha = 0.7) +
  # Top 3 colour points
  geom_point(data = nordic_combined2 %>% filter(Name %in% top10[1:3]), 
             aes(colour = Name), show.legend = FALSE) +
  geom_line(data = nordic_combined2 %>% filter(Name %in% top10[1:3]),
            aes(colour = Name), show.legend = FALSE) +
  geom_text(data = nordic_combined2 %>% 
              filter(Boundary == "Finish" & (Name %in% top10 | Points_rank == 1)), 
            aes(label = Name, x = Time + seconds(30), y = Final_rank),
            colour = c("#619CFF", "#F8766D", "#00BA38", rep("grey", 8)),
            size = 2, hjust = 0, show.legend = FALSE) +
  scale_x_time() +
  scale_y_reverse(breaks = c(1, 5, 10, 15, 20)) +
  expand_limits(x = ms("27:00")) +
  annotate(geom = "text", x = -ms("00:30"), y = 17.5, label = "Start", angle = 90,
           size = 3.5) +
  annotate(geom = "text", x = ms("23:31.2"), y = 17.5, label = "Finish", angle = 270,
           size = 3.5) +
  labs(title = "Nordic combined cross-country race 10 km - Oberstdorf 2021",
       x = "Race time", y = "Rank", 
       caption = paste("The winner of the ski jump starts at 00:00:00 and all", 
                       "other athletes\nstart with time disadvantages according", 
                       "to their jumping score.")) +
  theme_light()


# Combined plot (similar to the plots above, but with adjustment of scales)
p1 <- nordic_combined %>% filter(Name %in% top10 | Points_rank == 1) %>%
  ggplot(aes(x = Points, y = Points_rank)) + 
  geom_text(aes(label = Name, x = Points + 5), 
            colour = c("#619CFF", "#F8766D", "#00BA38", rep("black", 8)), 
            size = 2, hjust = 0) + 
  geom_curve(x = 50, y = 40, xend = 137.6, yend = 1, curvature = -0.25) + 
  scale_x_continuous(breaks = c(50, 100, 150), limits = c(40, 180)) + 
  scale_y_continuous(breaks = c(1, 10, 20, 30, 40, 50), limits = c(1, 42)) + 
  labs(subtitle = "Ski jump - Normal hill",
       x = "Points awarded", y = "Rank") + 
  theme_light()


# Cross country skiing plot
p2 <- nordic_combined2 %>% filter(Name %in% top10 | Points_rank == 1) %>% 
  ggplot(aes(x = Time, y = Final_rank, group = Name)) +
  geom_vline(xintercept = c(seconds(0), ms("23:01.2")), 
             linetype = "dashed", size = 0.3) +
  # Background grey points
  geom_point(colour = "grey", alpha = 0.7) + 
  geom_line(colour = "grey", alpha = 0.7) +
  # Top 3 colour points
  geom_point(data = nordic_combined2 %>% filter(Name %in% top10[1:3]), 
             aes(colour = Name), show.legend = FALSE) +
  geom_line(data = nordic_combined2 %>% filter(Name %in% top10[1:3]),
            aes(colour = Name), show.legend = FALSE) +
  geom_text(data = nordic_combined2 %>% 
              filter(Boundary == "Finish" & (Name %in% top10 | Points_rank == 1)), 
            aes(label = Name, x = Time + seconds(30), y = Final_rank),
            colour = c("#619CFF", "#F8766D", "#00BA38", rep("grey", 8)),
            size = 2, hjust = 0, show.legend = FALSE) +
  scale_x_time() +
  scale_y_reverse(breaks = c(1, 5, 10, 15, 20)) +
  expand_limits(x = ms("32:00")) +
  annotate(geom = "text", x = -ms("00:30"), y = 17.5, label = "Start", angle = 90,
           size = 3.5) +
  annotate(geom = "text", x = ms("23:31.2"), y = 17.5, label = "Finish", angle = 270,
           size = 3.5) +
  labs(subtitle = "Cross-country skiing 10 km",
       x = "Race time", y = "Rank") +
  theme_light()


# Using the patchwork package  to combine the plots
library(patchwork)
p1 + p2 + 
  plot_annotation(title = "Nordics combined in Oberstdorf 2021", 
                  caption = paste("The winner of the ski jump starts at 00:00:00", 
                                  "and all other athletes\nstart with time", 
                                  "disadvantages according to their jumping score."))