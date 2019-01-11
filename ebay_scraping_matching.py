#Import libraries
from selenium import webdriver
import pandas as pd
import numpy as np

#Initial Setup
chrome_path = r"C:\Users\Kyria\Desktop\Coding\Projects\2019\Web Scraping\chromedriver.exe"
driver = webdriver.Chrome(chrome_path)
base_url = "https://www.ebay.com/sch/i.html?_from=R40&_nkw=switch+mario+games&_sacat=0&rt=nc&_pgn="
frames = list()
page_number = 5

#Get the names of the products
names = list()
for i in range(1,page_number+1):
    url = base_url + str(i)
    driver.get(url)
    names_content = driver.find_elements_by_class_name("s-item__title")
    for name in names_content:
        names.append(((name.text).replace("SPONSORED\n", "")).replace("NEW LISTING", ""))
driver.close()

#An exhaustive list of switch mario games
mario_games = ["Mario Kart 8 Deluxe",
               "Super Mario Odyssey ",
               "Mario + Rabbids Kingdom Battle",
               "Mario Tennis Aces",
               "Captain Toad: Treasure Tracker",
               "Super Smash Bros. Ultimate",
               "Super Mario Party",
               "New Super Mario Bros U Deluxe",
               "Yoshi",
               "Luigi's Mansion 3 "]

#Match the products scraped against the offical names (similarity analysis)
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics.pairwise import euclidean_distances
vectorizer = CountVectorizer()
features = vectorizer.fit_transform(mario_games+names).todense()
col_n = len(mario_games)
row_n = len(names)
df = pd.DataFrame(index=names, columns=mario_games)
for i in range(col_n):
    for j in range(10,len(features)):
        df.at[names[j-10], mario_games[i]] = float(euclidean_distances(features[i], features[j]))
df.to_csv("Output.csv")