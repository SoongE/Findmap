import urllib.request
from urllib.error import HTTPError
import json
import re


class Searcher:
    def __init__(self):
        # naver에서 rest api 통신할 때 필요한 정보들
        self.client_id = "***"
        self.client_secret = "***"
        self.display = "50"

        # kakao에서 rest api 통신할 때 필요한 정보들
        self.rest_api_key = "***"
        self.size = "50"

    def convert_html_special_char(self, string):
        new_str = re.sub('(<([^>]+)>)', '', string)
        new_str = re.sub('&nbsp;', ' ', new_str)
        new_str = re.sub('&lt;|&#60;|&#060;', '<', new_str)
        new_str = re.sub('&gt;|&#62;|&#062;', '>', new_str)
        new_str = re.sub('&amp;|&#38;|&#038;', '&', new_str)
        new_str = re.sub('&#035;&#35;', '#', new_str)
        new_str = re.sub('&#039;|&#39;', '\'', new_str)
        new_str = re.sub('&quot;|&#34;|&#034;', '\"', new_str)

        return new_str

    def naver_parse_json(self, url):
        req = urllib.request.Request(url)
        req.add_header("X-Naver-Client-Id", self.client_id)
        req.add_header("X-Naver-Client-Secret", self.client_secret)

        try:
            res = urllib.request.urlopen(req)
        except HTTPError as e:
            print(e)
            return False
        else:
            res_code = res.getcode()

            if res_code == 200:
                # 정상적으로 naver로부터 결과를 받아온 경우
                res_body = json.load(res)
                result = list()

                for x in res_body["items"]:
                    title = self.convert_html_special_char(x['title'])
                    link = x["link"]
                    description = self.convert_html_special_char(x['description'])
                    result.append({"title": title, "link": link, "description": description})
                return result

            else:
                print("Error Code: " + res_code)
                return False

    def naver_get_result(self, search_text):
        enc_text = urllib.parse.quote(search_text)

        blog_url = "https://openapi.naver.com/v1/search/blog?query=" + enc_text + "&display=" + self.display
        cafe_url = "https://openapi.naver.com/v1/search/cafearticle.json?query=" + enc_text + "&display=" + self.display
        news_url = "https://openapi.naver.com/v1/search/news.json?query=" + enc_text + "&display=" + self.display

        result = list()

        blog_result = self.naver_parse_json(blog_url)
        cafe_result = self.naver_parse_json(cafe_url)
        news_result = self.naver_parse_json(news_url)

        if blog_result:
            result += blog_result
        if cafe_result:
            result += cafe_result
        if news_result:
            result += news_result

        if not result:
            print("Error: fail to get result")
            return False
        else:
            return result

    def kakao_parse_json(self, url):
        req = urllib.request.Request(url)
        req.add_header("Authorization", "KakaoAK " + self.rest_api_key)

        try:
            res = urllib.request.urlopen(req)
        except HTTPError as e:
            print(e)
            return False
        else:
            res_code = res.getcode()

            if res_code == 200:
                # 정상적으로 kakao로부터 결과를 받아온 경우
                res_body = json.load(res)
                result = list()

                for x in res_body["documents"]:
                    title = self.convert_html_special_char(x['title'])
                    link = x["url"]
                    description = self.convert_html_special_char(x['contents'])
                    result.append({"title": title, "link": link, "description": description})
                return result

            else:
                print("Error Code: " + res_code)
                return False

    def kakao_get_result(self, search_text):
        enc_text = urllib.parse.quote(search_text)
        
        blog_url = "https://dapi.kakao.com/v2/search/blog?query=" + enc_text + "&size=" + self.size
        cafe_url = "https://dapi.kakao.com/v2/search/cafe?query=" + enc_text + "&size=" + self.size

        result = list()

        blog_result = self.kakao_parse_json(blog_url)
        cafe_result = self.kakao_parse_json(cafe_url)

        if blog_result:
            result += blog_result
        if cafe_result:
            result += cafe_result

        if not result:
            print("Error: fail to get result")
            return False
        else:
            return result
