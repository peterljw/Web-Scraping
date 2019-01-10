#Import libraries
from selenium import webdriver
import pandas as pd
import numpy as np

#Initial Setup
chrome_path = r"C:\Users\Kyria\Desktop\chromedriver.exe"
driver = webdriver.Chrome(chrome_path)
base_url = "https://store.steampowered.com/search/?sort_by=Reviews_DESC&filter=topsellers&page="
frames = list()
page_number = 8

for i in range(1,page_number+1):
    url = base_url + str(i)
    driver.get(url)
    names_content = driver.find_elements_by_class_name("title")
    ratings_content = driver.find_elements_by_class_name("positive")
    prices_content = driver.find_elements_by_css_selector(".col.search_price.responsive_secondrow")
    names = list()
    for name in names_content:
        names.append(name.text)
    ratings = list()
    for rating in ratings_content:
        ratings.append(rating.get_attribute("data-tooltip-html"))
    percent_rating = list()
    user_number = list()
    for rating in ratings:
        percent_rating.append(rating.split("<br>", 1)[1][0:3])
        user_number.append(rating.split(" user", 1)[0].split("the ")[1])
    prices = list()
    for price in prices_content:
        prices.append(price.text)
    df_new = np.array([names, percent_rating, user_number, prices])
    info = pd.DataFrame(data=df_new.transpose(), columns=["Game", "Rating", "Number of Reviews", "Price"])
    frames.append(info)

info_df = pd.concat(frames)

info_df.to_csv("Steam Info.csv", index=False)
driver.close()
