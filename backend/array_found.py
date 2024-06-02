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

    print("\n\n")
    for class_name, elements in unique_class_groups.items():
        print(f"Class Group '{class_name[0]}' ({len(elements)} elements): {[element.name for element in elements]}")

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
    for class_name, elements in unique_class_groups.items():
        print(f"Class Group '{class_name[0]}' ({len(elements)} elements): {[element.name for element in elements]}")
    return next(iter(unique_class_groups.values()))

def scrape_offers(baseUrl):
    site = baseUrl.split('/')[-1].split('.')[1].capitalize()

    offerPageLink = find_offer_tab.findOfferTab(baseUrl=baseUrl, header=header)
    
    print("Site: " + offerPageLink)

    if offerPageLink != "":
        i = 1
        for offerCard in getOfferCardArray(offerPageLink):
            # print(offerCard.get("class"))
            # print("\n" +str(i) + "-------------------------------\n" + str(offerCard) + "\n" + str(i) +"-------------------------------\n")
            i += 1
            # if i == 2:
            #     break
    else:
        print("ANA SAYFA")
        i = 1
        for offerCard in getOfferCardArray(baseUrl):
            # print(offerCard.get("class"))
            # print("\n" +str(i) + "-------------------------------\n" + str(offerCard.get('class')) + "\n" + str(i) +"-------------------------------\n")
            i += 1

scrape_offers("https://www.instreet.com.tr")

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
