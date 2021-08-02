from urllib.request import urlopen
from urllib.error import HTTPError, URLError
import urllib.robotparser
import re
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
            return False
        except URLError as e:
            print(e)
            return False
        else:
            print("connecting success!")
            return True

    def html_parse(self):
        try:
            self.soup = bs(self.html, "html.parser")
        except AttributeError as e:
            print(e)
            return False
        else:
            print("parsing success!")
            return True

    def og_crawl(self, target):
        # crawl og tag like og:title, og:url, og:title ... etc
        try:
            meta_target = self.soup.select_one('meta[property="og:' + target + '"]')['content']
        except:
            return False
        else:
            return meta_target

    def get_title(self):
        # get title of page
        try:
            title = self.og_crawl('title')
            if title is False:
                # if this page doesn't specify meta og tag
                try:
                    title = self.soup.find('title')
                except:
                    return False
                else:
                    return title.text
        except:
            return False
        else:
            return title

    def get_image(self):
        # get image of the page
        try:
            imgUrl = self.og_crawl('image')
            if imgUrl is False:
                # if this page doesn't specify meta og tag
                try:
                    class_ignore = ["profile", "thumb", "thumbnail", "ads", "sidebar", "loading", "comment", "scroll"]
                    images = self.soup.find_all('img', class_=lambda x: x not in class_ignore)

                    imgUrl = None
                    if images:
                        # when the image file exists in page
                        for image in images:
                            try:
                                imgUrl = image['src']
                            except:
                                try:
                                    imgUrl = image['data-src']
                                except:
                                    try:
                                        imgUrl = image['srcset']
                                    except:
                                        imgUrl = None
                                        continue

                            if re.search('gif$', imgUrl) is not None:
                                imgUrl = None
                                continue

                            cp = False
                            not_includes = ["toast", "thumb", "profile", "load", "ads", "comment"]
                            for x in not_includes:
                                if x in imgUrl:
                                    cp = True
                                    imgUrl = None
                                    break
                            if cp:
                                continue

                        if imgUrl:
                            return imgUrl
                        else:
                            return None

                    else:
                        # when the image file doesn't exist in page
                        return None
                except:
                    return None
                else:
                    return imgUrl.text
        except:
            return None
        else:
            return imgUrl

    def get_contents(self):
        # get contents of the page
        iframe_check = self.soup.find('iframe')
        sentences = list()
        title = ""
        img_url = ""
        self.driver.get(self.url)

        if iframe_check:
            iframes = self.driver.find_elements_by_tag_name('iframe')

            for i, iframe in enumerate(iframes):
                try:
                    self.driver.switch_to.frame(iframes[i])
                    self.html = self.driver.page_source
                    self.html_parse()

                    # get sentences
                    p_list = self.driver.find_elements_by_tag_name("p")
                    for x in p_list:
                        p_text = x.text.strip()
                        if p_text == '':
                            continue
                        sentences.append(p_text)

                    # get title
                    if title == "":
                        title = self.get_title()
                        print(title)
                        if title is None:
                            print("Error: get the title of the page")

                    # get image url
                    if img_url == "":
                        img_url = self.get_image()
                        if img_url is None:
                            print("Error: get an image of the page")
                            img_url = "default"

                    self.driver.switch_to_default_content()

                except:
                    self.driver.switch_to_default_content()

        # get sentences
        p_list = self.driver.find_elements_by_tag_name("p")

        for x in p_list:
            p_text = x.text.strip()
            if p_text == '':
                continue
            sentences.append(p_text)

        # get title
        if title == "":
            title = self.get_title()
            if title is None:
                print("Error: get the title of the page")

        # get image url
        if img_url == "":
            img_url = self.get_image()
            if img_url is None:
                img_url = None

        return title, " ".join(sentences), img_url

    def crawl(self):
        scrap_page = dict()

        crawl_html = self.url_connect()
        if not crawl_html:
            print("Error: connect to url")
            # exit will be changed into sending an error message to nodejs server.
            exit(0)

        crawl_soup = self.html_parse()
        if not crawl_soup:
            print("Error: parse html code")
            # exit will be changed into sending an error message to nodejs server.
            exit(0)

        # print(self.soup)

        title, sentences, img_url = self.get_contents()

        scrap_page['url'] = self.url
        scrap_page['title'] = title
        scrap_page['sentences'] = sentences
        scrap_page['img_url'] = img_url

        return scrap_page
