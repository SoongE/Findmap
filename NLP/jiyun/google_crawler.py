from urllib.parse import quote_plus
from bs4 import BeautifulSoup as bs
import time
import requests

def get_url(soup):
    selectors = soup.select('#main > footer > div > div > div > a[href]')
    new_url = ""
    for link in selectors:
        new_url = link['href']
        break
    return new_url

def find_title_url(soup):
    for x in soup.find_all("h3", {"class": "zBAuLc"}):
        try:
            href = x.find_parent()['href']
            page_list[x.text.strip()] = href[7:]
        except:
            continue

def get_soup(source):
    req = requests.get(source)
    html = req.text
    soup = bs(html, "html.parser")
    return soup


base_url = 'https://www.google.co.kr/search?q='
google_url = 'https://www.google.co.kr'
plus_url = input('검색어 입력하세요 (이건 나중에 node에서 받아서 검색하는 식으로 바뀌겠지): ')

page_list = dict()

start = time.time()

# scrap first page
url = base_url + quote_plus(plus_url)
soup = get_soup(url)
page2 = get_url(soup)
find_title_url(soup)

# scrap second page
url = base_url + page2
soup = get_soup(url)
page3 = get_url(soup)
find_title_url(soup)

# scrap third page
url = base_url + page3
soup = get_soup(url)
find_title_url(soup)

print("time: ", time.time() - start)

for k, v in page_list.items():
    print(k, v)
