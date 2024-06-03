import requests
from bs4 import BeautifulSoup
import re
import find_offer_tab
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import unicodedata
import datetime
import json
import time
from collections import deque, defaultdict

header = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/119.0.0.0 Safari/537.36"
}

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
def clean_text(text):
    # Normalize unicode text to NFKD form and remove non-ASCII characters
    normalized_text = unicodedata.normalize('NFKD', text)
    ascii_text = re.sub(r'[^\x00-\x7F]', '', normalized_text)
    return ascii_text.strip()    

def count_words_in_children(children):
    word_count = 0
    wanted_roots = {'kampanya', 'indirim','lira','taksit','hediye','kupon','fırsat','hediye çeki','kazan',}
    
    for child in children:
        text = child.string if child.string is not None else child.get_text()
        if text:
            clean = clean_text(text)
            lower_text = clean.lower()
            # print("Cleaned and lowercase text:", lower_text)  # Debug print
            if any(root in lower_text for root in wanted_roots):
                word_count += len(lower_text.split())
                print("Word count after counting:", word_count)  # Debug print
    
    return word_count


def check_and_collect_children(parent, offerCardArray):
    # if 'container' in parent.get("class", []):

       
        print("---------------Parent: ")
        if parent.get("class") is not None and 'h' in parent.get("class",[]):
            print(parent)
        else:
            print(parent.get("class"))
    
        # Get all children that are either "a" or "div"
        children = [child for child in parent.children if child.name in ["a", "div","li","section"]]
        #print(len(children))
        if len(children) <=2:
            return False
        
        first_child_tag = children[1].name if children else None
        first_child_classes = children[1].get('class', []) if children else []

        unwanted_keywords = {'footer', 'navigation', 'menu','mega','category'}
        # Check if all children have the same tag name and the same class
        valid_children = [
        child for child in children
        if child.get('class',[]) and 
           child.name == first_child_tag and 
           child.get('class', []) == first_child_classes and 
           not any(keyword in cls.lower() for cls in child.get('class', []) for keyword in unwanted_keywords)
        ]
        for child in valid_children:
            print(f"Tag: {child.name}, Classes: {child.get('class', [])}")
    # If there are any children that don't meet the conditions
        if len(valid_children) != len(children):
            print("here")
            print(len(valid_children))
            if(len(valid_children)>2):
                
                if count_words_in_children(valid_children) > 3 * len(valid_children):
                    offerCardArray.extend(valid_children)
                    return True
        else:
            print("here2")
            if len(valid_children) > 2:
                print(len(valid_children))
                print("here3")
                print(count_words_in_children(valid_children))
                if count_words_in_children(valid_children) > 3 * len(valid_children):
                    print("here4")
                    print(count_words_in_children(valid_children))
                    offerCardArray.extend(valid_children)
                    return True       

    # Recurse into each child if the condition is not met
        for child in children:
            if check_and_collect_children(child, offerCardArray):
                return True

        return False
def dynamicHtml(offerPageLink):
    httpRequest = requests.get(offerPageLink, headers=header)
    parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "lxml")
    chrome_options = Options()
    chrome_options.add_argument("webdriver.chrome.driver=backend/chromedriver.exe")
    driver = webdriver.Chrome(options=chrome_options)
    driver.get(offerPageLink)
    time.sleep(5)
    parsedOfferPageHtml = BeautifulSoup(driver.page_source, "html.parser")
    driver.quit()
    return parsedOfferPageHtml
    
def getOfferCardArray(offerPageLink):
    parsedOfferPageHtml = dynamicHtml(offerPageLink)
    body=parsedOfferPageHtml.find("body")
    offerCardArray = []
    pattern=re.compile("kampanya|indirim",re.I)
    possibleOfferSections=[]
    for element in body.find_all(True):
        if element.get_text() and pattern.search(element.get_text()) and 'footer' not in element.get("class",[]):
           possibleOfferSections.append(element)
    
    for possibleOfferSection in possibleOfferSections:
        
        if check_and_collect_children(possibleOfferSection, offerCardArray):
            print("Found matching children.")
            break
        
    # if len(offerCardArray) == 0:
    #     tmp = ""
    #     count = 0
    #     for possibleOfferSection in possibleOfferSections:
    #         # print("\n" + "-------------------------------\n" + str(possibleOfferSection) + "\n" +"-------------------------------\n")
    #         if possibleOfferSection.get("class") is not None:
    #             if tmp == possibleOfferSection.get("class")[0]:
    #                 count += 1
    #                 break
    #             else:
    #                 tmp = possibleOfferSection.get("class")[0]
    #                 print(tmp)
    #                 count = 0

    #     if count > 0:
    #         return parsedOfferPageHtml.find_all("div", class_=re.compile(tmp, re.I))

    # print(len(offerCardArray))
    return offerCardArray

