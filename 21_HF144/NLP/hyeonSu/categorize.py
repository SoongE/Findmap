from pororo import Pororo

class Categorize :
    def __init__ (self,search_idx,db_ctg_list) :
        self.search_idx = search_idx
        self.db_ctg_list = db_ctg_list

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
        
        return ctg_temp
