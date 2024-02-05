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

def find_campaign_tab(baseUrl, header):
    base_without_https = baseUrl.split(":")[-1]
    
    httpRequest = requests.get(baseUrl, headers=header)
    parsedHomeHtml = BeautifulSoup(httpRequest.text, "html.parser")
    
    isDynamic = False if parsedHomeHtml.find("div") else True
    if isDynamic:
        chrome_options = Options()
        chrome_options.add_argument("webdriver.chrome.driver=backend/chromedriver.exe")
        driver = webdriver.Chrome(options=chrome_options)
        driver.get(baseUrl)
        time.sleep(5)
        parsedHomeHtml = BeautifulSoup(driver.page_source, "html.parser")
        driver.quit()

    campaignPageTagList = parsedHomeHtml.find_all(
        "a", href=re.compile("kampanya", re.I))

    campaignPageLinkList = []
    for iterTag in campaignPageTagList:
        campaignPageLinkList.append(iterTag.get("href"))

    campaignPageLink = ""
    for iterPageLink in campaignPageLinkList:
        if campaignPageLink == "":
            campaignPageLink = iterPageLink
        else:
            if len(iterPageLink) < len(campaignPageLink):
                campaignPageLink = iterPageLink
    
    if base_without_https in campaignPageLink:
        if "https:" not in campaignPageLink:
            campaignPageLink = "https:" + campaignPageLink
    else:
        campaignPageLink = baseUrl + campaignPageLink
        
    return campaignPageLink

is_bank = "https://www.isbank.com.tr"
bellona = "https://www.bellona.com.tr"
migros = "https://www.migros.com.tr"
media = "https://www.mediamarkt.com.tr"

print("is: " + find_campaign_tab(is_bank, header))
print("bel: " + find_campaign_tab(bellona, header))
print("mig: " + find_campaign_tab(migros, header))
print("mm: " + find_campaign_tab(media, header))