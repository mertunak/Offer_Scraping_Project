import requests
from bs4 import BeautifulSoup
import re
import firebase_operations
import find_offer_tab
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import datetime
import json
import time
from collections import deque, defaultdict
from bs4.element import Tag
from datetime import date

header = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/119.0.0.0 Safari/537.36"
}

singleDatePattern = re.compile(r'\d{1,2}([\.\/]\d{1,2}[\.\/]|\s(Ocak|(S|Ş)ubat|Mart|Nisan|May(ı|i)s|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kas(ı|i)m|Aral(ı|i)k)\s)\d{4}')
digitDatePattern = re.compile(r'\d{1,2}[\.\/]\d{1,2}[\.\/]\d{4}')
dateRangePattern = re.compile(r'\b\d{1,2}([\.\/]\d{1,2}[\.\/]|\s(?:Ocak|(?:S|Ş)ubat|Mart|Nisan|May(ı|i)s|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kas(ı|i)m|Aral(ı|i)k)\s*)\d{4}\s*-\s*\d{1,2}([\.\/]\d{1,2}[\.\/]|\s(?:Ocak|(?:S|Ş)ubat|Mart|Nisan|May(ı|i)s|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kas(ı|i)m|Aral(ı|i)k)\s*)\d{4}')

altin = "https://www.altinyildizclassics.com"
ets = "https://www.etstur.com"
isbank = "https://www.isbank.com.tr"
ebebek = "https://www.e-bebek.com"

def handle_rate_limit():
    print("Rate limit exceeded. Waiting for cooldown...")
    time.sleep(600)  # 600 saniye (10 dakika) bekleyin
    print("Cooldown period is over. Resuming...")
    
def ocr_space_url(url, overlay=False, api_key='K87650191288957', language='tur'):

    payload = {'url': url,
               'isOverlayRequired': overlay,
               'apikey': api_key,
               'language': language,
               }
    r = requests.post('https://api.ocr.space/parse/image',
                      data=payload,
                      )
    return r.content.decode()

def dateFormater(date):
    months = ["Ocak","Şubat","Mart","Nisan","Mayıs","Haziran","Temmuz","Ağustos","Eylül","Ekim","Kasım","Aralık"]
    formatedDate = ""
    if date is not None and isinstance(date, str):
        if re.search(r'[a-zA-Z]', date):
            dateParts = date.replace(u'\xa0', u' ').split(" ")
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
            date.strip().replace("/", ".")
            date = date.strip().replace("/", ".")
            dateParts = date.split(".")
            if len(dateParts[0]) == 1:
                formatedDate += "0"
            formatedDate += dateParts[0] + "."
            if len(dateParts[1]) == 1:
                formatedDate += "0"
            formatedDate += dateParts[1] + "."
            if len(dateParts) < 3:
                formatedDate += str(datetime.date.today().year)
            else:
                formatedDate += dateParts[2]
            return formatedDate
    else: 
        return formatedDate
        

def contains_campaign_content_filter(element):

    children_classes = [child.get('class', [None])[0] for child in element.children if isinstance(child, Tag)]
    if any(children_classes.count(cls) > 1 for cls in set(children_classes)):
        return False

    text_content = ' '.join(element.stripped_strings)
    word_count = len(text_content.split())
    return word_count > 3 and len(re.findall("(kampanya|ucuz|indirim|fırsat|hediye)", text_content, re.I)) > 0 and len(list(element.children)) < 10

