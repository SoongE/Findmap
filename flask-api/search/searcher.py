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

    def naver_get_result(self, search_text):
        enc_text = urllib.parse.quote(search_text)
        url = "https://openapi.naver.com/v1/search/blog?query=" + enc_text + "&display=" + self.display

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
                    title = re.sub('(<([^>]+)>)', '', x['title'])
                    link = x["link"]
                    description = re.sub('(<([^>]+)>)', '', x['description'])
                    result.append({"title": title, "link": link, "description": description})
                return result

            else:
                print("Error Code: " + res_code)
                return False

    def kakao_get_result(self, search_text):
        query = "query=" + urllib.parse.quote(search_text)
        url = "https://dapi.kakao.com/v2/search/blog?" + query + "&size=" + self.size

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
                    title = re.sub('(<([^>]+)>)', '', x['title'])
                    link = x["url"]
                    description = re.sub('(<([^>]+)>)', '', x['contents'])
                    result.append({"title": title, "link": link, "description": description})
                return result

            else:
                print("Error Code: " + res_code)
                return False