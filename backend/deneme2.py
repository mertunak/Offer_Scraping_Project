import requests
from bs4 import BeautifulSoup
import re
import find_offer_tab
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import datetime
import json
import time
from collections import deque, defaultdict

header = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/119.0.0.0 Safari/537.36"
}

altin = "https://www.altinyildizclassics.com"
ets = "https://www.etstur.com"
isbank = "https://www.isbank.com.tr"
garanti = "https://www.garantibbva.com.tr"
ebebek = "https://www.e-bebek.com"
vakif = "https://www.vakifbank.com.tr"
teb = "https://www.teb.com.tr"
karaca="https://www.karaca.com"
akbank = "https://www.akbank.com"
kuveyt = "https://www.kuveytturk.com.tr"
yapikredi = "https://www.yapikredi.com.tr"
halk = "https://www.halkbank.com.tr"
deniz = "https://www.denizbank.com"
qnb = "https://www.qnbfinansbank.com"
ing = "https://www.ing.com.tr"

flo = "https://www.flo.com.tr"
instreet = "https://www.instreet.com.tr"
adidas = "https://www.adidas.com.tr"
nike = "https://www.nike.com"
puma = "https://tr.puma.com"
reebok = "https://www.reebok.com.tr"
newbalance = "https://www.newbalance.com.tr"
superstep = "https://www.superstep.com.tr"
ayakkabidunyasi = "https://www.ayakkabidunyasi.com.tr"
lumber = "https://www.lumberjack.com.tr"

singleDatePatern = re.compile(r'\d{1,2}([\.\/]\d{1,2}[\.\/]|\s(Ocak|(S|Ş)ubat|Mart|Nisan|May(ı|i)s|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kas(ı|i)m|Aral(ı|i)k)\s)\d{4}')
digitDatePatern = re.compile(r'\d{1,2}[\.\/]\d{1,2}[\.\/]\d{4}')
dateRangePatern = re.compile(r'\b\d{1,2}([\.\/]\d{1,2}[\.\/]|\s(Ocak|(S|Ş)ubat|Mart|Nisan|May(ı|i)s|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kas(ı|i)ım|Aral(ı|i)k)\s*)*(\d{4})*\s*-\s*\d{1,2}([\.\/]\d{1,2}[\.\/]|\s(Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık)\s)(\d{4})*')

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
            return date.strip().replace("/", ".")
    else: 
        return formatedDate

def getOfferCardArray(offerPageLink):
    httpRequest = requests.get(offerPageLink, headers=header)
    parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "lxml")

    # chrome_options = Options()
    # chrome_options.add_argument("webdriver.chrome.driver=backend/chromedriver.exe")
    # driver = webdriver.Chrome(options=chrome_options)
    # driver.get(offerPageLink)
    # time.sleep(5)
    # parsedOfferPageHtml = BeautifulSoup(driver.page_source, "html.parser")
    # driver.quit()

    queue = deque([(parsedOfferPageHtml, None)])  # (current node, parent node)
    level = 0
    all_class_groups = defaultdict(list)
    
    while queue:
        level_size = len(queue)
        class_groups = defaultdict(list)  # Group elements with the same class and parent reference
        for _ in range(level_size):
            current, parent = queue.popleft()
            # Process the element
            # print(f"Level {level}: {current.name}, {current.attrs}, {current.string}")
            
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
                    #  and child.name.lower() not in ['span', 'p', 'h', 'img', 'ul', 'button', 'input'] and not re.search("(nav|footer|foot)", ' '.join(class_attr), re.I)
                    if child.name is not None and child.name.lower() not in ['span', 'p', 'h', 'img', 'button', 'input'] and not re.search("(nav|footer|foot)", ' '.join(class_attr), re.I):
                        queue.append((child, current))
        
        # Add grouped elements to all_class_groups
        for group_key, elements in class_groups.items():
            all_class_groups[group_key].extend(elements)
        
        level += 1
    
    # Convert to a list and sort by length of groups in descending order
    sorted_class_groups = sorted(all_class_groups.items(), key=lambda item: len(item[1]), reverse=True)
    
    # Keep track of class names already added to the result
    unique_class_groups = {}
    seen_classes = set()
    
    for group_key, elements in sorted_class_groups:
        class_name, _ = group_key
        if class_name not in seen_classes:
            unique_class_groups[group_key] = elements
            seen_classes.add(class_name)

    # print("\n\n")
    # for class_name, elements in unique_class_groups.items():
    #     print(f"Class Group '{class_name[0]}' ({len(elements)} elements): {[element.name for element in elements]}")

    for group_key, elements in unique_class_groups.items():
        class_name, _ = group_key
        element_id = elements[0].get('id')
        if (re.search("(kampanya|kamp|campaign|camp|cmp|fırsat|firsat)", class_name, re.I) or 
            (element_id and re.search("(kampanya|kamp|campaign|camp|cmp|fırsat|firsat)", element_id, re.I))) and len(elements) > 1:
            return elements 

    unique_class_groups_copy = unique_class_groups.copy()
    for group_key, elements in unique_class_groups_copy.items():
        class_name, _ = group_key
        #  or re.search("(search|drawer|footer)", class_name, re.I)
        if not re.search("(box|item|content)", class_name, re.I):
            unique_class_groups.pop(group_key)
    print("\n\n")
    # for class_name, elements in unique_class_groups.items():
    #     print(f"Class Group '{class_name[0]}' ({len(elements)} elements): {[element.name for element in elements]}")
    return next(iter(unique_class_groups.values()))

