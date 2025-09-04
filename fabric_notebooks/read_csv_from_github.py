import requests

url = "https://raw.githubusercontent.com/user/repo/branch/your-file.csv")
response = requests.get(url)
with open(f"/lakehouse/default/Files/your-file.csv", 'wb') as f:
    f.write(response.content)

df = spark.read.format("csv") \
    .option("header","true") \
    .option("inferSchema","true") \
    .load(f"Files/your_file.csv")

df.write.mode("overwrite").saveAsTable("your_table")
