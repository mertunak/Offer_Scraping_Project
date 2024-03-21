import requests
import pandas as pd
from bs4 import BeautifulSoup
import re
import firebase_operations
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time

header = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/119.0.0.0 Safari/537.36"
}

def findOfferTab(baseUrl, header):
    baseWithoutHttps = baseUrl.split(":")[-1]
    
    httpRequest = requests.get(baseUrl, headers=header)
    parsedHomeHtml = BeautifulSoup(httpRequest.text, "lxml")
    
    isDynamic = False if parsedHomeHtml.find("div") else True
    if isDynamic:
        chrome_options = Options()
        chrome_options.add_argument("webdriver.chrome.driver=backend/chromedriver.exe")
        driver = webdriver.Chrome(options=chrome_options)
        driver.get(baseUrl)
        time.sleep(5)
        parsedHomeHtml = BeautifulSoup(driver.page_source, "html.parser")
        driver.quit()

    offerPageTagList = parsedHomeHtml.find_all(
        "a", href=re.compile("kampanya", re.I))

    offerPageLinkList = []
    for iterTag in offerPageTagList:
        offerPageLinkList.append(iterTag.get("href"))

    offerPageLink = ""
    for iterPageLink in offerPageLinkList:
        if offerPageLink == "":
            offerPageLink = iterPageLink
        else:
            if len(iterPageLink) < len(offerPageLink):
                offerPageLink = iterPageLink
    
    if offerPageLink:
        if baseWithoutHttps in offerPageLink:
            if "https:" not in offerPageLink:
                offerPageLink = "https:" + offerPageLink
        else:
            offerPageLink = baseUrl + offerPageLink
            
        return offerPageLink
    else:
        return ""

# is_bank = "https://www.isbank.com.tr"
# bellona = "https://www.bellona.com.tr"
# migros = "https://www.migros.com.tr"
# media = "https://www.mediamarkt.com.tr"

# print("is: " + find_offer_tab(is_bank, header))
# print("bel: " + find_offer_tab(bellona, header))
# print("mig: " + find_offer_tab(migros, header))
# print("mm: " + find_offer_tab(media, header))