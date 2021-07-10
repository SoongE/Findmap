from urllib.request import urlopen
from urllib.error import HTTPError, URLError
import urllib.robotparser
from bs4 import BeautifulSoup as bs
from selenium import webdriver
from selenium.webdriver.chrome.options import Options


class Crawler:

    def __init__(self, url):
        self.url = url
        self.html = ""
        self.soup = ""

        chrome_options = Options()
        chrome_options.add_argument('--headless')
        chrome_options.add_argument('--no-sandbox')
        chrome_options.add_argument('--disable-dev-shm-usage')
        self.driver = webdriver.Chrome('/workspace/chromedriver', chrome_options=chrome_options)

    def robots_check(self):
        rp = urllib.robotparser.RobotFileParser()
        rp.set_url(self.url)
        rp.read()
        check = rp.can_fetch("*", self.url)
        return check

    def url_connect(self):
        try:
            page = urlopen(self.url)
            self.html = page.read()
            page.close()
        except HTTPError as e:
            print(e)
            return None
        except URLError as e:
            print(e)
            return None
        else:
            print("connecting success!")
            return self.html

    def html_parse(self):
        try:
            self.soup = bs(self.html, "html.parser")
        except AttributeError as e:
            print(e)
            return None
        else:
            print("parsing success!")
            # print(self.soup)
            return self.soup
        # have to handle iframe tag

    def get_title(self):
        # get title of page
        try:
            title = self.soup.find('title')
        except:
            return None
        else:
            print(title.text)
            return title.text

    def get_image(self):
        # get image of the page
        img = self.soup.find('img')
        print(img)

        if img:
            # when the image file exists in page
            try:
                imgUrl = img['src']
            except:
                imgUrl = img['data-src']

            if imgUrl:
                return imgUrl
            else:
                None

        else:
            # when the image file doesn't exist in page
            # our image?
            pass

    def get_contents(self):
        # get contents of the page
        iframe_check = self.soup.find('iframe')
        contents = list()

        if iframe_check:
            self.driver.get(self.url)
            iframes = self.driver.find_elements_by_tag_name('iframe')

            for i, iframe in enumerate(iframes):
                try:
                    self.driver.switch_to.frame(iframes[i])
                    p_list = self.driver.find_elements_by_tag_name("p")

                    for x in p_list:
                        p_text = x.text.strip()
                        if p_text == '':
                            continue
                        contents.append(p_text)

                    self.driver.switch_to_default_content()

                except:
                    self.driver.switch_to_default_content()

        else:
            p_list = self.soup.find_all('p')
            for x in p_list:
                text = x.get_text().strip()
                contents.append(text)

        return " ".join(contents)
