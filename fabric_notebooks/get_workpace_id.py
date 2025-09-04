import re
conf = spark.sparkContext.getConf()
web_url = conf.get("spark.tracking.webUrl", None)
workspace_id = re.search(r'/workspaces/([a-f0-9\-]+)/', web_url).group(1)
print(workspace_id)