def scrape_offers(baseUrl):
    site = baseUrl.split('/')[-1].split('.')[1].capitalize()

    offerPageLink = find_offer_tab.findOfferTab(baseUrl=baseUrl, header=header)
    print("\n")
    print("Link:\n")
    print(offerPageLink)
    offerCardArray=[]
    offerCardArray=getOfferCardArray(offerPageLink)
    print("Size: " + str(len(offerCardArray)))
    for offerCard in offerCardArray:
        print(offerCard.name)
        #print(offerCard)
        print(offerCard.get("class"))
#     offers = []
#     if offerPageLink != "":
#         n = 0
#         for offerCard in getOfferCardArray(offerPageLink):
#             # n += 1
#             # if n == 3:
#             #     break

#             #Extract offer strings
#             offerStringList = list(offerCard.stripped_strings)
#             offerAllStrings = ' '.join(offerCard.stripped_strings)

#             #Link
#             offerLink = ""
#             if(offerCard.find("a")):
#                 for link in offerCard.find_all("a"):
#                     offerLink = link.get("href")
#                     if offerLink != None:    
#                         if re.match("/", offerLink):
#                             break
#             else:
#                 offerLink = offerCard.get("href")

#             if offerLink != None:
#                 if not re.match(baseUrl, offerLink)
#                     if not re.match("https", offerLink):
#                         if offerLink !="":
#                             if offerLink[0] == "/":
#                                 offerLink = baseUrl + offerLink
#                             else:
#                                 offerLink = baseUrl + "/"+ offerLink
#             else:
#                 offerLink = ""
#             print("Link: " + offerLink)
#             #Title
#             offerTitleSection = offerCard.find(class_=re.compile("(title|head)", re.I))
#             offerTitle = ""
#             if offerTitleSection:
#                 if offerTitleSection.string:
#                     offerTitle = offerTitleSection.string.strip()
#                 else:
#                     offerTitle = offerTitleSection.find(re.compile("h"))
#                     if offerTitle != None:
#                         offerTitle = offerTitle.string.strip()

#                 if offerTitle == None:
#                     offerTitle = ""
#                     for sec in offerTitleSection.children: 
#                         if not re.search("koşul", sec.text, re.I):
#                             offerTitle += sec.text.strip()
#             else:
#                 offerTitle = offerStringList[0]
#                 del offerStringList[0]
                
#             # Image
#             isImageDynamic = False
#             offerImageLink = ""
#             offerImageSection = offerCard.find(class_=re.compile("(image|img)", re.I))
#             if offerImageSection:
#                 offerImageLink = offerImageSection.get("src")
#                 if offerImageLink == None:
#                     offerImageLink = offerCard.find("img").get("src")
#             else:
#                 if offerCard.find("img"):
#                     offerImageLink = offerCard.find("img").get("src")
#                 if offerImageLink == None:
#                     if offerCard.find("img"):
#                         offerImageLink = offerCard.find("img").get("data-src")
#                 if offerImageLink == "":
#                     if offerCard.find('div', style=re.compile("(image|img)", re.I)):
#                         isImageDynamic = True
#                         style=offerCard.find('div', style=re.compile("(image|img)", re.I)).get("style")
#                         url_pattern = re.compile(r"url(['\"]?(.*?)['\"]?)")
#                         match = url_pattern.search(style)
#                         offerImageLink = match.group(1) if match else None
#             # print(offerImageLink)
#             if offerImageLink != None:
#                 if not re.match(baseUrl, offerImageLink):
#                     if not re.match("https://", offerImageLink):
#                         offerImageLink = baseUrl + offerImageLink
                    
#             # Description
#             offerDescriptionSection = offerCard.find(class_=re.compile("(description|desc)", re.I))
#             if offerDescriptionSection:
#                 if(offerDescriptionSection.string):
#                     offerDescription = offerDescriptionSection.string.strip()
#                 else:
#                     offerDescription = offerDescriptionSection.find(re.compile("h")).string.strip()
#             else:
#                 offerDescription = ""
#                 if offerTitleSection:
#                     possibleDescriptionSections = []
#                     for possibleSection in offerTitleSection.next_siblings:
#                         if possibleSection.name: 
#                             for child in possibleSection.find_all(re.compile("h|span|p|li")):
#                                 possibleDescriptionSections.append(child)
#                     for section in possibleDescriptionSections:
#                         try:
#                             if not re.search("koşul", section.text, re.I):
#                                 offerDescription += section.text.strip() + " "
#                         except:
#                             continue
#                     if offerDescription == "":
#                         for string in offerStringList:
#                             offerDescription += string.strip() + " "
#                     if len(offerDescription) < 20:
#                         offerDescription = ""
#                 else:
#                     offerDescription = " ".join(offerStringList)

