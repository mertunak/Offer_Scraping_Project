import requests
import pandas as pd
from bs4 import BeautifulSoup
import re
import find_offer_tab
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import datetime

header = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/119.0.0.0 Safari/537.36"
}
singleDateRegex = r'\d{1,2}(\.\d{1,2}\.|\s(Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık)\s)\d{4}'
digitDateRegex = r'\d{1,2}\.\d{1,2}\.\d{4}'
dateRangeRegex = r'\b\d{1,2}(\.\d{1,2}\.|\s(Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık)\s*)*(\d{4})*\s*-\s*\d{1,2}(\.\d{1,2}\.|\s(Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık)\s)(\d{4})*'

singleDatePatern = re.compile(singleDateRegex)
digitDatePatern = re.compile(digitDateRegex)
dateRangePatern = re.compile(dateRangeRegex)

altin = "https://www.altinyildizclassics.com"
ets = "https://www.etstur.com"
isbank = "https://www.isbank.com.tr"
instreet = "https://www.instreet.com.tr"
site = "https://www.e-bebek.com"

def dateFormater(date):
    months = ["Ocak","Şubat","Mart","Nisan","Mayıs","Haziran","Temmuz","Ağustos","Eylül","Ekim","Kasım","Aralık"]
    formatedDate = ""
    if date is not None and isinstance(date, str):
        if re.search(r'[a-zA-Z]', date):
            dateParts = date.split(" ")
            if len(dateParts[0]) == 1:
                formatedDate += "0"
            formatedDate += dateParts[0] + "."

            i = 0
            for month in months:
                i += 1
                if re.match(month, dateParts[1], re.I):
                    break
            
            if i < 10:
                formatedDate += "0"
            formatedDate += str(i) + "."
            
            if len(dateParts) < 3:
                formatedDate += str(datetime.date.today().year)
            else:
                formatedDate += dateParts[2]
            
            return formatedDate
        else:
            return date.strip()
    else: 
        return formatedDate
        

