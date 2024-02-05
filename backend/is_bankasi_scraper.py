import requests
import pandas as pd
from bs4 import BeautifulSoup
import re
import firebase_operations
import find_offer_tab

baseUrl = "https://www.isbank.com.tr"
header = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/119.0.0.0 Safari/537.36"
}

site = baseUrl.split('/')[-1].split('.')[1].capitalize()

offers = []
offerPageLink = find_offer_tab.find_offer_tab(baseUrl = baseUrl, header = header)

if offerPageLink != "":
    httpRequest = requests.get(offerPageLink, headers=header)
    parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "html.parser")
    offerSection = parsedOfferPageHtml.find("div", class_=re.compile("(kampanya|kamp)", re.I))
    offerCardArr = offerSection.find_all("div", class_="kamp_cards33C")
    for offerCard in offerCardArr:
        offerLink = offerCard.find("a").get("href")#Link
        if not re.match(baseUrl, offerLink):
            offerLink = baseUrl + offerLink

        offerTitle = offerCard.find(class_=re.compile("title", re.I)).string.strip()#Title

        offerDescription = offerCard.find(class_=re.compile("(description|desc)", re.I)).string.strip()#Description

        offerImageLink = offerCard.find(class_=re.compile("(image|img)", re.I)).find("img").get("src")#Image
        if not re.match(baseUrl, offerImageLink):
            offerImageLink = baseUrl + offerImageLink

        dateSection = offerCard.find(class_=re.compile("date", re.I))#Date
        offerEndDate = dateSection.find(string=re.compile("(\d{2})[/.-](\d{2})[/.-](\d{4})$"))
        
        offer = {
            "Link": offerLink,
            "Title" : offerTitle,
            "Description" : offerDescription,
            "Image": offerImageLink,
            "StartDate" : "-",
            "EndDate" : offerEndDate,
            "Site": site
        }

        offers.append(offer)
else:
    print("Search in slider")

firebase_operations.add_offers_to_firestore(offers, site)