def scrape_offers(baseUrl):
    site = baseUrl.split('/')[-1].split('.')[1].capitalize()

    offerPageLink = find_offer_tab.findOfferTab(baseUrl=baseUrl, header=header)
    
    print("Site: " + offerPageLink)
    offers = []
    if offerPageLink != "":
        i = 1
        print(len(getOfferCardArray(offerPageLink)))
        for offerCard in getOfferCardArray(offerPageLink):   
            print(offerCard.get("class"))
        # print("\n" +str(i) + "-------------------------------\n" + str(offerCard) + "\n" + str(i) +"-------------------------------\n")
            i += 1
            # if i == 2:
            #     break
            
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

            if offerLink != None:
                if not re.match(baseUrl, offerLink):
                    if not re.match("https", offerLink):
                        if offerLink !="":
                            if offerLink[0] == "/":
                                offerLink = baseUrl + offerLink
                            else:
                                offerLink = baseUrl + "/"+ offerLink
            else:
                offerLink = ""
            # print("Link: " + offerLink)
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
                offerTitle = offerStringList[0]
                del offerStringList[0]
                
            # Image
            isImageDynamic = False
            offerImageLink = ""
            offerImageSection = offerCard.find(class_=re.compile("(image|img)", re.I))
            if offerImageSection:
                offerImageLink = offerImageSection.get("src")
                if offerImageLink == None:
                    offerImageLink = offerCard.find("img").get("src")
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
            if offerImageLink != None:
                if not re.match(baseUrl, offerImageLink):
                    if not re.match("https://", offerImageLink):
                        offerImageLink = baseUrl + offerImageLink
                    
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
                if offerDescription != "":
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
                                startDate = dateFormater(startDateParts[0] + " " + dates[1].replace(u'\xa0', u' ').strip().split(" ")[1])
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

                        if startDate == "" and endDate == "":
                            singleDates = list(singleDatePatern.finditer(offerAllStrings))
                            match len(singleDates):
                                case 0:
                                    print("Date not found")
                                case 1:
                                    tmpEndDate = ""
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
                        for possibleDateString in campaignDetailStrings:
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
    print(len(offers))
    for o in offers:
        print("\nLink: " + o["link"],
               "\nTitle: " + o["title"],
               "\nDescription: " + o["description"],
               "\nImage: " + str(o["image"]),
               "\nStartDate: " + o["startDate"],
               "\nEndDate: " + o["endDate"],
               "\nSite: " + o["site"])
    else:
        print("ANA SAYFA")
        i = 1
        # for offerCard in getOfferCardArray(baseUrl):
        #     # print(offerCard.get("class"))
        #     # print("\n" +str(i) + "-------------------------------\n" + str(offerCard.get('class')) + "\n" + str(i) +"-------------------------------\n")
        #     i += 1

scrape_offers("https://www.tefal.com.tr")

# links = [
#     "https://www.altinyildizclassics.com",
#     "https://www.desa.com.tr",
#     "https://www.flo.com.tr",
#     "https://www.instreet.com.tr",
#     "https://www.koton.com",
#     "https://www.lumberjack.com.tr",
#     "https://www.mudo.com.tr",
#     "https://www.ninewest.com.tr",
#     "https://www.penti.com",
#     "https://www.reebok.com.tr",
#     "https://www.slazenger.com.tr",
#     "https://tr.uspoloassn.com",
#     "https://www.arcelik.com.tr",
#     "https://www.bosch-home.com.tr",
#     "https://www.kumtel.com",
#     "https://www.tefal.com.tr"
# ]
# for link in links:
#     scrape_offers(link)


