import requests
import pandas as pd
from bs4 import BeautifulSoup
import re
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time

header = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/119.0.0.0 Safari/537.36"
}

def getParsedHtml(baseUrl, header, isDynamic=False):
    if not isDynamic:
        httpRequest = requests.get(baseUrl, headers=header)
        return BeautifulSoup(httpRequest.text, "lxml")
    else:
        chrome_options = Options()
        chrome_options.add_argument("webdriver.chrome.driver=backend/chromedriver.exe")
        driver = webdriver.Chrome(options=chrome_options)
        driver.get(baseUrl)
        time.sleep(5)
        parsedHtml = BeautifulSoup(driver.page_source, "html.parser")
        driver.quit()
        return parsedHtml

def extractOfferLink(parsedHtml, baseWithoutHttps, baseUrl):
    offerPageTagList = parsedHtml.find_all(
        "a", href=re.compile("(kampanya|fırsat|promotion)", re.I))

    offerPageLinkList = [tag.get("href") for tag in offerPageTagList]

    offerPageLink = ""
    for iterPageLink in offerPageLinkList:
        if offerPageLink == "" or len(iterPageLink) < len(offerPageLink):
            offerPageLink = iterPageLink

    if offerPageLink:
        if baseWithoutHttps in offerPageLink:
            if "https:" not in offerPageLink:
                offerPageLink = "https:" + offerPageLink
        else:
            if "https:" not in offerPageLink:
                if offerPageLink[0] == "/":
                    offerPageLink = baseUrl + offerPageLink
                else:
                    offerPageLink = baseUrl + "/" + offerPageLink
    return offerPageLink

def findOfferTab(baseUrl, header):
    baseWithoutHttps = baseUrl.split(":")[-1]

    parsedHtml = getParsedHtml(baseUrl, header)
    
    if not parsedHtml.find("div"):
        parsedHtml = getParsedHtml(baseUrl, header, isDynamic=True)
    
    offerPageLink = extractOfferLink(parsedHtml, baseWithoutHttps, baseUrl)
    
    if not offerPageLink:
        parsedHtml = getParsedHtml(baseUrl, header, isDynamic=True)
        offerPageLink = extractOfferLink(parsedHtml, baseWithoutHttps, baseUrl)
    
    return offerPageLink if offerPageLink else ""


# is_bank = "https://www.isbank.com.tr"
# bellona = "https://www.bellona.com.tr"
# migros = "https://www.migros.com.tr"
# media = "https://www.mediamarkt.com.tr"

# print("is: " + find_offer_tab(is_bank, header))
# print("bel: " + find_offer_tab(bellona, header))
# print("mig: " + find_offer_tab(migros, header))
# print("mm: " + find_offer_tab(media, header))