#             #Date
#             startDate = ""
#             endDate = ""
#             dateRanges = None
#             dateSection = offerCard.find(class_=re.compile("date", re.I))
#             if dateSection:
#                 singleDates = list(singleDatePatern.finditer(dateSection.get_text()))
#                 match len(singleDates):
#                     case 0:
#                         print("Date not found")
#                     case 1:
#                         endDate = dateFormater(singleDates[0].group())
#                         dateRanges = list(dateRangePatern.finditer(offerDescription))
#                         if dateRanges:
#                             dateRange = dateRanges[-1].group()
#                             dates = list(digitDatePatern.finditer(dateRange))
#                             if dates:
#                                 tmpStartDate = dates[0].group()
#                                 tmpEndDate = dates[1].group()
#                             else:
#                                 dates = dateRange.split("-")
#                                 tmpEndDate = dateFormater(dates[1].strip())
#                                 startDateParts = dates[0].strip().split(" ")
#                                 if len(startDateParts) < 2:
#                                     tmpStartDate = dateFormater(startDateParts[0] + " " + dates[1].strip().split(" ")[1])
#                                 else: 
#                                     tmpStartDate = dateFormater(dates[0].strip())
#                                 if endDate == tmpEndDate:
#                                     startDate = tmpStartDate
#                     case 2:
#                         startDate = dateFormater(singleDates[0].group())
#                         endDate = dateFormater(singleDates[1].group())
#                     case default:
#                         startDate = dateFormater(singleDates[-2].group())
#                         endDate = dateFormater(singleDates[-1].group())
#             else:
#                 if offerDescription != "":
#                     dateRanges = list(dateRangePatern.finditer(offerDescription))
#                     if dateRanges:
#                         dateRange = dateRanges[-1].group()
#                         dates = list(digitDatePatern.finditer(dateRange))
#                         if dates:
#                             startDate = dates[0].group()
#                             endDate = dates[1].group()
#                         else:
#                             dates = dateRange.split("-")
#                             endDate = dateFormater(dates[1].strip())
#                             startDateParts = dates[0].strip().split(" ")
#                             if len(startDateParts) < 2:
#                                 startDate = dateFormater(startDateParts[0] + " " + dates[1].replace(u'\xa0', u' ').strip().split(" ")[1])
#                             else: 
#                                 startDate = dateFormater(dates[0].strip())
#                     else:
#                         singleDates = list(singleDatePatern.finditer(offerDescription))
#                         match len(singleDates):
#                             case 0:
#                                 print("Date not found")
#                             case 1:
#                                 startDate = ""
#                                 endDate = dateFormater(singleDates[0].group())
#                             case 2:
#                                 startDate = dateFormater(singleDates[0].group())
#                                 endDate = dateFormater(singleDates[1].group())
#                             case default:
#                                 startDate = dateFormater(singleDates[-2].group())
#                                 endDate = dateFormater(singleDates[-1].group())

#                         if startDate == "" and endDate == "":
#                             singleDates = list(singleDatePatern.finditer(offerAllStrings))
#                             match len(singleDates):
#                                 case 0:
#                                     print("Date not found")
#                                 case 1:
#                                     tmpEndDate = ""
#                                     endDate = dateFormater(singleDates[0].group())
#                                     dateRanges = list(dateRangePatern.finditer(offerDescription))
#                                     if dateRanges:
#                                         dateRange = dateRanges[-1].group()
#                                         dates = list(digitDatePatern.finditer(dateRange))
#                                         if dates:
#                                             tmpStartDate = dates[0].group()
#                                             tmpEndDate = dates[1].group()
#                                         else:
#                                             dates = dateRange.split("-")
#                                             tmpEndDate = dateFormater(dates[1].strip())
#                                             startDateParts = dates[0].strip().split(" ")
#                                             if len(startDateParts) < 2:
#                                                 tmpStartDate = dateFormater(startDateParts[0] + " " + dates[1].strip().split(" ")[1])
#                                             else: 
#                                                 tmpStartDate = dateFormater(dates[0].strip())
#                                     if endDate == tmpEndDate:
#                                         startDate = tmpStartDate
#                                 case 2:
#                                     startDate = dateFormater(singleDates[0].group())
#                                     endDate = dateFormater(singleDates[1].group())
#                                 case default:
#                                     startDate = dateFormater(singleDates[-2].group())
#                                     endDate = dateFormater(singleDates[-1].group())

