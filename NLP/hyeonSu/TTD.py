from categorize import Categorize
import unittest
import pymysql 
import pandas as pd



host_name = "findmap-first-db.c2jag33neij8.ap-northeast-2.rds.amazonaws.com"
user_name = "admin"
password = "mypassword"
db_name = "findmap-first-db"

db = pymysql.connect(
    host = host_name,
    port = 3306,
    user = user_name,
    passwd = password,
    db = db_name,
    charset = 'utf8'
)



class CustomTests(unittest.TestCase): 

    def setUp(self) :
        #dataset
        sql = 'select name from CategoryTB ct'

        ctg_test = pd.read_sql(sql,db)
        table = ctg_test['name']
        self.search_idx = []
        self.test_idx = ["야구", "운동","정치","올림픽","양자역학","스마트폰","상어"]
        
        
        for i in table :
          self.search_idx.append(i)
        


    def test_runs(self):
        for  word in self.test_idx :
           k= Categorize(word,self.search_idx).ctg()
           print(k)
           
#####
    

#### unittest를 실행
if __name__ == '__main__':  
    unittest.main()