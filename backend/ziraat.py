import requests
import pandas as pd
from bs4 import BeautifulSoup
import re
import firebase_operations
import find_offer_tab
from nltk.tokenize import sent_tokenize
import nltk
nltk.download('punkt')

baseUrl = "https://www.bankkart.com.tr"
header = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/119.0.0.0 Safari/537.36"
}

site = baseUrl.split('/')[-1].split('.')[1].capitalize()

offers = []
offerPageLink = find_offer_tab.findOfferTab(baseUrl = baseUrl, header = header)
print(offerPageLink)
if offerPageLink != "":
    httpRequest = requests.get(offerPageLink, headers=header)
    parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "html.parser")
    offerSection = parsedOfferPageHtml.find("div", class_=re.compile("(kampanya|kamp|campaign)", re.I))
    #print(offerSection)
    offerList=offerSection.find_all("section", class_="col-md-3 col-sm-4 col-xs-6")
    for offerCard in offerList:
        offerLink = offerCard.find("a").get("href")#Link 
        
        if not re.match(baseUrl, offerLink):
            offerLink = baseUrl + offerLink
       
        
        offerImageLink = offerCard.find(class_="front").find("img").get("src")#Image
        if not re.match(baseUrl,offerImageLink):
            offerImageLink=baseUrl+offerImageLink
        
        offerTitle=offerCard.find("h4").text #Title
        
        offerDetailPageRequest=requests.get(offerLink,headers=header)
        parsedOfferPageDetailHtml=BeautifulSoup(offerDetailPageRequest.text,"html.parser")
        #print(parsedOfferPageDetailHtml.prettify)
        dateSection=parsedOfferPageDetailHtml.find("div",class_=re.compile("(date)",re.I))
        dateText=dateSection.find("h4").text
        offerEndDate=dateText.split("-")[1].strip() #End Date
        #print(offerEndDate)
        
        offerDescriptionSection=parsedOfferPageDetailHtml.find("div",re.compile("(detail-content)",re.I))
        uls=offerDescriptionSection.find_all("ul")
        if len(uls)>=2:
            offerDescription=uls[1].text #Description
            sentences = sent_tokenize(offerDescription)
            offerDescription = ' '.join(sentences[:1])
        else:
            offerDescription=uls[0].text
            sentences = sent_tokenize(offerDescription)
            offerDescription = ' '.join(sentences[:1])
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