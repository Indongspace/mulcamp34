# 파일명 : db.py
import mysql.connector
import pandas as pd

mydb = mysql.connector.connect(
    host = "localhost", 
    user = "root", 
    passwd = "indong1998!", 
    database = "muldb"
)

print(mydb)

my_cursor = mydb.cursor(dictionary=True)

query = """
   SELECT * FROM users;
"""

my_cursor.execute(query)

result = my_cursor.fetchall()
for row in result:
    print(row)

df = pd.DataFrame(result)
print(df)
print("완료")

