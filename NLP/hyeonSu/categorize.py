from pororo import Pororo

class Categorize :
    def _init_ (self,search_idx,db_ctg_list) :
        self.search_idsx = search_idx
        self.db_ctg_list = ctg_list

    def ctg():
        smr = Pororo(task="similarity", lang="ko")

        temp = 0
        ctg_temp = ""
         for i in self.db_ctg_list :
             sim_temp = smr(i,self.search_idx)
             if temp > sim_temp :
                 continue
             else :
                 ctg_temp = i
                 temp = smr(i,self.search_idx)
        
        return ctg_temp
