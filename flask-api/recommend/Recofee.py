import pandas as pd
import os
import numpy as np
import pymysql 

class Recc :

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

   SQL = "select idx from ScrapTB st  where isFeed = 'Y' and status = 'Y' and userIdx = " + str(user_idx)

   self.df  = pd.read_sql(SQL,db)
   

 def recommend_Feed(self) :
     k = self.df['idx']
     result = []
     for i in k :
         result.append(i)

     result_s = ""
     for num , k in enumerate(result) :
            if num == len(result)-1 :
                result_s = result_s + k
            else :
                result_s = result_s + k + ','
            
        
     return result_s
         

     
     



