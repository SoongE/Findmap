import pandas as pd
import fasttext
import random
import numpy as np
import pymysql 
from pororo import Pororo
from sklearn.preprocessing import minmax_scale

class Categorization:
    def __init__(self, model):
        self.model = model

        host_name = "findmap-first-db.c2jag33neij8.ap-northeast-2.rds.amazonaws.com"
        user_name = "admin"
        password = "mypassword"
        db_name = "findmap-first-db"
        
        self.db = pymysql.connect(
                host = host_name,
                port = 3306,
                 user = user_name,
                 passwd = password,
                 db = db_name,
                 charset = 'utf8'
          )

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

    def calculate_user_rate(self, userIdx):
        # 사용자 취향 계산
        category_sql = "select categoryIdx from UserInterestTB where userIdx = " + str(userIdx) + " and status = 'Y';"
        scrap_sql = "select categoryIdx, count(categoryIdx) as count from ScrapTB where userIdx = " + str(userIdx) + " and status = 'Y' group by categoryIdx;"
        search_sql = "select categoryIdx1, categoryIdx2, categoryIdx3 from SearchLogTB SLT, SearchWordTB SWT where SLT.userIdx = " + str(userIdx) + " and SLT.wordIdx = SWT.idx;"
        feedheart_sql = "select categoryIdx, count(categoryIdx) as count from FeedHeartTB, ScrapTB where FeedHeartTB.userIdx = " + str(userIdx) + " and FeedHeartTB.status = 'Y' and ScrapTB.idx = FeedHeartTB.scrapIdx group by categoryIdx;"

        category_df = pd.read_sql(category_sql, self.db)
        scrap_df = pd.read_sql(scrap_sql, self.db)
        search_df = pd.read_sql(search_sql, self.db)
        feedheart_df = pd.read_sql(feedheart_sql, self.db)

        user_rate = [0 for x in range(32)]

        for x in category_df.iloc[:, 0]:
            temp = x - 4
            if temp > 0:
                user_rate[temp] += 5

        scrap_df_x = scrap_df.iloc[:, 0]
        scrap_df_y = scrap_df.iloc[:, 1]

        for idx, x in enumerate(scrap_df_x):
            temp = x - 4
            if temp > 0:
                user_rate[temp] += 0.01 * scrap_df_y[idx]

        categoryIdx1 = search_df.iloc[:, 0]
        categoryIdx2 = search_df.iloc[:, 1]
        categoryIdx3 = search_df.iloc[:, 2]

        for idx in range(len(categoryIdx1)):
            user_rate[categoryIdx1[idx] - 4] += 0.015
            user_rate[categoryIdx2[idx] - 4] += 0.010
            user_rate[categoryIdx3[idx] - 4] += 0.005

        feedheart_idx = feedheart_df.iloc[:, 0]
        feedheart_count = feedheart_df.iloc[:, 1]
        for idx in range(len(feedheart_idx)):
            temp = feedheart_idx[idx] - 4
            if temp > 0:
                user_rate[temp] += 0.001 * feedheart_count[idx]
        user_rate = minmax_scale(user_rate, feature_range=(-1, 1))
        return user_rate


    def sort_search_list(self, result, userIdx):
        category_pred = {'문학·책': 0, '영화': 0, '미술·디자인': 0, '공연·전시': 0, '음악': 0, '드라마': 0, '스타·연예인': 0, '만화·애니': 0,
                         '방송': 0, '일상·생각': 0, '육아·결혼': 0, '애완·반려동물': 0, '좋은글·이미지': 0, '패션/미용': 0, '인테리어·DIY': 0,
                         '요리·레시피': 0, '상품리뷰': 0, '원예·재배': 0, '게임': 0, '스포츠': 0, '사진': 0, '자동차': 0, '취미': 0, '국내여행': 0,
                         '세계여행': 0, '맛집': 0, 'IT·컴퓨터': 0, '사회·정치': 0, '건강·의학': 0, '비즈니스·경제': 0, '어학·외국어': 0, '교육·학문': 0}

        user_rate = self.calculate_user_rate(userIdx)
        
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


    def get_preference(self, category_pred_value, user_rate):
        # 사용자의 카테고리별 선호도를 바탕으로 검색 결과의 선호도를 유추
        user_rate_np = np.array(user_rate).flatten()
        category_pred_value_np = np.array(category_pred_value).flatten()

        return np.dot(category_pred_value_np, user_rate_np)

    def get_category_of_keyword(self, keyword):
        label = self.model.predict(keyword, k=3)[0]
        pred_label = self.remove_label(label)

        label_temp = []
        for i in pred_label :
            print(i)
            i = i.replace('/','·')
            print(i)
            label_temp.append(i)
        
        label_idx_list = []
        for i in label_temp :

            SQL = "select idx,name from CategoryTB ct where name = '{}'".format(i.strip()) 
            df = pd.read_sql(SQL,self.db)
            print(df)
            label_idx_list.append(str(df['idx'][0]))


        result_s = ""
        for num , k in enumerate(label_idx_list) :
            if num == len(label_idx_list)-1 :
                result_s = result_s + k
            else :
                result_s = result_s + k + ','
            
        return result_s  

class PororoModel:
    def __init__(self):
        self.summ = Pororo(task="summarization", model="abstractive", lang="ko")
        self.zsl = Pororo(task="zero-topic")

    def summarize(self, contents):
        # summarize contents of the page
        return self.summ(contents)

    def categorize(self, contents, category_list):
        # categorize contents
        return self.zsl(contents, category_list)
