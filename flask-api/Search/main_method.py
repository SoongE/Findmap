from Search import Searcher
from Search import model

class Mainmethod :
  def __init__(self) :
    self.searcher = Searcher.Searcher()
    self.result = list()
  def main():
    search_text = input("입력하시오 : ") # 추후 노드에서 받을 예정!
    
    # 검색 결과의 title 로부터 카테고리를 유추
    mod = model.Categorize(search_text)
    mod.ctg()
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

    result = sorted(self.result, key=lambda content: (content['title']))
    
    return result





