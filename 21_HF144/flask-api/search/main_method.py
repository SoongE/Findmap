from search import searcher
from search import model
from search import crawler

class Mainmethod :
    def __init__(self,search_idx,user_idx,fasttext_model) :
        self.searcher = searcher.Searcher()
        self.result = list()
        self.search = search_idx
        self.user_idx = user_idx
        self.model = fasttext_model

    def main(self):
        search_text = self.search # 추후 노드에서 받을 예정!
        
        # 검색 결과의 title 로부터 카테고리를 유추
        mod = model.Categorization(self.model)
        naver_result = self.searcher.naver_get_result(search_text)
        kakao_result = self.searcher.kakao_get_result(search_text)

        if not naver_result and not kakao_result:
            # naver와 kakao 모두 rest api 통신 실패
            # node.js 에 에러 던져줌
            exit(0)

        elif not naver_result:
            # naver 통신 과정 중 에러 발생
            # kakao에서 얻어온 정보로만 사용자 검색 결과 추천
            self.result = kakao_result

        elif not kakao_result:
            # kakao 통신 과정 중 에러 발생
            # naver 에서 얻어온 정보로만 사용자 검색 결과 추천
            self.result = naver_result
        else:
            # naver와 kakao 모두 정상적으로 통신
            self.result = naver_result + kakao_result
        

        # node.js 로부터 사용자 정보 받아오기.
        # 각 카테고리별 스크랩 수 / 최초 관심사 카테고리 등등...

        mod.sort_search_list(self.result, self.user_idx)

        # node.js 로부터 사용자 정보 받아오기.
        # 각 카테고리별 스크랩 수 / 최초 관심사 카테고리 등등...

        result = sorted(self.result, key=lambda content: (-content['pred'], content['title']))
        # for x in result:
        #     print(f'\n{x["title"]}\n{x["link"]}\n{x["description"]}\n')

        # result = sorted(self.result, key=lambda content: (content['title']))
        
        return result

def share(url, crw, nlp, ft_model):
    # temporary url. It will get the current url from nodejs later.
    try:
        if crw.robots_check(url):
            # this page admit crawling
            scrap_page = crw.crawl(url)
            if scrap_page == 0:
                return 0
            title = scrap_page['title']

            if 'sentences' in scrap_page:
                try:
                    sentences = scrap_page['sentences']
                    if sentences is not None or sentences.strip() is not "":
                        description = nlp.summarize(sentences)
                        scrap_page['description'] = description
                except:
                    scrap_page['description'] = None
            
            if title is not None:
                try:
                    label = ft_model.predict(title)[0][0].replace('_', '').replace('label', '')
                    scrap_page['category'] = label.replace('/','·')
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