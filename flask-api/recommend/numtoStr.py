import pymysql 
import pandas as pd 


class Recommend :

 def __init__(self,reco_list) : 
   host_name = "findmap-first-db.c2jag33neij8.ap-northeast-2.rds.amazonaws.com"
   user_name = "admin"
   password = "mypassword"
   db_name = "findmap-first-db"

   SQL = "select * from CategoryTB ct"
   self.reco_list = reco_list

   db = pymysql.connect(
     host = host_name,
     port = 3306,
     user = user_name,
     passwd = password,
     db = db_name,
     charset = 'utf8'
   )
  
   self.df  = pd.read_sql(SQL,db)

 def give_result(self) :
     result = []

     for i in self.reco_list :
      temp = self.df[self.df['idx'] == i]
      result.append(temp['name'].values)
     return  result
