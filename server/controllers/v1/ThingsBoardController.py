# import csv
# import json
# from flask import jsonify
# import requests
# import pandas as pd
# import psycopg2

# username = 'postgres'
# password = 'admin'
# dbName = 'air_quality_v2'

# class ThingsBoardController:
#   def fetchAllData():
#     # getUser = DBConnection('bills').where('userID', '==', userID)
#     # userBill = getUser.get()
#     # data = []
#     # for i in userBill:
#     # data.append(i.to_dict())
#     token = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0ZW5hbnRAdGhpbmdzYm9hcmQub3JnIiwidXNlcklkIjoiZjgwZTI2ZjAtZWZjYi0xMWVkLWE4MTItNmIwZmU4ZGYzMGY4Iiwic2NvcGVzIjpbIlRFTkFOVF9BRE1JTiJdLCJzZXNzaW9uSWQiOiJlMDdiMjJjZC0zOWViLTQ3ZGMtOTUzMC0yMzExN2ViOTJjNWUiLCJpc3MiOiJ0aGluZ3Nib2FyZC5pbyIsImlhdCI6MTY4OTYwNjcwNCwiZXhwIjoxNjg5NjE1NzA0LCJlbmFibGVkIjp0cnVlLCJpc1B1YmxpYyI6ZmFsc2UsInRlbmFudElkIjoiZjY0YTJmZDAtZWZjYi0xMWVkLWE4MTItNmIwZmU4ZGYzMGY4IiwiY3VzdG9tZXJJZCI6IjEzODE0MDAwLTFkZDItMTFiMi04MDgwLTgwODA4MDgwODA4MCJ9.vtUPw6goPZyCS6nuDXBGPyQJgjhtx4ki2jdYWN0bA44AzjViPjmZ4YptjzzLRxIGYxUnQTJrL2Y7pessosYfbQ"
#     field1 = "temp"
#     field2 = "humi"
#     field3 = "mq135"
#     field4 = "mq7"
#     field5 = "pm2.5"
#     field6 = "uv_index"
#     field7 = "dewpoint"
#     deviceID = "8b6df0a0-23a8-11ee-8629-f3133190e26b"
#     start = "1689465600000"
#     end = "1689552000000"
#     sort = "ASC"
#     host = "192.168.1.29:8080"

#     # Define the fields
#     fields = ["temp", "humi", "mq135", "mq7", "pm2.5", "uv_index"]

#     url = "http://" + host + "/api/plugins/telemetry/DEVICE/" + deviceID + \
#           "/values/timeseries?keys=" + ','.join(fields) + "&startTs=" + \
#           start + "&endTs=" + end + "&sortOrder=" + sort
#     headers = {
#         'Accept': 'application/json',
#         'Authorization': "Bearer " + token
#     }
#     response = requests.request("GET", url, headers=headers)
#     data = response.json()

#   def fecthOfflineData():
#     def manualFormatData(field):
#       json_url = "datasets/" + field + ".json"
#       with open(json_url) as f:
#         data = json.load(f)

#       df = pd.DataFrame(data[field])

#       df['timestamp'] = pd.to_datetime(df['ts'], unit='ms')
#       df['timestamp'] = df['timestamp'].dt.floor('s')

#       df.drop('ts', axis=1, inplace=True)

#       df.rename(columns={'value': field}, inplace=True)

#       df1 = df[['timestamp', field]]

#       df1.set_index('timestamp', inplace=True)

#       return df1
    
#     fields = ["temp", "humi", "mq135", "mq7", "pm2.5", "uv_index", "dewpoint"]
#     for field in fields:
#       if field == "temp":
#         temp = manualFormatData(field)
#       elif field == "humi":
#         humi = manualFormatData(field)
#       elif field == "mq135":
#         mq135 = manualFormatData(field)
#       elif field == "mq7":
#         mq7 = manualFormatData(field)
#       elif field == "pm2.5":
#         pm25 = manualFormatData(field)
#       elif field == "uv_index":
#         uv_index = manualFormatData(field)
#       elif field == "dewpoint":
#         dew_point = manualFormatData(field)

#     df = pd.concat([temp, humi, mq135, mq7, pm25, uv_index, dew_point], axis=1)
#     data = df.to_json(orient='records') 

#     # get current day
#     current_day = df.index[-1].strftime("%Y-%m-%d")
#     pathSaveCSV = "datasets/output/" + current_day + ".csv"
#     df.to_csv(pathSaveCSV, index=True)

#     def db_connection():
#       return psycopg2.connect(user=username, password=password, dbname=dbName, host='localhost', port='5432')

#     def QueryParamFunc(query, params):
#       try:
#           conn = db_connection()
#           cursor = conn.cursor()
#           cursor.execute(query, params)
#           conn.commit()
#           data = cursor.fetchone()
#           cursor.close()
#           conn.close()
#           return data
#       except Exception as e:
#           return e
      
#     table_name = "daily_data"
#     try:
#         checkExistTable = QueryParamFunc('SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = %s)', (table_name,))
#         if not checkExistTable[0]:
#             QueryParamFunc('CREATE TABLE "daily_data" ("timestamp" timestamp NOT NULL, "temp" float8, "humi" float8, "mq135" float8, "mq7" float8, "pm2.5" float8, "uv_index" float8, "dewpoint" float8, PRIMARY KEY ("timestamp"))', ())
#     except ValueError:
#         return ValueError

#     def check_existing_data(conn, cursor, timestamp):
#       cursor.execute("SELECT COUNT(*) FROM daily_data WHERE timestamp = %s", (timestamp,))
#       count = cursor.fetchone()[0]
#       return count > 0
    
#     try:
#       conn = db_connection()
#       cursor = conn.cursor()

#       # Check if the data already exists in the database
#       cursor.execute("SELECT COUNT(*) FROM daily_data")
#       data_count = cursor.fetchone()[0]

#       if data_count == 0:
#         # If no data exists, perform the initial insertion of all data
#         with open('datasets/output/' + current_day + '.csv', 'r') as f:
#           reader = csv.reader(f)
#           next(reader)  # Skip the header row.
#           for row in reader:
#               cursor.execute(
#                   "INSERT INTO daily_data VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
#                   row
#               )
#       else:
#         # If data already exists, append new data to the database
#         with open('datasets/output/' + current_day + '.csv', 'r') as f:
#           reader = csv.reader(f)
#           next(reader)  # Skip the header row.
#           for row in reader:
#               timestamp = row[0]
#               if not check_existing_data(conn, cursor, timestamp):
#                   cursor.execute(
#                       "INSERT INTO daily_data VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
#                       row
#                   )
#       conn.commit()
#       cursor.close()
#     except (psycopg2.Error, ValueError) as e:
#       # Handle the exception
#       print(e)
#     finally:
#       if conn is not None:
#         conn.close()

#     return jsonify({
#       'status': 'success',
#       'message': 'Data fetched successfully',
#       'data': data
#     })
    
