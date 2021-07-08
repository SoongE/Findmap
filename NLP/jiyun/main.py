import crawler
import model


def main():
    # temporary url. It will get the current url from nodejs later.
    url = ""
    crw = crawler.Crawler(url)
    nlp = model.Model()

    html = crw.url_connect()
    if html is None:
        print("Error: connect to url")
        # exit will be changed into sending an error message to nodejs server.
        exit(0)

    soup = crw.html_parse()
    if soup is None:
        print("Error: parse html code")
        exit(0)

    title = crw.get_title()
    if title is None:
        print("Error: get the title of the page")


    category_list = ['문학', '영화', '미술', '공연', '전시', '음악', '드라마', '스타', '만화', '방송', '일상', '육아', '결혼', '반려동물', '패션', '인테리어', '요리', '리뷰', '원예', '게임', '스포츠', '사진', '자동차', '취미', '국내여행', '세계여행', '맛집', 'IT', '사회', '정치', '건강', '의학', '경제', '외국어', '교육', '학문']
    category_predict = nlp.categorize(title, category_list)
    print(max(category_predict, key=category_predict.get))

    # print(crw.robots_check())

    if crw.robots_check():
        # this page admit crawling
        img_url = crw.get_image()
        if img_url is None:
            print("Error: get an image of the page")

        contents = crw.get_contents()
        print(contents)

        # contents = "(전국종합=연합뉴스) 임미나 김선호 성서호 기자 = 국내 신종 코로나바이러스 감염증(코로나19) 확산세가 거세지면서 이틀 연속 1천명대 확진자가 쏟아졌다. 7일 방역당국과 서울시 등 각 지방자치단체에 따르면 이날 0시부터 오후 9시까지 전국에서 코로나19 양성 판정을 받은 신규 확진자는 총 1천113명이다.전날 같은 시간에 집계된 1천145명보다는 32명 적다.신규 확진자는 그간 300∼700명대를 오르내리다가 지난해 연말 '3차 대유행'(12월 24일, 1천240명) 정점 이후 약 6개월 보름 만인 전날 1천200명대로 치솟았다.이틀 연속 1천명대 확진자는 작년 12월 29일(1천44명), 30일(1천50명) 이후 처음이다.이날 확진자가 나온 지역을 보면 수도권이 911명(81.9%), 비수도권이 202명(18.1%)이다.시도별로는 서울 536명, 경기 316명, 인천 59명, 충남 57명, 부산 49명, 제주 17명, 대구·강원 각 15명, 대전 12명, 울산 9명, 경남 8명, 충북 6명, 전남·경북 각 4명, 전북 3명, 광주 2명, 세종 1명 등이다.집계를 마감하는 자정까지 아직 시간이 남은 만큼 8일 0시 기준으로 발표될 신규 확진자 수는 이보다 더 늘어 적게는 1천100명대 중후반, 많으면 1천200명을 넘을 것으로 보인다.전날에는 오후 9시 이후 67명 늘어 최종 1천212명으로 마감됐다."
        summary = nlp.summarize(contents)
        print(summary)

    else:
        pass
        # this page doesn't admit crawling
        # img_url = None
        # summmary = None


if __name__ == '__main__':
    main()
