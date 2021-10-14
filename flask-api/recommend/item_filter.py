import pandas as pd
import os
from sklearn.model_selection import train_test_split
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
import pymysql 

class Item_filtered :

 def __init__(self,user_idx) : 
   host_name = "findmap-first-db.c2jag33neij8.ap-northeast-2.rds.amazonaws.com"
   user_name = "admin"
   password = "mypassword"
   db_name = "findmap-first-db"


   self.userid = int(user_idx)    ### node 로부터 user ID 를 받아야됨

   db = pymysql.connect(
     host = host_name,
     port = 3306,
     user = user_name,
     passwd = password,
     db = db_name,
     charset = 'utf8'
   )

   SQL = " select st.userIdx, st.categoryIdx as keywordidx, count(*) as rating from ScrapTB st  group by categoryIdx  "  



   self.df  = pd.read_sql(SQL,db)

 def make_list(self)  :
   train_df, test_df = train_test_split(self.df, test_size=0.2, random_state=1234)

   def cos_matrix(a, b):
     cos_values = cosine_similarity(a.values, b.values)
     cos_df = pd.DataFrame(data=cos_values, columns = a.index.values, index=a.index)
     return cos_df

   print(train_df.shape)
   print(test_df.shape)

   sparse_matrix = train_df.groupby('keywordidx').apply(lambda x: pd.Series(x['rating'].values, index=x['userIdx'])).unstack()
   sparse_matrix.index.name = 'keywordidx'



   checker = sparse_matrix.isnull().values.any()
   if(True == checker) :

     sparse_matrix_withsearch = sparse_matrix.apply(lambda x: x.fillna(0), axis=1)
    
   else :

     sparse_matrix_withsearch = sparse_matrix

   search_cos_df = cos_matrix(sparse_matrix_withsearch, sparse_matrix_withsearch)
   print("matirx화 성공")
   userId_grouped = train_df.groupby('userIdx')
   search_prediction_ = pd.DataFrame(index=list(userId_grouped.indices.keys()), columns=sparse_matrix_withsearch.index)


   for userId, group in userId_grouped:
    
     user_sim = search_cos_df.loc[group['keywordidx']]
     user_rating = group['rating']
     sim_sum = user_sim.sum(axis=0)

    # userId의 전체 rating predictions 
     pred_ratings = np.matmul(user_sim.T.to_numpy(), user_rating) / (sim_sum+1)
     search_prediction_.loc[userId] = pred_ratings
   max_rating_num = search_prediction_.loc[self.userid].max()
   search_ctg_idx = search_prediction_.columns.tolist()
   recommend_list = [] 

   for i in search_ctg_idx :
     if search_prediction_[i].loc[self.userid] == max_rating_num :
         recommend_list.append(i)
   print("1번의 maximum 추천값")
   return recommend_list 
