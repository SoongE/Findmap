import crawler
import model
import pymysql

def main():
    # temporary url. It will get the current url from nodejs later.
    url = ""
    crw = crawler.Crawler(url)
    nlp = model.Model()

    if crw.robots_check():
        # this page admit crawling
        scrap_page = crw.crawl()

        title = scrap_page[1]
        sentences = scrap_page[2]

        if sentences is not None:
            summary = nlp.summarize(sentences)
            scrap_page[2] = summary

        if title is not None:
            try:
                category_list = ['문학', '영화', '미술', '공연', '전시', '음악', '드라마', '스타', '만화', '방송', '일상', '육아', '결혼', '반려동물', '패션', '인테리어', '요리', '리뷰', '원예', '게임', '스포츠', '사진', '자동차', '취미', '국내여행', '세계여행', '맛집', 'IT', '사회', '정치', '건강', '의학', '경제', '외국어', '교육', '학문']
                category_predict = nlp.categorize(scrap_page[1], category_list)
                scrap_page.append(max(category_predict, key=category_predict.get))
            except:
                scrap_page.append(None)
        else:
            scrap_page.append(None)

        print(scrap_page)

    else:
        pass
        # this page doesn't admit crawling
        title = None
        summary = None
        img_url = "default"

        scrap_page = list()
        scrap_page.append(url)
        scrap_page.append(title)
        scrap_page.append(summary)
        scrap_page.append(img_url)

    # connect DB and insert "scrap_page" into ScrapTB
    conn = pymysql.connect(host='findmap-first-db.c2jag33neij8.ap-northeast-2.rds.amazonaws.com',
                           port=3306,
                           user='admin',
                           password='mypassword',
                           db='findmap-first-db',
                           charset='utf8')
    cur = conn.cursor()
    query = "INSERT INTO ScrapTB(idx, userIdx, title, contentUrl, thumbnailUrl, summary, comment, folderIdx, feedIdx) " \
          "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);"
    cur.execute(query, (2, 1, scrap_page[1], scrap_page[0], scrap_page[3], scrap_page[2], "COMMENT", 1, 1))
    conn.commit()
    conn.close()

if __name__ == '__main__':
    main()
