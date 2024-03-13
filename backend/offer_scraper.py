import requests
from bs4 import BeautifulSoup
import re
import firebase_operations
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
# instreet = "https://www.instreet.com.tr"

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
        

def scrape_offers(baseUrl, firestoreDb):
    site = baseUrl.split('/')[-1].split('.')[1].capitalize()

    offers = []
    offerPageLink = find_offer_tab.findOfferTab(baseUrl=baseUrl, header=header)

    if offerPageLink != "":
        httpRequest = requests.get(offerPageLink, headers=header)
        parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "lxml")
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
            if(offerCard.find("a")):
                offerLink = offerCard.find("a").get("href")
            else:
                offerLink = offerCard.get("href")
            if not re.match(baseUrl, offerLink):
                offerLink = baseUrl + offerLink

            #Title
            offerTitleSection = offerCard.find(class_=re.compile("title", re.I))
            if(offerTitleSection.string):
                offerTitle = offerTitleSection.string.strip()
            else:
                offerTitle = offerTitleSection.find(re.compile("h")).string.strip()
            
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
                    print("2)Alt linke git")
            
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
        #print("Search in slider")
        httpRequest = requests.get(base_url, headers=header)
        parsedOfferPageHtml = BeautifulSoup(httpRequest.text, "html.parser")
        #print(parsedOfferPageHtml.prettify)
        # sliderInner=parsedOfferPageHtml.find("div",class_="swiper swiper-initialized swiper-horizontal swiper-pointer-events")
        # print(sliderInner.prettify)
        sliderInner=parsedOfferPageHtml.find(["section","div","li","ul"],class_=re.compile("swiper-wrapper|home-slider|banner owl|slider-component|hero-slider|slick-list|carousel__wrapper|owl-stage|slick-track", re.I))
        #print(sliderInner)
        offerList=sliderInner.find_all(["div","a","img","li","ul"],class_=re.compile("item|swiper-slide|slider|slick-slide|carousel-slide|owl-item|slick-slide|uk-slider-items",re.I))  
        print(len(offerList))
        #print(offerList)
        count=0
        # offerLinks=[]
        offerImageLink=""
        for offerCard in offerList:
            print(count)
            # print("offer:\n")
            # print(offerCard)
            # print("\n")
            offerImageLink=""
            if offerCard.name=="img":
                offerImageLink=offerCard.get("src") or offerCard.find("img").get("data-src")
                #print("gets1 here\n")
                print(offerImageLink)
                print("\n")
            else :
                if offerCard.name=="a":
                    offerLink=offerCard.get("href")
                    offerImageLink=offerCard.find("img").get("src") or offerCard.find("img").get("data-src")
                    #print("gets2 here\n")
                    print(offerImageLink)
                elif offerCard.find("a") is not None:
                    #print("aaaa")
                    offerLink=offerCard.find("a").get("href")
                    if offerImageLink=="":
                        if offerCard.find("a").find("img") is not None:
                            offerImageLink=offerCard.find("a").find("img").get("src") or offerCard.find("a").find("img").get("data-src")
                            #print("gets3 here\n")
                            print(offerImageLink)
                if not re.match("https://", offerLink):
                        offerLink = base_url + offerLink
                print(offerLink)
                count=count+1
                # if offerLink not in offerLinks:
                #      if count < len(offerLinks):
                #         offerLinks[count] = offerLink
                #      else:
                #         offerLinks.append(offerLink)
                #         count += 1
            jsonStr = ocr_space_url(url=offerImageLink)
            #print(jsonStr)
            data_dict = json.loads(jsonStr)
            if "ParsedResults" in data_dict and data_dict["ParsedResults"]:
            # "ParsedResults" listesi var mı ve boş değil mi kontrolü
                parsed_text = data_dict["ParsedResults"][0]["ParsedText"]
                print(parsed_text)
            elif "ErrorMessage" in data_dict:
            # API'den gelen bir hata mesajı varsa
                if "Rate limit exceeded" in data_dict["ErrorMessage"]:
                    handle_rate_limit()
                else:
                    print("OCR işlemi başarısız oldu. Hata mesajı:", data_dict["ErrorMessage"])
            else:
                print("OCR işlemi başarısız oldu veya sonuç alınamadı.")
            lines = parsed_text.split('\n')
            offerTitle=""
            offerDescription=""
            startDate=""
            endDate=""
            
            if(base_url=="https://www.columbia.com.tr"):
                discount_index = next((index for index, line in enumerate(lines) if "İNDİRİM" in line), None)

                if discount_index is not None:
                # Assign the expression "DISCOUNT" and the lines 2 lines after it to offerDescription

                # Extract the 2nd word 2 lines after "DISCOUNT" to startDate
                    if discount_index + 2 < len(lines):
                        offerDescription = '\n'.join(lines[discount_index + 2:]).strip()
                    else:
                        offerDescription = None
                # Assign the first 3 words of the first line to offerTitle, or the first 2 words if not enough words
                
                    if discount_index > 0:
                        offerTitle = ' '.join(lines[discount_index - 1].split()[:2]).strip()
                    else:
                        offerTitle = None

                    if discount_index + 2 < len(lines):
                        startDate = lines[discount_index + 2].split()[1]
                        if len(lines[discount_index + 2].split()) >= 4:
                            endDate = ' '.join(lines[discount_index + 2].split()[2:4])
                        else:
                            endDate = None
                    else:
                        startDate = None
                        endDate = None
                else:
                    start_shopping_index = next((index for index, line in enumerate(lines) if "ALIŞVERİŞE BAŞLA" in line), None)
                    if start_shopping_index is not None:
                        if start_shopping_index + 1 < len(lines):
                            offerDescription = lines[start_shopping_index + 1].strip()
                        else:
                            offerDescription = None
                        if start_shopping_index > 0:
                            offerTitle = ' '.join(lines[start_shopping_index - 1].split()[:2]).strip()
                        else:
                            offerTitle = None
                    # Extract the 2nd word in offerDescription to startDate
                        if offerDescription:
                            startDate = offerDescription.split()[1]

                        # Extract the 3rd and 4th words in offerDescription to endDate
                            if len(offerDescription.split()) >= 3:
                                endDate = ' '.join(offerDescription.split()[2:4])
                            else:
                                endDate = None
                        else:
                            startDate = endDate = None
                    else:
                        offerDescription = offerTitle = startDate = endDate = None
                print("Offer Description:", offerDescription)
                print("Offer Title:", offerTitle)
                print("Start Date:", startDate)
                print("End Date:", endDate)
                
            else:
                # Find the line containing the expression "DISCOUNT"
                discount_index = next((index for index, line in enumerate(lines) if "İNDİRİM" in line or "indirim" in line or "İndirim" in line), None)

                if discount_index is not None:
                     # Add the line containing "DISCOUNT" to offerTitle
                    offerTitle = lines[discount_index].strip()

                    # Assign the line containing "DISCOUNT" to offerDescription, along with lines before and after
                    offerDescription_lines = lines[max(0, discount_index - 1):discount_index + 2]
                    offerDescription = '\n'.join(offerDescription_lines).strip()

                else:
                    offerTitle = offerDescription = None

                # Print the results
                print("Offer Title:", offerTitle)
                print("Offer Description:", offerDescription)

    scraped_site = {
        "site_name": site,
        "url": baseUrl,
        "scraping_date": datetime.date.today().strftime("%d-%m-%Y"),
    }

    firebase_operations.add_scraped_site(scraped_site, firestoreDb)
    firebase_operations.add_offers_to_firestore(offers, firestoreDb)

    # for o in offers:
    #     print("\n\nLink: " + o["Link"],
    #             "\nTitle: " + o["Title"],
    #             "\nDescription: " + o["Description"],
    #             "\nImage: " + o["Image"],
    #             "\nStartDate: " + o["StartDate"],
    #             "\nEndDate: " + o["EndDate"],
    #             "\nSite: " + o["Site"])

# scrape_offers(altin)
# scrape_offers(ets)
# scrape_offers(isbank)
# scrape_offers(instreet)

