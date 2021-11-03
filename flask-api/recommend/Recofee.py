import pandas as pd
import os
import numpy as np
import pymysql 
from sklearn.model_selection import train_test_split
from sklearn.metrics.pairwise import cosine_similarity


class Recc :

 def __init__(self,user_idx) : 
   host_name = "findmap-first-db.c2jag33neij8.ap-northeast-2.rds.amazonaws.com"
   user_name = "admin"
   password = "mypassword"
   db_name = "findmap-first-db"


   self.userid = int(user_idx)    ### node 로부터 user ID 를 받아야됨

   self.db = pymysql.connect(
     host = host_name,
     port = 3306,
     user = user_name,
     passwd = password,
     db = db_name,
     charset = 'utf8'
   )

   SQL = "select userIdx ,categoryIdx as keywordidx ,count(*) as rating from ScrapTB st group by userIdx , categoryIdx"

   self.df  = pd.read_sql(SQL,self.db)

 def make_list(self)  :
   train_df, test_df = train_test_split(self.df, test_size=0.2, random_state=1234)

   def cos_matrix(a, b):
     cos_values = cosine_similarity(a.values, b.values)
     cos_df = pd.DataFrame(data=cos_values, columns = a.index.values, index=a.index)
     return cos_df

   #  print(train_df.shape)
   #  print(test_df.shape)

   sparse_matrix = train_df.groupby('keywordidx').apply(lambda x: pd.Series(x['rating'].values, index=x['userIdx'])).unstack()
   sparse_matrix.index.name = 'keywordidx'



   checker = sparse_matrix.isnull().values.any()
   if(True == checker) :

     sparse_matrix_withsearch = sparse_matrix.apply(lambda x: x.fillna(0), axis=1)
    
   else :

     sparse_matrix_withsearch = sparse_matrix

   search_cos_df = cos_matrix(sparse_matrix_withsearch, sparse_matrix_withsearch)
   #  print("matirx화 성공")
   userId_grouped = train_df.groupby('userIdx')
   search_prediction_ = pd.DataFrame(index=list(userId_grouped.indices.keys()), columns=sparse_matrix_withsearch.index)


   for userId, group in userId_grouped:
    
     user_sim = search_cos_df.loc[group['keywordidx']]
     user_rating = group['rating']
     sim_sum = user_sim.sum(axis=0)

    # userId의 전체 rating predictions 
     pred_ratings = np.matmul(user_sim.T.to_numpy(), user_rating) / (sim_sum+1)
     search_prediction_.loc[userId] = pred_ratings
   max_rating_num = search_prediction_.loc[self.userid]
   search_ctg_idx = search_prediction_.columns.tolist()
   

   sum = 0

   for i in max_rating_num :
     sum = sum + float(i)
  
   average_rating = sum / len(max_rating_num)

   print("평균값" + str(average_rating))
   # 평균값

   over_avg_df =  max_rating_num[max_rating_num>average_rating]
   print(over_avg_df)
   selected_col = []
   
   for i in list(over_avg_df.index) :
     selected_col.append(i)
    
  
   last_result = [] 

   for i in selected_col :
     sql_temp = "select idx,userIdx,categoryIdx from ScrapTB st where categoryidx = "+ str(i) +" and idx != " + str(self.userid)
     df_temp = pd.read_sql(sql_temp,self.db)

     for k in df_temp['idx'] :
       last_result.append(k)

   result_s = ""
   for num , k in enumerate(last_result) :
       if num == len(last_result)-1 :
          result_s = result_s + str(k)
       else :
          result_s = result_s + str(k) + ','
            
   return result_s
    
 #def recommend_Feed(self) :
    # k = self.df['idx']
     #result = []
     #for i in k :
         #result.append(i)

    # result.sort(reverse=True)

     #result_s = ""
     #for num , k in enumerate(result) :
            #if num == len(result)-1 :
                #result_s = result_s + str(k)
            #else :
                #result_s = result_s + str(k) + ','
            
        
     #return result_s
         

     
     



