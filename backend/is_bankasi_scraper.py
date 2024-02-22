import requests
import pandas as pd
from bs4 import BeautifulSoup
import re
import firebase_operations
import find_offer_tab

header = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/119.0.0.0 Safari/537.36"
}

altin = "https://www.altinyildizclassics.com"
ets = "https://www.etstur.com/Kampanyalar/Erken-Rezervasyon"
isbank = "https://www.isbank.com.tr"

def scrape_offers(baseUrl):
    # site = baseUrl.split('/')[-1].split('.')[1].capitalize()

    offers = []
    offerPageLink = baseUrl

    if offerPageLink != "":
        httpRequest = requests.get(offerPageLink, headers=header)
        parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "html5lib")
        possibleOfferSections = parsedOfferPageHtml.find_all("div", class_=re.compile("(kampanya|kamp|campaign)", re.I))
        # offerSection = None
        i = 0
        for possibleOfferSection in possibleOfferSections:
            offerCardArr = []
            for child in possibleOfferSection.contents:
                if child.name:
                    offerCardArr.append(child)
            offerCardArrLen = len(offerCardArr)
            if offerCardArrLen > 1:
                try:
                    if offerCardArr[0]['class'][0] == offerCardArr[1]['class'][0]:
                        # offerSection = possibleOfferSection
                        print(offerCardArrLen)
                        break
                except:
                    continue
        # print(offerSection)
        for offerCard in offerCardArr:
            #Link
            # if(offerCard.find("a")):
            #     offerLink = offerCard.find("a").get("href")
            # else:
            #     offerLink = offerCard.get("href")
            # if not re.match(baseUrl, offerLink):
            #     offerLink = baseUrl + offerLink

            #Title
            # offerTitleSection = offerCard.find(class_=re.compile("title", re.I))
            # if(offerTitleSection.string):
            #     offerTitle = offerTitleSection.string.strip()
            # else:
            #     offerTitle = offerTitleSection.find(re.compile("h")).string.strip()

            #Description
            # offerDescriptionSection = offerCard.find(class_=re.compile("(description|desc)", re.I))
            # if offerDescriptionSection:
            #     if(offerDescriptionSection.string):
            #         offerDescription = offerDescriptionSection.string.strip()
            #     else:
            #         offerDescription = offerDescriptionSection.find(re.compile("h")).string.strip()
            # else:
            #     offerDescription = ""
            #     possibleDescriptionSections = []
            #     for possibleSection in offerTitleSection.next_siblings:
            #         if possibleSection.name:
            #             possibleDescriptionSections.append(possibleSection)
            #     for section in possibleDescriptionSections:
            #         try:
            #             offerDescription += section.get_text().strip() + " "
            #         except:
            #             continue
            #     if len(offerDescription) < 20 and re.match("detay", offerDescription, re.I):
            #         offerDescription = ""
            
            #Image
            offeImageSection = offerCard.find(class_=re.compile("(image|img)", re.I))
            if offeImageSection:
                offerImageLink = offeImageSection.find("img").get("src")
                if not re.match(baseUrl, offerImageLink):
                    if not re.match("https://", offerImageLink):
                        offerImageLink = baseUrl + offerImageLink
            else:
                print(offerCard.find('div', style=re.compile("(image|img)", re.I)))
                print("\n")
            print(offerImageLink)
            
            # dateSection = offerCard.find(class_=re.compile("date", re.I))#Date
            # offerEndDate = dateSection.find(string=re.compile("(\d{2})[/.-](\d{2})[/.-](\d{4})$"))
            
            # offer = {
            #     "Link": offerLink,
            #     "Title" : offerTitle,
            #     "Description" : offerDescription,
            #     "Image": offerImageLink,
            #     "StartDate" : "-",
            #     "EndDate" : offerEndDate,
            #     "Site": site
            # }

            # offers.append(offer)
    else:
        print("Search in slider")

    # print(offers)

# scrape_offers(altin)
scrape_offers(ets)
# scrape_offers(isbank)

# firebase_operations.add_offers_to_firestore(offers, site)