# # Sonuçları yazdır
# for i, group in enumerate(sorted_groups):
#     print(f"Group {i + 1}:")
#     for element in group:
#         print(f"{element.name} - {element.get('class')} - {element.text.strip()}")

# def scrape_offers(baseUrl):
#     site = baseUrl.split('/')[-1].split('.')[1].capitalize()

#     offerPageLink = find_offer_tab.findOfferTab(baseUrl=baseUrl, header=header)
#     print(offerPageLink)

#     if offerPageLink != "":
#         i = 1
#         for offerCard in getOfferCardArray(offerPageLink):
#             # print(offerCard.get("class"))
#             print("\n" +str(i) + "-------------------------------\n" + str(offerCard) + "\n" + str(i) +"-------------------------------\n")
#             i += 1
# scrape_offers("https://www.bosch-home.com.tr")


# def check_and_collect_children(parent, offerCardArray):
#     # Get all children that are either "a" or "div"
#     children = [child for child in parent.children if child.name in ["a", "div"]]

#     if len(children) == 0:
#         return False

#     first_child_tag = children[0].name
#     first_child_classes = children[0].get('class', [])

#     # Check if all children have the same tag name (either all "a" or all "div") and the same class
#     if all(child.name == first_child_tag and child.get('class', []) == first_child_classes for child in children):
#         # If the number of these children is more than 2
#         if len(children) > 2:
#             offerCardArray.extend(children)
#             return True

#     # Recurse into each child
#     for child in children:
#         if check_and_collect_children(child, offerCardArray):
#             return True
    
#     return False

# def getOfferCardArray(offerPageLink):
#     httpRequest = requests.get(offerPageLink, headers=header)
#     parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "lxml")

#     possibleOfferSections = parsedOfferPageHtml.find_all("div", class_=re.compile("(kampanya|kamp|campaign)", re.I))
#     offerCardArray = []

#     for possibleOfferSection in possibleOfferSections:
        
#         if check_and_collect_children(possibleOfferSection, offerCardArray):
#             print("Found matching children.")
#             break

#     if len(offerCardArray) == 0:
#         tmp = ""
#         count = 0
#         for possibleOfferSection in possibleOfferSections:
#             # print("\n" + "-------------------------------\n" + str(possibleOfferSection) + "\n" +"-------------------------------\n")
#             if tmp == possibleOfferSection.get("class")[0]:
#                 count += 1
#                 break
#             else:
#                 tmp = possibleOfferSection.get("class")[0]
#                 print(tmp)
#                 count = 0

#         if count > 0:
#             return parsedOfferPageHtml.find_all("div", class_=re.compile(tmp, re.I))

#     print(len(offerCardArray))
#     return offerCardArray


# def check_and_collect_children(parent, offerCardArray):
#     # Get all children that are either "a" or "div"
#     children = [child for child in parent.children if child.name in ["a", "div"]]

#     if len(children) == 0:
#         return False

#     first_child_tag = children[0].name
#     first_child_classes = children[0].get('class', [])

#     # Check if all children have the same tag name (either all "a" or all "div") and the same class
#     if all(child.name == first_child_tag and child.get('class', []) == first_child_classes for child in children):
#         # If the number of these children is more than 2
#         if len(children) > 2:
#             offerCardArray.extend(children)
#             return True

#     # Recurse into each child
#     for child in children:
#         if check_and_collect_children(child, offerCardArray):
#             return True
    
#     return False

# def getOfferCardArray(offerPageLink):
#     httpRequest = requests.get(offerPageLink, headers=header)
#     parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "lxml")

#     possibleOfferSections = parsedOfferPageHtml.find_all("div", class_=re.compile("(kampanya|kamp|campaign)", re.I))
#     offerCardArray = []

#     for possibleOfferSection in possibleOfferSections:
        
#         if check_and_collect_children(possibleOfferSection, offerCardArray):
#             print("Found matching children.")
#             break

#     if len(offerCardArray) == 0:
#         tmp = ""
#         count = 0
#         for possibleOfferSection in possibleOfferSections:
#             # print("\n" + "-------------------------------\n" + str(possibleOfferSection) + "\n" +"-------------------------------\n")
#             if tmp == possibleOfferSection.get("class")[0]:
#                 count += 1
#                 break
#             else:
#                 tmp = possibleOfferSection.get("class")[0]
#                 print(tmp)
#                 count = 0

#         if count > 0:
#             return parsedOfferPageHtml.find_all("div", class_=re.compile(tmp, re.I))

#     print(len(offerCardArray))
#     return offerCardArray
