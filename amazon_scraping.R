#Import required libraries
library(RSelenium)
library(rvest)
library(dplyr)
require(RSelenium)

#Initial Setup
driver <- rsDriver()
remDr <- driver$client
remDr$getStatus

#A function that returns the titles and the prices of the items from the given page
get_info <- function(link){
  info_box <- link %>%
    html_nodes(".a-fixed-left-grid-inner")
  title <- info_box %>%
    html_nodes(".a-size-medium") %>%
    html_text()
  price <- info_box %>%
    html_nodes(".sx-price-whole") %>%
    html_text()
  d <- data.frame(title, price)
}

#A function that clicks on next page and returns the page
next_page <- function(remDr){
  next_button <- remDr$findElement(using = 'id', 'pagnNextString')
  next_button$clickElement()
  new_link <- read_html(remDr$getPageSource()[[1]])
  return(new_link)
}

#A function that returns a table of titles and prices based on the given search term and the numbers of pages to be scraped
scrape_amazon <- function(product, page_number, remDr){
  url <- "https://www.amazon.com/"
  remDr$navigate(url)
  
  webElem1 <- remDr$findElement(using = 'xpath', '//*[(@id = "twotabsearchtextbox")]')
  product_name <- product
  webElem1$sendKeysToElement(list(product_name, key="enter"))
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

#---------------Scraping time!---------------

dining_table_info <- scrape_amazon("dining table", 1, remDr)
necklace_info <- scrape_amazon("necklace", 2, remDr)
microphone_info <- scrape_amazon("microphone", 5, remDr)

products <- c("xbox", "nintendo switch", "play station")
products_info <- list()
for(item in products){
  d <- scrape_amazon(item, 20, remDr)
  products_info[[item]] <- d
}

remDr$close()
driver$server$stop()
