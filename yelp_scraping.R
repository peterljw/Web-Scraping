#Import required libraries
library(RSelenium)
library(rvest)
library(dplyr)
require(RSelenium)
library(stringr)

#Initial Setup
driver <- rsDriver()
remDr <- driver$client
remDr$getStatus

#Extract numbers from a string
numextract <- function(string){ 
  str_extract(string, "\\-*\\d+\\.*\\d*")
} 

#A function that returns the names and the ratings of the restaurants from the given page
get_info <- function(link){
  info_box <- link %>%
    html_nodes(".domtags--ul__373c0__3EAkl")
  name <- info_box %>%
    html_nodes(".link-size--inherit__373c0__2JXk5") %>%
    html_text()
  name <- name[name!="read more"]
  
  rating <- info_box %>%
    html_nodes(".overflow--hidden__373c0__8Jq2I") %>%
    html_attr("aria-label")
  rating <- as.numeric(numextract(rating))
  d <- data.frame(name, rating)
}

#A function that clicks on next page and returns the page
next_page <- function(remDr){
  Sys.sleep(1)
  next_button <- remDr$findElement(using = 'xpath', '//*[contains(concat( " ", @class, " " ), concat( " ", "navigation-button-icon__373c0__1hC4a", " " ))]')
  next_button$clickElement()
  new_link <- read_html(remDr$getPageSource()[[1]])
  return(new_link)
}

scrape_yelp <- function(food, location, page_number, remDr){
  url <- "https://www.yelp.com/"
  remDr$navigate(url)
  webElem1 <- remDr$findElement(using = 'xpath', "//*[(@id = 'find_desc')]")
  webElem2 <- remDr$findElement(using = 'xpath', "//*[(@id = 'dropperText_Mast')]")
  webElem1$sendKeysToElement(list(food))
  webElem2$clickElement()
  webElem2$sendKeysToElement(list(location, key="enter"))
  hlink <- read_html(remDr$getPageSource()[[1]])
  
  info_d <- data.frame()
  for(i in 1:page_number){
    Sys.sleep(5)
    d <- get_info(hlink)
    info_d <- rbind(info_d, d)
    hlink <- next_page(remDr)
  }
  return(info_d)
}

food <- "ramen"
locations <- c("San Jose, CA", "Los Angeles, CA", "San Diego, CA")
info_list <- list()
for(place in locations){
  info_list[[place]] <- scrape_yelp(food, place, 2, remDr)
  Sys.sleep(2)
}

#Visualization of ratings across the three cities
library(ggplot2)
SJ_rating <- info_list[[1]]$rating
SJ <- data.frame("City"= rep("San Jose", length(SJ_rating)), "Rating" = SJ_rating)
LA_rating <- info_list[[2]]$rating
LA <- data.frame("City"= rep("Los Angeles", length(LA_rating)), "Rating" = LA_rating)
SD_rating <- info_list[[3]]$rating
SD <- data.frame("City"= rep("San Diego", length(SD_rating)), "Rating" = SD_rating)
df <- rbind(SJ,LA,SD)
ggplot(df, aes(x=Rating, fill=City)) +
  geom_histogram(binwidth=0.15, position="dodge")


remDr$close()
driver$server$stop()