def getOfferCardArray(offerPageLink):
    httpRequest = requests.get(offerPageLink, headers=header)
    parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "lxml")

    queue = deque([(parsedOfferPageHtml, None)])  # (current node, parent node)
    level = 0
    all_class_groups = defaultdict(list)
    
    while queue:
        level_size = len(queue)
        class_groups = defaultdict(list)  # Group elements with the same class and parent reference
        for _ in range(level_size):
            current, parent = queue.popleft()
            # Process the element
            
            # Group elements with the same class name and parent reference
            if current.get('class'):
                class_name = ' '.join(current.get('class'))
                group_key = (class_name, parent)
                class_groups[group_key].append(current)
            
            # Add child elements to the queue
            if current.children:
                for child in current.children:
                    if isinstance(child, str):
                        continue
                    class_attr = child.get('class')
                    if class_attr is None:
                        class_attr = ''
                    if child.name is not None and child.name.lower():
                        queue.append((child, current))
        
        # Add grouped elements to all_class_groups
        for group_key, elements in class_groups.items():
            class_name, _ = group_key
            if re.search("(camp|cmp|kamp|promo|offer|banner|bnr|fırsat|firsat|box|item|cont|cnt|col|md|group|card|wrap)", class_name, re.I) and not re.search("(foot|nav|slide|layout|background|filter|menu|service|button|btn|icon|cookie|notif|modal|dropdown|form)", class_name, re.I) or re.search("(camp|cmp|kamp|promo|offer|fırsat|firsat)", class_name, re.I):
                
                all_class_groups[group_key].extend(elements)
        
        level += 1
    
    # Convert to a list and sort by length of groups in descending order
    sorted_class_groups = sorted(all_class_groups.items(), key=lambda item: len(item[1]), reverse=True)
    
    # Keep track of class names already added to the result
    unique_class_groups = {}
    seen_classes = set()
    
    for group_key, elements in sorted_class_groups:
        class_name, _ = group_key
        if class_name not in seen_classes and len(elements) > 1:
            unique_class_groups[group_key] = elements
            seen_classes.add(class_name)

    unique_class_groups_copy = unique_class_groups.copy()
    for group_key, elements in unique_class_groups_copy.items():
        class_name, _ = group_key
        if not (contains_campaign_content_filter(elements[0]) or contains_campaign_content_filter(elements[1])):
            unique_class_groups.pop(group_key)

    return next(iter(unique_class_groups.values()))

