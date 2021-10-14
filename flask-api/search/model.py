from pororo import Pororo
import pymysql 
import pandas as pd

class Categorize :
    def __init__ (self,search_idx) :
        self.search_idx = search_idx
        #self.db_ctg_list =  ['문학/책', '영화', '미술/디자인', '공연/전시', '음악', '드라마', '스타/연예인', '만화/애니',
                                     #'방송', '일상/생각', '육아/결혼', '애완/반려동물', '좋은글/이미지', '패션/미용', '인테리어/DIY',
                                     #'요리/레시피', '상품리뷰', '원예/재배', '게임', '스포츠', '사진', '자동차', '취미', '국내여행',
                                     #'세계여행', '맛집', 'IT/컴퓨터', '사회/정치', '건강/의학', '비즈니스/경제', '외학/외국어', '교육/학문']
        
        host_name = "findmap-first-db.c2jag33neij8.ap-northeast-2.rds.amazonaws.com"
        user_name = "admin"
        password = "mypassword"
        db_name = "findmap-first-db"


        db = pymysql.connect(
           host = host_name,
           port = 3306,
           user = user_name,
           passwd = password,
           db = db_name,
           charset = 'utf8'
        )

        SQL = " select * from CategoryTB"

        self.df  = pd.read_sql(SQL,db)
    
    def ctg(self):
        smr = Pororo(task="similarity", lang="ko")
        
        temp = 0
        ctg_temp = ""
        for i in list(self.df['name']) :
             word_temp = i.split('·')

             if 2 == len(word_temp) :
                 sim_temp = max(smr(word_temp[0],self.search_idx),smr(word_temp[1],self.search_idx))
             else :
                 sim_temp = smr(word_temp[0],self.search_idx)
             if temp > sim_temp :
                 continue
             else :
                 ctg_temp = i
                 temp = smr(i,self.search_idx)
        
        k = self.df[self.df['name'] == ctg_temp]
        print(ctg_temp)
        return list(k['idx'].values)
    
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