import crawler
import model

def main(url):
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

    print(scrap_page)

if __name__ == '__main__':
    main('https://blog.naver.com/harusary84/222536179450?rvid=5A809C679DE6EE4D8E16DA0B300A64198F86')