def scrape_offers(baseUrl, firestoreDb):
    site = baseUrl.split('/')[-1].split('.')[1].capitalize()
    offers = []
    offerPageLink = find_offer_tab.findOfferTab(baseUrl=baseUrl, header=header)
    print(offerPageLink)
    offerCardArray = getOfferCardArray(offerPageLink)
    print(len(offerCardArray))
    if offerPageLink != "":
        n = 0
        for offerCard in offerCardArray:
            n += 1
            # if n == 2:
                # break
           #Extract offer strings
            offerStringList = list(offerCard.stripped_strings)
            offerAllStrings = ' '.join(offerCard.stripped_strings)

            #Link
            offerLink = ""
            if(offerCard.find("a")):
                for link in offerCard.find_all("a"):
                    offerLink = link.get("href")
                    if offerLink != None:    
                        if re.match("/", offerLink):
                            break
            else:
                offerLink = offerCard.get("href")

            if offerLink != None and offerLink != "":
                if not re.match(baseUrl, offerLink):
                    if not re.match("https", offerLink):
                        if offerLink[0] == "/":
                            offerLink = baseUrl + offerLink
                        else:
                            offerLink = baseUrl + "/"+ offerLink
            else:
                offerLink = ""

            #Title
            offerTitleSection = offerCard.find(class_=re.compile("(title|head)", re.I))
            offerTitle = ""
            if offerTitleSection:
                if offerTitleSection.string:
                    offerTitle = offerTitleSection.string.strip()
                else:
                    offerTitle = offerTitleSection.find(re.compile("h"))
                    if offerTitle != None:
                        offerTitle = offerTitle.string.strip()

                if offerTitle == None:
                    offerTitle = ""
                    for sec in offerTitleSection.children: 
                        if not re.search("koşul", sec.text, re.I):
                            offerTitle += sec.text.strip()
            else:
                if offerStringList:
                    offerTitle = offerStringList[0]
                    del offerStringList[0]
                else:
                    offerTitle = ""
                
            # Image
            isImageDynamic = False
            offerImageLink = ""
            offerImageSection = offerCard.find(class_=re.compile("(image|img)", re.I))
            if offerImageSection:
                offerImageLink = offerImageSection.get("src")
                if offerImageLink == None:
                    offerImageLink = offerCard.find("img").get("src")
                    if offerImageLink == None:
                        offerImageLink = offerCard.find("img").get("data-src")
            else:
                if offerCard.find("img"):
                    offerImageLink = offerCard.find("img").get("src")
                if offerImageLink == None:
                    if offerCard.find("img"):
                        offerImageLink = offerCard.find("img").get("data-src")
                if offerImageLink == "":
                    if offerCard.find('div', style=re.compile("(image|img)", re.I)):
                        isImageDynamic = True
                        style=offerCard.find('div', style=re.compile("(image|img)", re.I)).get("style")
                        url_pattern = re.compile(r"url(['\"]?(.*?)['\"]?)")
                        match = url_pattern.search(style)
                        offerImageLink = match.group(1) if match else None
            # print(offerImageLink)
            if offerImageLink == None:
                offerImageLink = ""
            else:
                if offerImageLink != "" :
                    if not re.match(baseUrl, offerImageLink):
                        if not re.match("https://", offerImageLink):
                            offerImageLink = baseUrl + offerImageLink
                    
            # Description
            offerDescriptionSection = offerCard.find(class_=re.compile("(description|desc|cond)", re.I))
            if offerDescriptionSection:
                # if(offerDescriptionSection.string):
                #     offerDescription = offerDescriptionSection.string.strip()
                # else:
                #     offerDescription = offerDescriptionSection.find(re.compile("h|span|p")).string.strip()
                offerDescription = ' '.join(offerDescriptionSection.stripped_strings)
            else:
                offerDescription = ""
                if offerTitleSection:
                    possibleDescriptionSections = []
                    for possibleSection in offerTitleSection.next_siblings:
                        if possibleSection.name: 
                            for child in possibleSection.find_all(re.compile("h|span|p|li")):
                                possibleDescriptionSections.append(child)
                    for section in possibleDescriptionSections:
                        try:
                            if not re.search("koşul", section.text, re.I):
                                offerDescription += section.text.strip() + " "
                        except:
                            continue
                    if offerDescription == "":
                        for string in offerStringList:
                            offerDescription += string.strip() + " "
                    if len(offerDescription) < 20:
                        offerDescription = ""
                else:
                    offerDescription = " ".join(offerStringList)

            #Date
            startDate = ""
            endDate = ""
            dateRanges = None
            dateSection = offerCard.find(class_=re.compile("date", re.I))
            if dateSection:
                singleDates = list(singleDatePattern.finditer(dateSection.get_text()))
                match len(singleDates):
                    case 0:
                        print("Date not found")
                    case 1:
                        endDate = dateFormater(singleDates[0].group())
                        dateRanges = list(dateRangePattern.finditer(offerDescription))
                        if dateRanges:
                            dateRange = dateRanges[-1].group()
                            dates = list(digitDatePattern.finditer(dateRange))
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
                if offerDescription != "":
                    dateRanges = list(dateRangePattern.finditer(offerDescription))
                    if dateRanges:
                        dateRange = dateRanges[-1].group()
                        dates = list(digitDatePattern.finditer(dateRange))
                        # print(dateRange)
                        if dates:
                            startDate = dates[0].group()
                            endDate = dates[1].group()
                        else:
                            dates = dateRange.split("-")
                            endDate = dateFormater(dates[1].strip())
                            startDateParts = dates[0].strip().split(" ")
                            if len(startDateParts) < 2:
                                startDate = dateFormater(startDateParts[0] + " " + dates[1].replace(u'\xa0', u' ').strip().split(" ")[1])
                            else: 
                                startDate = dateFormater(dates[0].strip())
                    else:
                        singleDates = list(singleDatePattern.finditer(offerDescription))
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

                        if startDate == "" and endDate == "":
                            singleDates = list(singleDatePattern.finditer(offerAllStrings))
                            match len(singleDates):
                                case 0:
                                    print("Date not found")
                                case 1:
                                    tmpEndDate = ""
                                    endDate = dateFormater(singleDates[0].group())
                                    dateRanges = list(dateRangePattern.finditer(offerDescription))
                                    if dateRanges:
                                        dateRange = dateRanges[-1].group()
                                        dates = list(digitDatePattern.finditer(dateRange))
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

                if startDate == "" and endDate == "" and offerLink != "":
                    httpRequest = requests.get(offerLink, headers=header)
                    parsedOfferDetailPageHtml = BeautifulSoup(httpRequest.text, "lxml")
                    dPCampaignSections = parsedOfferDetailPageHtml.find_all("div", {"class": re.compile("(kampanya|kamp|campaign|detay)", re.I)}) + parsedOfferDetailPageHtml.find_all("div", {"id": re.compile("(kampanya|kamp|campaign)", re.I)})
                    
                    campaignDetailStrings = []
                    for dPCampaignSection in dPCampaignSections:
                        if dPCampaignSection.stripped_strings:
                            campaignDetailStrings += [text.strip() for text in dPCampaignSection.stripped_strings]
                    
                    if offerDescription == "":
                        offerDescription = " ".join(campaignDetailStrings)
                        dateRanges = list(dateRangePattern.finditer(offerDescription))
                        if dateRanges:
                            dateRange = dateRanges[-1].group()
                            dates = list(digitDatePattern.finditer(dateRange))
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
                            singleDates = list(singleDatePattern.finditer(offerDescription))
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
                        for possibleDateString in campaignDetailStrings:
                            dateRanges = list(dateRangePattern.finditer(possibleDateString))
                        if dateRanges:
                            dateRange = dateRanges[-1].group()
                            dates = list(digitDatePattern.finditer(dateRange))
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
                            singleDates = list(singleDatePattern.finditer(offerDescription))
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
            
            if endDate != "":
                endDateParts = endDate.split(".")
                todayDateParts = date.today().strftime("%d.%m.%Y").split(".")
                print(endDate + " " + date.today().strftime("%d.%m.%Y"))
                if todayDateParts[2] < endDateParts[2]:
                    offer = {
                        "link": offerLink,
                        "title" : offerTitle,
                        "description" : offerDescription,
                        "image": offerImageLink,
                        "startDate" : startDate,
                        "endDate" : endDate,
                        "site": site
                    }
                    # print(offer)
                    offers.append(offer)
                elif todayDateParts[2] == endDateParts[2] and todayDateParts[1] < endDateParts[1]:
                    offer = {
                        "link": offerLink,
                        "title" : offerTitle,
                        "description" : offerDescription,
                        "image": offerImageLink,
                        "startDate" : startDate,
                        "endDate" : endDate,
                        "site": site
                    }
                    # print(offer)
                    offers.append(offer)
                elif todayDateParts[2] == endDateParts[2] and todayDateParts[1] == endDateParts[1] and todayDateParts[0] < endDateParts[0]:
                    offer = {
                        "link": offerLink,
                        "title" : offerTitle,
                        "description" : offerDescription,
                        "image": offerImageLink,
                        "startDate" : startDate,
                        "endDate" : endDate,
                        "site": site
                    }
                    # print(offer)
                    offers.append(offer)

            else:
                offer = {
                    "link": offerLink,
                    "title" : offerTitle,
                    "description" : offerDescription,
                    "image": offerImageLink,
                    "startDate" : startDate,
                    "endDate" : endDate,
                    "site": site
                }
                # print(offer)
                offers.append(offer)

    else:
        print("Search in slider")

    scraped_site = {
        "site_name": site,
        "url": baseUrl,
        "scraping_date": datetime.date.today().strftime("%d-%m-%Y"),
    }

    firebase_operations.add_scraped_site(scraped_site, firestoreDb)
    firebase_operations.add_offers_to_firestore(offers, firestoreDb)

    # for o in offers:
    #     print("\n\nLink: " + o["link"],
    #             "\nTitle: " + o["title"],
    #             "\nDescription: " + o["description"],
    #             "\nImage: " + o["image"],
    #             "\nStartDate: " + o["startDate"],
    #             "\nEndDate: " + o["endDate"],
    #             "\nSite: " + o["site"])

