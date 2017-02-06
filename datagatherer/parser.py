#!/usr/bin/env python
import pprint
from bs4 import BeautifulSoup


pp = pprint.PrettyPrinter(indent=4)
with open("hipchat_history.html", "r") as rawDataFile:
    html_doc = rawDataFile.read()


soup = BeautifulSoup(html_doc, 'html.parser')
# print(soup.prettify())


def getAllDates(soup):
    return soup.find_all("span", {"class": "aOM"})

def getAllAzf(soup):
    return soup.find_all("div", {"class": "aZf"})


allDates = getAllDates(soup)
allAzf = getAllAzf(soup)

# pp.pprint(getAllAzf(soup))
print("Number of dates: %d\n" % len(allDates))
print("Number of containers?: %d\n" % len(allAzf))

pp.pprint(allAzf[0]);