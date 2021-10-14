import pymysql

class insert : 
 def __init__(self,search,ctg1,ctg2,ctg3) : 
   host_name = "findmap-first-db.c2jag33neij8.ap-northeast-2.rds.amazonaws.com"
   user_name = "admin"
   password = "mypassword"
   db_name = "findmap-first-db"

   self.search = search
   self.userid = int(user_idx)    ### node 로부터 user ID 를 받아야됨
   self.ctg1 = ctg1
   self.ctg2 = ctg2
   self.ctg3 = ctg3

   db = pymysql.connect(
     host = host_name,
     port = 3306,
     user = user_name,
     passwd = password,
     db = db_name,
     charset = 'utf8'
   )

 def putin(self) :
