import fasttext
import re
import os ,sys

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from app import mod

class model :
    def __init__(self) :
        self.recommend_list = []
    def give_recommend(self) :
        word = "아이언맨"
        model = mod

        words = model.get_nearest_neighbors(word, k=100)

        for index in words :
          hangul = re.compile('[^ \uac00-\ud7a3]+')
          result = hangul.sub('', index[1])
          if result == None :
            continue

          if (re.findall(word,result) == None) :
            continue

          self.recommend_list.append(index[1])
          if (len(self.recommend_list) == 5) :
            break

        return self.recommend_list
  