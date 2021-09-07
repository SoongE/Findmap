import fasttext
import re

class model :
    def __init__(self) :
        self.model = fasttext.load_model('morphnamunaver.bin')

    def give_recommend(self) :
        word = input("검색어를 입력해주세요 : ")
        words = self.model.get_nearest_neighbors(word, k=100)

        recommend_list = []

        for index in words :
          hangul = re.compile('[^ \uac00-\ud7a3]+')
          result = hangul.sub('', index[1])
          if result == None :
            continue

          if (re.findall(word,result) == None) :
            continue

          recommend_list.append(index[1])
          if (len(recommend_list) == 5) :
            break

        return recommend_list
  