#                 if startDate == "" and endDate == "" and offerLink != "":
#                     httpRequest = requests.get(offerLink, headers=header)
#                     parsedOfferDetailPageHtml = BeautifulSoup(httpRequest.text, "lxml")
#                     dPCampaignSections = parsedOfferDetailPageHtml.find_all("div", {"class": re.compile("(kampanya|kamp|campaign|detay)", re.I)}) + parsedOfferDetailPageHtml.find_all("div", {"id": re.compile("(kampanya|kamp|campaign)", re.I)})
                    
#                     campaignDetailStrings = []
#                     for dPCampaignSection in dPCampaignSections:
#                         if dPCampaignSection.stripped_strings:
#                             campaignDetailStrings += [text.strip() for text in dPCampaignSection.stripped_strings]
                    
#                     if offerDescription == "":
#                         offerDescription = " ".join(campaignDetailStrings)
#                         dateRanges = list(dateRangePatern.finditer(offerDescription))
#                         if dateRanges:
#                             dateRange = dateRanges[-1].group()
#                             dates = list(digitDatePatern.finditer(dateRange))
#                             if dates:
#                                 startDate = dates[0].group()
#                                 endDate = dates[1].group()
#                             else:
#                                 dates = dateRange.split("-")
#                                 endDate = dateFormater(dates[1].strip())
#                                 startDateParts = dates[0].strip().split(" ")
#                                 if len(startDateParts) < 2:
#                                     startDate = dateFormater(startDateParts[0] + " " + dates[1].strip().split(" ")[1])
#                                 else: 
#                                     startDate = dateFormater(dates[0].strip())
#                         else:
#                             singleDates = list(singleDatePatern.finditer(offerDescription))
#                             match len(singleDates):
#                                 case 0:
#                                     print("Date not found")
#                                 case 1:
#                                     startDate = ""
#                                     endDate = dateFormater(singleDates[0].group())
#                                 case 2:
#                                     startDate = dateFormater(singleDates[0].group())
#                                     endDate = dateFormater(singleDates[1].group())
#                                 case default:
#                                     startDate = dateFormater(singleDates[-2].group())
#                                     endDate = dateFormater(singleDates[-1].group())
#                     else:
#                         for possibleDateString in campaignDetailStrings:
#                             dateRanges = list(dateRangePatern.finditer(possibleDateString))
#                         if dateRanges:
#                             dateRange = dateRanges[-1].group()
#                             dates = list(digitDatePatern.finditer(dateRange))
#                             if dates:
#                                 startDate = dates[0].group()
#                                 endDate = dates[1].group()
#                             else:
#                                 dates = dateRange.split("-")
#                                 endDate = dateFormater(dates[1].strip())
#                                 startDateParts = dates[0].strip().split(" ")
#                                 if len(startDateParts) < 2:
#                                     startDate = dateFormater(startDateParts[0] + " " + dates[1].strip().split(" ")[1])
#                                 else: 
#                                     startDate = dateFormater(dates[0].strip())
#                         else:
#                             singleDates = list(singleDatePatern.finditer(offerDescription))
#                             match len(singleDates):
#                                 case 0:
#                                     print("Date not found")
#                                 case 1:
#                                     startDate = ""
#                                     endDate = dateFormater(singleDates[0].group())
#                                 case 2:
#                                     startDate = dateFormater(singleDates[0].group())
#                                     endDate = dateFormater(singleDates[1].group())
#                                 case default:
#                                     startDate = dateFormater(singleDates[-2].group())
#                                     endDate = dateFormater(singleDates[-1].group())
                        
#             offer = {
#                 "link": offerLink,
#                 "title" : offerTitle,
#                 "description" : offerDescription,
#                 "image": offerImageLink,
#                 "startDate" : startDate,
#                 "endDate" : endDate,
#                 "site": site
#             }
#             # print(offer)
#             offers.append(offer)
#     else:
#         print("Search in slider")

#     for o in offers:
#         print("\nLink: " + o["link"],
#                "\nTitle: " + o["title"],
#                "\nDescription: " + o["description"],
#                "\nImage: " + str(o["image"]),
#                "\nStartDate: " + o["startDate"],
#                "\nEndDate: " + o["endDate"],
#                "\nSite: " + o["site"])

