from pororo import Pororo

class Categorize :
    def __init__ (self,search_idx) :
        self.search_idx = search_idx
        self.db_ctg_list =  ['문학/책', '영화', '미술/디자인', '공연/전시', '음악', '드라마', '스타/연예인', '만화/애니',
                                     '방송', '일상/생각', '육아/결혼', '애완/반려동물', '좋은글/이미지', '패션/미용', '인테리어/DIY',
                                     '요리/레시피', '상품리뷰', '원예/재배', '게임', '스포츠', '사진', '자동차', '취미', '국내여행',
                                     '세계여행', '맛집', 'IT/컴퓨터', '사회/정치', '건강/의학', '비즈니스/경제', '외학/외국어', '교육/학문']

    def ctg(self):
        smr = Pororo(task="similarity", lang="ko")
        
        temp = 0
        ctg_temp = ""
        for i in self.db_ctg_list :
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
        
        print(ctg_temp)
        return ctg_temp





