import requests
import pandas as pd
from bs4 import BeautifulSoup
import re
import firebase_operations
import find_offer_tab
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time

header = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/119.0.0.0 Safari/537.36"
}
singleDateRegex = r'\d{1,2}(\.\d{1,2}\.|\s(Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık)\s)\d{4}'
dateRangeRegex = r'\b\d{1,2}(\.\d{1,2}\.|\s(Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık)\s*)*(\d{4})*\s*-\s*\d{1,2}(\.\d{1,2}\.|\s(Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık)\s)(\d{4})*'

singleDatePatern = re.compile(singleDateRegex)
dateRangePatern = re.compile(dateRangeRegex)

altin = "https://www.altinyildizclassics.com"
ets = "https://www.etstur.com"
isbank = "https://www.isbank.com.tr"
# instreet = "https://www.instreet.com.tr"

def dateFormater(offerDates, index):
    return f"{offerDates[index][0]}.{offerDates[index][1]}.{offerDates[index][2]}"

def scrape_offers(baseUrl):
    site = baseUrl.split('/')[-1].split('.')[1].capitalize()

    offers = []
    offerPageLink = find_offer_tab.findOfferTab(baseUrl=baseUrl, header=header)

    if offerPageLink != "":
        httpRequest = requests.get(offerPageLink, headers=header)
        parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "html.parser")
        possibleOfferSections = parsedOfferPageHtml.find_all("div", class_=re.compile("(kampanya|kamp|campaign)", re.I))
        for possibleOfferSection in possibleOfferSections:
            offerCardArr = []
            for child in possibleOfferSection.contents:
                if child.name:
                    offerCardArr.append(child)
            offerCardArrLen = len(offerCardArr)
            if offerCardArrLen > 1:
                try:
                    if offerCardArr[0]['class'][0] == offerCardArr[1]['class'][0]:
                        print(offerCardArrLen)
                        break
                except:
                    continue
        for offerCard in offerCardArr:
            #Link
            # if(offerCard.find("a")):
            #     offerLink = offerCard.find("a").get("href")
            # else:
            #     offerLink = offerCard.get("href")
            # if not re.match(baseUrl, offerLink):
            #     offerLink = baseUrl + offerLink

            #Title
            offerTitleSection = offerCard.find(class_=re.compile("title", re.I))
            # if(offerTitleSection.string):
            #     offerTitle = offerTitleSection.string.strip()
            # else:
            #     offerTitle = offerTitleSection.find(re.compile("h")).string.strip()
            
            #Image
            # isImageDynamic = False
            # offeImageSection = offerCard.find(class_=re.compile("(image|img)", re.I))
            # if offeImageSection:
            #     offerImageLink = offeImageSection.find("img").get("src")
            #     if not re.match(baseUrl, offerImageLink):
            #         if not re.match("https://", offerImageLink):
            #             offerImageLink = baseUrl + offerImageLink
            # else:
            #     if offerCard.find('div', style=re.compile("(image|img)", re.I)):
            #         isImageDynamic = True
            #     offerImageLink = ""
            
            # Description
            offerDescriptionSection = offerCard.find(class_=re.compile("(description|desc)", re.I))
            if offerDescriptionSection:
                if(offerDescriptionSection.string):
                    offerDescription = offerDescriptionSection.string.strip()
                else:
                    offerDescription = offerDescriptionSection.find(re.compile("h")).string.strip()
            else:
                offerDescription = ""
                possibleDescriptionSections = []
                for possibleSection in offerTitleSection.next_siblings:
                    if possibleSection.name:
                        possibleDescriptionSections.append(possibleSection)
                for section in possibleDescriptionSections:
                    try:
                        offerDescription += section.get_text().strip() + " "
                    except:
                        continue
                if len(offerDescription) < 20 and re.match("detay", offerDescription, re.I):
                    offerDescription = ""

            #Date
            dateSection = offerCard.find(class_=re.compile("date", re.I))
            if dateSection:
                offerDates = re.findall("(\d{2})[/.-](\d{2})[/.-](\d{4})", dateSection.get_text())
                # if len(offerDates) == 1:
                #     offerEndDate = dateFormater(offerDates=offerDates, index=0)
                #     print(offerEndDate)
                # else:
                #     offerStartDate = dateFormater(offerDates=offerDates, index=0)
                #     offerEndDate = dateFormater(offerDates=offerDates, index=1)
            else:
                if offerDescription:
                    dates = list(dateRangePatern.finditer(desc))
                    if dates:
                        dateRange = dates[-1].group()
                        
                    else:
                        dates = list(singleDatePatern.finditer(desc))
                        for date in dates:
                            print(date.group())
                else:
                    print("2)Alt linke git")
            # print(dateSection)
            
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

scrape_offers(altin)
# scrape_offers(ets)
# scrape_offers(isbank)
# scrape_offers(instreet)

# firebase_operations.add_offers_to_firestore(offers, site)