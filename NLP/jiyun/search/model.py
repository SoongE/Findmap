import pandas as pd
import fasttext
import random
import numpy as np

class Categorization:
    def __init__(self):
        self.model = fasttext.load_model('/home/jiyun/mount/NLP/model/0826101710_model.bin')

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
        for x in range(32):
            user_rate.append(random.uniform(-1, 1))
        print(user_rate)

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
        return [keyword, self.model.predict(keyword)[0][0]]

