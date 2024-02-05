import requests
import pandas as pd
from bs4 import BeautifulSoup
import re
import firebase_operations

baseUrl = "https://www.isbank.com.tr"
header = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/119.0.0.0 Safari/537.36"
}

site = baseUrl.split('/')[-1].split('.')[1].capitalize()

campaigns = []
httpRequest = requests.get(baseUrl, headers=header)
parsedHomeHtml = BeautifulSoup(httpRequest.text, "html.parser")
campaignPageTagList = parsedHomeHtml.find_all(
    "a", string=re.compile("kampanya", re.I))

campaignPageLinkList = []
for iterTag in campaignPageTagList:
    campaignPageLinkList.append(iterTag.get("href"))

campaignPageLink = ""
for iterPageLink in campaignPageLinkList:
    if campaignPageLink == "":
        campaignPageLink = iterPageLink
    else:
        if len(iterPageLink) < len(campaignPageLink):
            campaignPageLink = iterPageLink

if not re.match(baseUrl, campaignPageLink):
    campaignPageLink = baseUrl + campaignPageLink

print(campaignPageLink)

if campaignPageLink != "":
    httpRequest = requests.get(campaignPageLink, headers=header)
    parsedCampaignPageHtml = BeautifulSoup(httpRequest.text, "html.parser")
    campaignSection = parsedCampaignPageHtml.find("div", class_=re.compile("(kampanya|kamp)", re.I))
    campaignCardArr = campaignSection.find_all("div", class_="kamp_cards33C")
    for campaignCard in campaignCardArr:
        campaignLink = campaignCard.find("a").get("href")#Link
        if not re.match(baseUrl, campaignLink):
            campaignLink = baseUrl + campaignLink

        campaignTitle = campaignCard.find(class_=re.compile("title", re.I)).string.strip()#Title

        campaignDescription = campaignCard.find(class_=re.compile("(description|desc)", re.I)).string.strip()#Description

        campaignImageLink = campaignCard.find(class_=re.compile("(image|img)", re.I)).find("img").get("src")#Image
        if not re.match(baseUrl, campaignImageLink):
            campaignImageLink = baseUrl + campaignImageLink

        dateSection = campaignCard.find(class_=re.compile("date", re.I))#Date
        campaignEndDate = dateSection.find(string=re.compile("(\d{2})[/.-](\d{2})[/.-](\d{4})$"))
        
        campaign = {
            "Link": campaignLink,
            "Title" : campaignTitle,
            "Description" : campaignDescription,
            "Image": campaignImageLink,
            "StartDate" : "-",
            "EndDate" : campaignEndDate,
            "Site": site
        }

        campaigns.append(campaign)
else:
    print("Search in slider")

firebase_operations.add_campaigns_to_firestore(campaigns, site)