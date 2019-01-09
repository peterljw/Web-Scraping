#Import required libraries

#---------------------------------------Using RSelenium---------------------------------------

library(RSelenium)
require(RSelenium)

#Initial Setup
driver <- rsDriver()
remDr <- driver[["client"]]
remDr$getStatus

#Navigate to a specific url
remDr$navigate("http://usjus.org/programs/")

#Select classes of all courses
webElem <- remDr$findElements(using = 'css selector', ".portelement")
info <- sapply(webElem, function(x){
  
  #Retrieve the title of the course
  title <- x$findChildElement(using = 'css selector', ".title")
  
  #Retrieve the description box and obtain the price as the second headline3 in the box
  info_box <- x$findChildElement(using = 'css selector', ".description-block_2")
  price <- info_box$findChildElements(using = 'tag name', "h1")[[2]]
  
  #Combine title and price info into a column
  cbind(c("title" = title$getElementText(), "price" = price$getElementText()))
})

#Output a table of course info
course_info <- as.data.frame(t(info))
course_info

remDr$close()
driver$server$stop()

#---------------------------------------Using rvest---------------------------------------

#Import required libraries
library(rvest)
library(dplyr)
library(imager)
library(magick)

url <- read_html('http://usjus.org/programs/')

#Retrieve course titles
title <- url %>%
  html_nodes(".default-block_2") %>%
  html_nodes(".title") %>%
  html_text()

#Retrieve course prices
price <- url %>%
  html_nodes(".portelement") %>%
  html_nodes("h1") %>%
  html_text()
#Remove non-price entries from h1's
price <- price[c(seq(2, length(price), 2))]

images <- url %>%
  html_nodes(".default-block_2") %>%
  html_nodes("img") %>%
  html_attr('src')

pic <- list()
for(i in 1:length(images)){
  url <- images[[i]]
  pic[[i]] <- load.image(url)
}
  
course_info <- data.frame(cbind("Course Title"=title,"Price"=price,"Image URL"=images))
write.csv(course_info, file = "USJ Course Info.csv")

#Saving the output to a SQL server
# library(RODBC)
# connection <- odbcDriverConnect(
#   driver = {server} 
#   server = name
#   database = name
#   trusted_connection = true;
# )
# sqlSave(connection, course_info, tablename = "USJ Courses", rownames = F)
# odbcClose(connection)
