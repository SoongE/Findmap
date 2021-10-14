import pandas as pd
import fasttext
import random
import numpy as np
import pymysql 

class Categorization:
    def __init__(self):
        self.model = fasttext.load_model('0826101710_model.bin')
        
        # host_name = "findmap-first-db.c2jag33neij8.ap-northeast-2.rds.amazonaws.com"
        # user_name = "admin"
        # password = "mypassword"
        # db_name = "findmap-first-db"
        
        # db = pymysql.connect(
        #        host = host_name,
        #        port = 3306,
        #         user = user_name,
        #         passwd = password,
        #         db = db_name,
        #         charset = 'utf8'
        #  )

        # SQL = "" ## sql 입력

        # self.df = pd.read_sql(SQL,db)

    def remove_label(self, pred):
        # fasttext를 사용할 때 카테고리에 붙는 __label__을 제거
        clear_pred = []
        for x in pred:
            try:
                x = x.replace('_', '').replace('label', '')
                clear_pred.append(x)
            except:
                continue
        return clear_pred

    def categorize(self, result):
        category_pred = {'문학/책': 0, '영화': 0, '미술/디자인': 0, '공연/전시': 0, '음악': 0, '드라마': 0, '스타/연예인': 0, '만화/애니': 0,
                         '방송': 0, '일상/생각': 0, '육아/결혼': 0, '애완/반려동물': 0, '좋은글/이미지': 0, '패션/미용': 0, '인테리어/DIY': 0,
                         '요리/레시피': 0, '상품리뷰': 0, '원예/재배': 0, '게임': 0, '스포츠': 0, '사진': 0, '자동차': 0, '취미': 0, '국내여행': 0,
                         '세계여행': 0, '맛집': 0, 'IT/컴퓨터': 0, '사회/정치': 0, '건강/의학': 0, '비즈니스/경제': 0, '어학/외국어': 0, '교육/학문': 0}

        user_rate = list()
        user_rate = [0.126436, 0.134778, 0.235164, 0.311223, 0.983456, 0.123415, 0.995632, -0.235162, 
                    0.458636, 0.231463, 0.234515, -0.562231, -0.352111, 0.654724, 0.231523, 
                    -0.968704, -0.869472, -0.112235, -0.162246, -0.236613, 0.212356, -0.123573, -0.235616, -0.760286,
                    0.123835, -0.582454, -0.235671, -0.146256, 0.212356, 0.123856, 0.233156, -0.321563]
        #for x in range(32):
            #user_rate.append(random.uniform(-1, 1))
        #print(user_rate)
        ## 여기서 처리하면됩니다.

        for i, x in enumerate(result):
            title = x["title"]
            pred = self.model.predict(title, k=32)
            pred_category = pred[0]
            pred_num = pred[1]
            predictions = self.remove_label(pred_category)

            for j in range(32):
                category_pred[predictions[j]] = pred_num[j]

            category_pred_value = list(category_pred.values())

            result[i]["pred"] = self.get_preference(category_pred_value, user_rate)

<<<<<<< HEAD
    def get_preference(self, category_pred_value, user_rate):
        # 사용자의 카테고리별 선호도를 바탕으로 검색 결과의 선호도를 유추
        user_rate_np = np.array(user_rate).flatten()
        category_pred_value_np = np.array(category_pred_value).flatten()

        return np.dot(category_pred_value_np, user_rate_np)

    def get_category_of_keyword(self, keyword):
        return [keyword, self.model.predict(keyword)[0][0]]
=======
def share(url):
    # temporary url. It will get the current url from nodejs later.
    crw = crawler.Crawler(url)
    nlp = model.Model()

    try:
        if crw.robots_check():
            # this page admit crawling
            scrap_page = crw.crawl()

            title = scrap_page['title']

            if 'sentences' in scrap_page:
                sentences = scrap_page['sentences']
                if sentences is not None:
                    description = nlp.summarize(sentences)
                    scrap_page['description'] = description

            if title is not None:
                try:
                    category_list = ['문학/책', '영화', '미술/디자인', '공연/전시', '음악', '드라마', '스타/연예인', '만화/애니',
                                     '방송', '일상/생각', '육아/결혼', '애완/반려동물', '좋은글/이미지', '패션/미용', '인테리어/DIY',
                                     '요리/레시피', '상품리뷰', '원예/재배', '게임', '스포츠', '사진', '자동차', '취미', '국내여행',
                                     '세계여행', '맛집', 'IT/컴퓨터', '사회/정치', '건강/의학', '비즈니스/경제', '외학/외국어', '교육/학문']
                    category_predict = nlp.categorize(title, category_list)
                    scrap_page['category'] = max(category_predict, key=category_predict.get)
                except:
                    scrap_page['category'] = None
            else:
                scrap_page['category'] = None


        else:
            # this page doesn't admit crawling
            scrap_page = dict()
            scrap_page['url'] = url
            scrap_page['title'] = None
            scrap_page['description'] = None
            scrap_page['img_url'] = None
            scrap_page['category'] = None
    except:
        scrap_page = dict()
        scrap_page['url'] = url
        scrap_page['title'] = None
        scrap_page['description'] = None
        scrap_page['img_url'] = None
        scrap_page['category'] = None

    return scrap_page
>>>>>>> a9d51dec8d90bc2a1c5f0e810d82097ae02bdf0f