import firebase_admin
from firebase_admin import credentials, firestore
credentialData = credentials.Certificate("backend/serviceAccountKey.json")
firebase_admin.initialize_app(credentialData)
firestoreDb = firestore.client()
scrape_offers(isbank, firestoreDb)
# scrape_offers(isbank)
# scrape_offers(altin)
# scrape_offers(ebebek)
# scrape_offers("https://www.desa.com.tr")
# scrape_offers("https://www.flo.com.tr") #Title #Dateler karışabiliyor /
# scrape_offers("https://www.instreet.com.tr")
# scrape_offers("https://www.lumberjack.com.tr") #date sectionu vara ama bazen descte
# scrape_offers("https://www.mudo.com.tr") #Title yanlış çekiliyor.
# scrape_offers("https://www.ninewest.com.tr")
# scrape_offers("https://www.penti.com")
# scrape_offers("https://www.reebok.com.tr")
# scrape_offers("https://www.slazenger.com.tr")
# scrape_offers("https://tr.uspoloassn.com") #Dinamik görsel
# scrape_offers("https://www.kumtel.com")
# scrape_offers("https://www.tefal.com.tr")
# scrape_offers("https://www.karaca.com")
# scrape_offers("https://www.madamecoco.com")
# scrape_offers("https://www.pierrecardin.com.tr")
# scrape_offers("https://www.teb.com.tr")
# scrape_offers("https://www.yapikredi.com.tr") #Dinamik görsel
# scrape_offers("https://www.etstur.com") #Detay ve görsel iç sayfada
# scrape_offers("https://www.enuygun.com") #Dinamik görsel
# scrape_offers("https://www.pttcell.com.tr") #Date detayda
# scrape_offers("https://www.vodafone.com.tr") # Desc detayda