def scrape_offers(baseUrl):
    site = baseUrl.split('/')[-1].split('.')[1].capitalize()

    offers = []
    offerPageLink = find_offer_tab.findOfferTab(baseUrl=baseUrl, header=header)
    print(offerPageLink)
    if offerPageLink != "":
        httpRequest = requests.get(offerPageLink, headers=header)
        parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "lxml")
        possibleOfferSections = parsedOfferPageHtml.find_all("div", {"class": re.compile("(kampanya|kamp|campaign)", re.I)}) +parsedOfferPageHtml.find_all("div", {"id": re.compile("(kampanya|kamp|campaign)", re.I)})
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
        # print(offerCardArr)
        # print(offerCard)
        i = 0
        for offerCard in offerCardArr:
            i += 1
            if i > 10:
                break
            offerStringSections = offerCard.find_all(re.compile("h|span"))
            offerStrings = []
            for offerStringSection in offerStringSections:
                offerStrings.append(offerStringSection.string.strip())
            #Link
            if(offerCard.find("a")):
                offerLink = offerCard.find("a").get("href")
            else:
                offerLink = offerCard.get("href")
            if not re.match(baseUrl, offerLink):
                offerLink = baseUrl + offerLink

            print("Link: " + offerLink)
            
            #Title
            offerTitleSection = offerCard.find(class_=re.compile("title", re.I))
            if offerTitleSection:
                if offerTitleSection.string:
                    offerTitle = offerTitleSection.string.strip()
                else:
                    offerTitle = offerTitleSection.find(re.compile("h")).string.strip()
            else:
                offerTitle = offerStrings[0]
                del offerStrings[0]
            print("Title: " + offerTitle)
            
            # Image
            isImageDynamic = False
            offeImageSection = offerCard.find(class_=re.compile("(image|img)", re.I))
            if offeImageSection:
                offerImageLink = offeImageSection.find("img").get("src")
                if not re.match(baseUrl, offerImageLink):
                    if not re.match("https://", offerImageLink):
                        offerImageLink = baseUrl + offerImageLink
            else:
                if offerCard.find('div', style=re.compile("(image|img)", re.I)):
                    isImageDynamic = True
                offerImageLink = ""
            
            print("Image: " + offerImageLink)
            
            # Description
            offerDescriptionSection = offerCard.find(class_=re.compile("(description|desc)", re.I))
            if offerDescriptionSection:
                if(offerDescriptionSection.string):
                    offerDescription = offerDescriptionSection.string.strip()
                else:
                    offerDescription = offerDescriptionSection.find(re.compile("h")).string.strip()
            else:
                offerDescription = ""
                if offerTitleSection:
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
                else:
                    offerDescription = " ".join(offerStrings)

            print("Desc: " + offerDescription)
            
            #Date
            startDate = ""
            endDate = ""
            dateSection = offerCard.find(class_=re.compile("date", re.I))
            if dateSection:
                singleDates = list(singleDatePatern.finditer(dateSection.get_text()))
                match len(singleDates):
                    case 0:
                        print("Date not found")
                    case 1:
                        endDate = dateFormater(singleDates[0].group())
                        dateRanges = list(dateRangePatern.finditer(offerDescription))
                        if dateRanges:
                            dateRange = dateRanges[-1].group()
                            dates = list(digitDatePatern.finditer(dateRange))
                            if dates:
                                tmpStartDate = dates[0].group()
                                tmpEndDate = dates[1].group()
                            else:
                                dates = dateRange.split("-")
                                tmpEndDate = dateFormater(dates[1].strip())
                                startDateParts = dates[0].strip().split(" ")
                                if len(startDateParts) < 2:
                                    tmpStartDate = dateFormater(startDateParts[0] + " " + dates[1].strip().split(" ")[1])
                                else: 
                                    tmpStartDate = dateFormater(dates[0].strip())
                        if endDate == tmpEndDate:
                            startDate = tmpStartDate
                    case 2:
                        startDate = dateFormater(singleDates[0].group())
                        endDate = dateFormater(singleDates[1].group())
                    case default:
                        startDate = dateFormater(singleDates[-2].group())
                        endDate = dateFormater(singleDates[-1].group())
            else:
                if offerDescription:
                    dateRanges = list(dateRangePatern.finditer(offerDescription))
                    if dateRanges:
                        dateRange = dateRanges[-1].group()
                        dates = list(digitDatePatern.finditer(dateRange))
                        if dates:
                            startDate = dates[0].group()
                            endDate = dates[1].group()
                        else:
                            dates = dateRange.split("-")
                            endDate = dateFormater(dates[1].strip())
                            startDateParts = dates[0].strip().split(" ")
                            if len(startDateParts) < 2:
                                startDate = dateFormater(startDateParts[0] + " " + dates[1].strip().split(" ")[1])
                            else: 
                                startDate = dateFormater(dates[0].strip())
                    else:
                        singleDates = list(singleDatePatern.finditer(offerDescription))
                        match len(singleDates):
                            case 0:
                                print("Date not found")
                            case 1:
                                startDate = ""
                                endDate = dateFormater(singleDates[0].group())
                            case 2:
                                startDate = dateFormater(singleDates[0].group())
                                endDate = dateFormater(singleDates[1].group())
                            case default:
                                startDate = dateFormater(singleDates[-2].group())
                                endDate = dateFormater(singleDates[-1].group())
                    
                else:
                    httpRequest = requests.get(offerLink, headers=header)
                    parsedOfferDetailPageHtml = BeautifulSoup(httpRequest.text, "lxml")
                    dPCampaignSections = parsedOfferDetailPageHtml.find_all("div", {"class": re.compile("(kampanya|kamp|campaign)", re.I)}) + parsedOfferDetailPageHtml.find_all("div", {"id": re.compile("(kampanya|kamp|campaign)", re.I)})
                    possibleDateStrings = []
                    for dPCampaignSection in dPCampaignSections:
                        if dPCampaignSection.stripped_strings:
                            possibleDateStrings += [text.strip() for text in dPCampaignSection.stripped_strings]
                    for possibleDateString in possibleDateStrings:
                        dateRanges = list(dateRangePatern.finditer(possibleDateString))
                    if dateRanges:
                        dateRange = dateRanges[-1].group()
                        dates = list(digitDatePatern.finditer(dateRange))
                        if dates:
                            startDate = dates[0].group()
                            endDate = dates[1].group()
                        else:
                            dates = dateRange.split("-")
                            endDate = dateFormater(dates[1].strip())
                            startDateParts = dates[0].strip().split(" ")
                            if len(startDateParts) < 2:
                                startDate = dateFormater(startDateParts[0] + " " + dates[1].strip().split(" ")[1])
                            else: 
                                startDate = dateFormater(dates[0].strip())
                    else:
                        singleDates = list(singleDatePatern.finditer(offerDescription))
                        match len(singleDates):
                            case 0:
                                print("Date not found")
                            case 1:
                                startDate = ""
                                endDate = dateFormater(singleDates[0].group())
                            case 2:
                                startDate = dateFormater(singleDates[0].group())
                                endDate = dateFormater(singleDates[1].group())
                            case default:
                                startDate = dateFormater(singleDates[-2].group())
                                endDate = dateFormater(singleDates[-1].group())

            print("StartDate: " + startDate)
            print("EndDate: " + endDate)
            
            offer = {
                "link": offerLink,
                "title" : offerTitle,
                "description" : offerDescription,
                "image": offerImageLink,
                "startDate" : startDate,
                "endDate" : endDate,
                "site": site
            }

            offers.append(offer)
    else:
        print("Search in slider")

    # for o in offers:
    #     print("\n\nLink: " + o["link"],
    #             "\nTitle: " + o["title"],
    #             "\nDescription: " + o["description"],
    #             "\nImage: " + o["image"],
    #             "\nStartDate: " + o["startDate"],
    #             "\nEndDate: " + o["endDate"],
    #             "\nSite: " + o["site"])

# scrape_offers(altin)
# scrape_offers(ets)
# scrape_offers(isbank)
scrape_offers(site)