altin = "https://www.altinyildizclassics.com" #ok
ets = "https://www.etstur.com"   #ok
isbank = "https://www.isbank.com.tr"   #ok
garanti = "https://www.garantibbva.com.tr"   #ok
ebebek = "https://www.e-bebek.com"    #ok
vakif = "https://www.vakifbank.com.tr"    #ok
teb = "https://www.teb.com.tr"   #ok
karaca="https://www.karaca.com"   #ok
akbank = "https://www.akbank.com"  #değil
kuveyt = "https://www.kuveytturk.com.tr"
yapikredi = "https://www.yapikredi.com.tr"
halk = "https://www.halkbank.com.tr"
deniz = "https://www.denizbank.com"
qnb = "https://www.qnbfinansbank.com"
ing = "https://www.ing.com.tr"
bankkart = "https://www.bankkart.com.tr"   #dynamic

flo = "https://www.flo.com.tr"
instreet = "https://www.instreet.com.tr"
adidas = "https://www.adidas.com.tr"
nike = "https://www.nike.com"
puma = "https://tr.puma.com"
reebok = "https://www.reebok.com.tr"
newbalance = "https://www.newbalance.com.tr" #kampanya linkinde ürün var
superstep = "https://www.superstep.com.tr"
ayakkabidunyasi = "https://www.ayakkabidunyasi.com.tr"   #kampanya linkinde ürün var
lumber = "https://www.lumberjack.com.tr"

tefal = "https://www.tefal.com.tr"
defacto = "https://www.defacto.com.tr"
enza = "https://www.enzahome.com.tr"
hotiç="https://www.thenorthface.com.tr"
koton= "https://www.koton.com" #yanlıs card buluo :(

scrape_offers(koton)
# scrape_offers(superstep)
# scrape_offers(kuveyt)   #calısmıyor
# scrape_offers(isbank)
# scrape_offers(altin)
# scrape_offers(ebebek)
# scrape_offers(teb)
# scrape_offers(flo)
# scrape_offers(lumber)
# scrape_offers(ets)
# scrape_offers(karaca) #parentı buluo :(
# scrape_offers(instreet)
# scrape_offers(reebok)
# scrape_offers(tefal)
# scrape_offers(defacto)
# scrape_offers(bankkart)

# def getOfferCardArray(offerPageLink):
#     httpRequest = requests.get(offerPageLink, headers=header)
#     parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "lxml")
    
#     possibleOfferSections = parsedOfferPageHtml.find_all("div", class_=re.compile("(kampanya|kamp|campaign)", re.I))
#     # print(parsedOfferPageHtml)
#     i = 1
#     for possibleOfferSection in possibleOfferSections:
#         print("\n" +str(i) + "-------------------------------\n" + str(possibleOfferSections) + "\n" + str(i) +"-------------------------------\n")
#         i += 1

#     for possibleOfferSection in possibleOfferSections:
#         offerCardArray = []
#         for child in possibleOfferSection.contents:
#             if child.name:
#                 offerCardArray.append(child)
#         offerCardArrayLen = len(offerCardArray)
#         if offerCardArrayLen > 1:
#             try:
#                 if offerCardArray[0]['class'][0] == offerCardArray[1]['class'][0]:
#                     print(offerCardArrayLen)
#                     break
#             except:
#                 continue

#     print(offerCardArray)
#     i = 1
#     for offerCard in offerCardArray:
#         print("\n" +str(i) + "-------------------------------\n" + str(offerCard) + "\n" + str(i) +"-------------------------------\n")
#         i += 1
#     return offerCardArray


# def getOfferCardArray(offerPageLink):
#     httpRequest = requests.get(offerPageLink, headers=header)
#     parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "lxml")

#     possibleOfferSections = parsedOfferPageHtml.find_all("div", class_=re.compile("(kampanya|kamp|campaign)", re.I))
#     offerCardArray = []

#     for possibleOfferSection in possibleOfferSections:
#         # print(possibleOfferSection.get("class"))
        
#         if check_and_collect_children(possibleOfferSection, offerCardArray):
#             print("Found matching children.")
#             break  # Stop processing further sections if condition is met

#     # Debugging output (optional)
#     # i = 1
#     # for offerCard in offerCardArray:
#     #     print(f"\n{i}-------------------------------\n{offerCard}\n{i}-------------------------------\n")
#     #     i += 1
#     print(len(offerCardArray))
#     return offerCardArray