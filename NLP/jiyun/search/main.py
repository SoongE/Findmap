import Searcher
import model

def main():
    searcher = Searcher.Searcher()
    nlp = model.Categorization()

    search_text = input("검색할 단어를 입력하세요: ") # 추후 노드에서 받을 예정!

    # input으로 받은 검색어의 카테고리를 유추 
    # keyword_category에 [검색어, 유추한_카테고리]로 값 저장
    keyword_category = nlp.get_category_of_keyword(search_text)
    print(keyword_category)

    # result = list()

    # naver_result = searcher.naver_get_result(search_text)
    # kakao_result = searcher.kakao_get_result(search_text)

    # if not naver_result and not kakao_result:
    #     # naver와 kakao 모두 rest api 통신 실패
    #     # node.js 에 에러 던져줌
    #     exit(0)

    # elif not naver_result:
    #     # naver 통신 과정 중 에러 발생
    #     # kakao에서 얻어온 정보로만 사용자 검색 결과 추천
    #     result = kakao_result

    # elif not kakao_result:
    #     # kakao 통신 과정 중 에러 발생
    #     # naver 에서 얻어온 정보로만 사용자 검색 결과 추천
    #     result = naver_result
    # else:
    #     # naver와 kakao 모두 정상적으로 통신
    #     result = naver_result + kakao_result


    # # 검색 결과의 title 로부터 카테고리를 유추
    # nlp.categorize(result)

    # # node.js 로부터 사용자 정보 받아오기.
    # # 각 카테고리별 스크랩 수 / 최초 관심사 카테고리 등등...

    # result = sorted(result, key=lambda content: (-content['pred'], content['title']))
    # for x in result:
    #     print(f'\n{x["title"]}\n{x["link"]}\n{x["description"]}\n')

if __name__ == '__main__':
    main()
