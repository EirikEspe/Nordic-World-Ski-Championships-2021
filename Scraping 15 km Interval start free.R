#####################################################
#
# FIS Nordic World Ski Championship 
# 
# Oberstdorf 2021 15.0 km Interval Start Free
# Scraping the data
#
#####################################################

# Calling on libraries
library(rvest)
library(httr)
library(lubridate)
library(purrr)
library(dplyr)


# URL we want to scrape
url <- paste0("https://www.fis-ski.com/DB/general/results.html?",
              "sectorcode=CC&raceid=36554#details")


# Scrape name of winner
read_html(url) %>% 
  html_element("#events-info-results div:nth-child(4)") %>% 
  html_text(trim = TRUE)


# Create a dataframe with information and results from the 15km
results <- tibble(
  
  Final_rank = read_html(url) %>% 
    html_elements("#events-info-results div.justify-right.pr-1.bold") %>%
    html_text() %>% as.numeric(),
  
  BIB = read_html(url) %>% 
    html_elements("#events-info-results div:nth-child(2)") %>%
    html_text() %>% as.numeric(),
  
  FIS_code = read_html(url) %>% 
    html_elements("#events-info-results div:nth-child(3)") %>% 
    html_text() %>% as.numeric(),
  
  Name = read_html(url) %>% 
    html_elements("#events-info-results div.justify-left.bold") %>% 
    html_text(trim = TRUE))


# Urls for athlete information
athlete_urls <- read_html(url) %>% 
  html_elements("#events-info-results a") %>% 
  html_attr("href")


# Function to collect athlete information
get_athlete_info <- function(url) {
  athlete <- tibble(
    # Paste results of code for scraping last name and results for scraping first name
    Name = paste(read_html(url) %>% 
                   html_element(xpath = '//*[@id="content"]/div[1]/div/div[1]/h1/span') %>% 
                   html_text(),
                 
                 read_html(url) %>%
                   html_element(xpath = '//*[@id="content"]/div[1]/div/div[1]/h1/text()') %>% 
                   html_text(trim = TRUE)),
    
    Nation = read_html(url) %>% 
      html_element("span.country__name-short") %>% 
      html_text(),
    
    Club = read_html(url) %>% 
      html_element("div.athlete-profile__team.spacer__section") %>%
      html_text(), 
    
    Born = read_html(url) %>% 
      html_element("#Birthdate > span.profile-info__value") %>% 
      html_text() %>% dmy()
    )
}

# Testing the function on the five first urls
purrr::map_dfr(athlete_urls[1:5], get_athlete_info) %>% View("functiontest")


# Now lets create an iteration for all the urls, adding a delay for each 
# function call to avoid bot detection
athlete <- purrr::map_dfr(athlete_urls, 
                          purrr::slowly(get_athlete_info, purrr::rate_delay(3)))


# We got some missing data from the web scrape, where the desired data cannot be
# found in the url
athlete %>% filter(if_any(everything(), ~ is.na(.)))

# Find index of rows where we have missing values
which(is.na(athlete$Born))

# Use information from the official results to fill the values
athlete[86,] <- list("OGNYANOV Aleksandar", "BUL", "ASK Aleksandar Logistiks", 
                     dmy("25 JUN 2002"))
athlete$Born[[97]] <- dmy("13 DEC 2003")


#--- Retrieve interim times for the skiers ----

## Url to get the information (Url found in Chrome Developer Tools -> Network tab -> 
## filter requests to 'XHR')
timing_url <- paste0("https://data.fis-ski.com/fis_events/ajax/raceresultsfunctions/",
                     "details.html?sectorcode=CC&raceid=36554&competitors=")

## Make the request
r <- httr::GET(timing_url)
## Check status and content
httr::http_status(r)
httr::headers(r)
## content-type: "text/html; charset=UTF-8"


# Retrieve contents from the request
timing_content <- httr::content(r, type = "text/html", encoding = "UTF-8")


# Create a dataframe with the interim timing
timing <- tibble(
  Name = timing_content %>% 
    html_elements(xpath = '//*[@id="events-info-results"]/div/a/div/div[1]/div[3]') %>% 
    html_text(),
  
  Time_1.8km = timing_content %>% 
    html_elements(xpath = '//*[@id="events-info-results"]/div/a/div/div[2]/div[2]/div[2]/div[1]/div[1]') %>% 
    html_text() %>% ms(),
  
  Rank_1.8km = timing_content %>% 
    html_elements(xpath = '//*[@id="events-info-results"]/div/a/div/div[2]/div[2]/div[2]/div[1]/div[3]') %>% 
    html_text() %>% as.numeric(),
  
  Time_6.6km = timing_content %>% 
    html_elements(xpath = '//*[@id="events-info-results"]/div/a/div/div[2]/div[5]/div[2]/div[1]/div[1]') %>% 
    html_text() %>% ms(),
  
  Rank_6.6km = timing_content %>% 
    html_elements(xpath = '//*[@id="events-info-results"]/div/a/div/div[2]/div[5]/div[2]/div[1]/div[3]') %>% 
    html_text() %>% as.numeric(),
  
  Time_10.0km = timing_content %>% 
    html_elements(xpath = '//*[@id="events-info-results"]/div/a/div/div[3]/div[3]/div[2]/div[1]/div[1]') %>% 
    html_text() %>% ms(),
  
  Rank_10.0km = timing_content %>% 
    html_elements(xpath = '//*[@id="events-info-results"]/div/a/div/div[3]/div[3]/div[2]/div[1]/div[3]') %>% 
    html_text() %>% as.numeric(),
  
  Time_12.9km = timing_content %>% 
    html_elements(xpath = '//*[@id="events-info-results"]/div/a/div/div[3]/div[5]/div[2]/div[1]/div[1]') %>% 
    html_text() %>% ms(),
  
  Rank_12.9km = timing_content %>% 
    html_elements(xpath = '//*[@id="events-info-results"]/div/a/div/div[3]/div[5]/div[2]/div[1]/div[3]') %>%
    html_text() %>% as.numeric(),
  
  Time_Finish = timing_content %>% 
    html_elements(xpath = '//*[@id="events-info-results"]/div/a/div/div[3]/div[6]/div[2]/div[1]/div[1]') %>% 
    html_text() %>% ms()
)


# Join results table, athlete table and timing table
results <- results %>% 
  inner_join(athlete, by = "Name") %>% 
  inner_join(timing, by = "Name")
