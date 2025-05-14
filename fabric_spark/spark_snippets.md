# PySpark Snippets on Microsoft Fabric

Create a delta table in Spark is to save a dataframe in the delta format.

```python
# Load a file into a dataframe
df = spark.read.load('Files/mydata.csv', format='csv', header=True)

# Save the dataframe as a delta table
df.write.format("delta").saveAsTable("mytable")
```

Creates an external table for which the data is stored in the folder in the Files storage location for the lakehouse

```python
df.write.format("delta").saveAsTable("myexternaltable", path="Files/myexternaltable")
```
You can also specify a fully qualified path for a storage location, like this:

```python
df.write.format("delta").saveAsTable("myexternaltable", path="abfss://my_store_url..../myexternaltable")
```

DeltaTableBuilder API

```python
from delta.tables import *

DeltaTable.create(spark) \
  .tableName("products") \
  .addColumn("Productid", "INT") \
  .addColumn("ProductName", "STRING") \
  .addColumn("Category", "STRING") \
  .addColumn("Price", "FLOAT") \
  .execute()
```

```sql
%%sql

CREATE TABLE salesorders
(
    Orderid INT NOT NULL,
    OrderDate TIMESTAMP NOT NULL,
    CustomerName STRING,
    SalesTotal FLOAT NOT NULL
)
USING DELTA
```

You can also create an external table by specifying a LOCATION parameter, as shown here:

```sql
%%sql

CREATE TABLE MyExternalTable
USING DELTA
LOCATION 'Files/mydata'
```

The following PySpark code saves a dataframe to a new folder location in delta format:

```python
delta_path = "Files/mydatatable"
df.write.format("delta").save(delta_path)
```

You can replace the contents of an existing folder with the data in a dataframe by using the overwrite mode, as shown here:

```python
new_df.write.format("delta").mode("overwrite").save(delta_path)
```

You can also add rows from a dataframe to an existing folder by using the append mode:

```python
new_rows_df.write.format("delta").mode("append").save(delta_path)
```

In Microsoft Fabric, OptimizeWrite is enabled by default. You can enable or disable it at the Spark session level:

```python
# Disable Optimize Write at the Spark session level
spark.conf.set("spark.microsoft.delta.optimizeWrite.enabled", False)

# Enable Optimize Write at the Spark session level
spark.conf.set("spark.microsoft.delta.optimizeWrite.enabled", True)

print(spark.conf.get("spark.microsoft.delta.optimizeWrite.enabled"))
```

VACCUM 

```sql
%%sql
VACUUM lakehouse2.products RETAIN 168 HOURS;
```

VACUUM commits to the Delta transaction log, so you can view previous runs in DESCRIBE HISTORY.

```sql
%%sql
DESCRIBE HISTORY lakehouse2.products;
```

In this example, a DataFrame containing product data is partitioned by Category:

```python
df.write.format("delta").partitionBy("Category").saveAsTable("partitioned_products", path="abfs_path/partitioned_products")
```

```sql
%%sql
CREATE TABLE partitioned_products (
    ProductID INTEGER,
    ProductName STRING,
    Category STRING,
    ListPrice DOUBLE
)
PARTITIONED BY (Category);
```

the following code inserts a row into the products table.

```python
spark.sql("INSERT INTO products VALUES (1, 'Widget', 'Accessories', 2.99)")
```

```sqk
%%sql

UPDATE products
SET Price = 2.49 WHERE ProductId = 1;
```

### Delta API

You can create an instance of a DeltaTable from a folder location containing files in delta format, and then use the API to modify the data in the table.

```python
from delta.tables import *
from pyspark.sql.functions import *

# Create a DeltaTable object
delta_path = "Files/mytable"
deltaTable = DeltaTable.forPath(spark, delta_path)

# Update the table (reduce price of accessories by 10%)
deltaTable.update(
    condition = "Category == 'Accessories'",
    set = { "Price": "Price * 0.9" })
```

To see the history of a table, you can use the DESCRIBE SQL command as shown here.
```sql
%%sql

DESCRIBE HISTORY products
```

```sql
%%sql

DESCRIBE HISTORY 'Files/mytable'
```


```python
df = spark.read.format("delta").option("versionAsOf", 0).load(delta_path)
```

```python
df = spark.read.format("delta").option("timestampAsOf", '2022-01-01').load(delta_path)
```

## Streaming Data

```sql
%%sql
CREATE TABLE orders_in
(
        OrderID INT,
        OrderDate DATE,
        Customer STRING,
        Product STRING,
        Quantity INT,
        Price DECIMAL
)
USING DELTA;

INSERT INTO orders_in (OrderID, OrderDate, Customer, Product, Quantity, Price)
VALUES
    (3001, '2024-09-01', 'Yang', 'Road Bike Red', 1, 1200),
    (3002, '2024-09-01', 'Carlson', 'Mountain Bike Silver', 1, 1500),
    (3003, '2024-09-02', 'Wilson', 'Road Bike Yellow', 2, 1350),
    (3004, '2024-09-02', 'Yang', 'Road Front Wheel', 1, 115),
    (3005, '2024-09-02', 'Rai', 'Mountain Bike Black', 1, NULL);

```



```python
# Read and display the input table
df = spark.read.format("delta").table("orders_in")

display(df)
```

```python
# Load a streaming DataFrame from the Delta table
stream_df = spark.readStream.format("delta") \
    .option("ignoreChanges", "true") \
    .table("orders_in")
```

> When using a Delta table as a streaming source, only append operations can be included in the stream. Data modifications will cause an error unless you specify the ignoreChanges or ignoreDeletes option.

```python
# Verify that the stream is streaming
stream_df.isStreaming
```

```python
from pyspark.sql.functions import col, expr

transformed_df = stream_df.filter(col("Price").isNotNull()) \
    .withColumn('IsBike', expr("INSTR(Product, 'Bike') > 0").cast('int')) \
    .withColumn('Total', expr("Quantity * Price").cast('decimal'))
```

```python
# Write the stream to a delta table
output_table_path = 'Tables/orders_processed'
checkpointpath = 'Files/delta/checkpoint'
deltastream = transformed_df.writeStream.format("delta").option("checkpointLocation", checkpointpath).start(output_table_path)

print("Streaming to orders_processed...")
```

```sql
%%sql
SELECT *
    FROM orders_processed
    ORDER BY OrderID;
```

```python
# Stop the streaming data to avoid excessive processing costs
delta_stream.stop()
```

### Exercise

```python
df = spark.read.format("csv").option("header","true").load("Files/products/products.csv")
# df now is a Spark DataFrame containing CSV data from "Files/products/products.csv".
display(df)
```

```python
df.write.format("delta").saveAsTable("managed_products")
```

Criar uma tabela externa

```python
df.write.format("delta").saveAsTable("external_products", path="abfs_path/external_products")
```

Comparar tabelas gerenciadas e externas

```sql
%%sql

DESCRIBE FORMATTED managed_products;
```

```sql
%%sql

DROP TABLE managed_products;
DROP TABLE external_products;
```

```sql
%%sql

CREATE TABLE products
USING DELTA
LOCATION 'Files/external_products';
```

```sql
%%sql

SELECT * FROM products;
```

## Explorar o controle de versão de tabela

```sql
%%sql

UPDATE products
SET ListPrice = ListPrice * 0.9
WHERE Category = 'Mountain Bikes';
```

```sql
%%sql

DESCRIBE HISTORY products;
```

```python
delta_table_path = 'Files/external_products'

# Get the current data
current_data = spark.read.format("delta").load(delta_table_path)
display(current_data)

# Get the version 0 data
original_data = spark.read.format("delta").option("versionAsOf", 0).load(delta_table_path)
display(original_data)
```

## Usar tabelas delta para transmitir dados

```python
from notebookutils import mssparkutils
from pyspark.sql.types import *
from pyspark.sql.functions import *

# Create a folder
inputPath = 'Files/data/'
mssparkutils.fs.mkdirs(inputPath)

# Create a stream that reads data from the folder, using a JSON schema
jsonSchema = StructType([
StructField("device", StringType(), False),
StructField("status", StringType(), False)
])
iotstream = spark.readStream.schema(jsonSchema).option("maxFilesPerTrigger", 1).json(inputPath)

# Write some event data to the folder
device_data = '''{"device":"Dev1","status":"ok"}
{"device":"Dev1","status":"ok"}
{"device":"Dev1","status":"ok"}
{"device":"Dev2","status":"error"}
{"device":"Dev1","status":"ok"}
{"device":"Dev1","status":"error"}
{"device":"Dev2","status":"ok"}
{"device":"Dev2","status":"error"}
{"device":"Dev1","status":"ok"}'''
mssparkutils.fs.put(inputPath + "data.txt", device_data, True)
print("Source stream created...")
```

```python
# Write the stream to a delta table
delta_stream_table_path = 'Tables/iotdevicedata'
checkpointpath = 'Files/delta/checkpoint'
deltastream = iotstream.writeStream.format("delta").option("checkpointLocation", checkpointpath).start(delta_stream_table_path)
print("Streaming to delta sink...")
```

```sql
%%sql

SELECT * FROM IotDeviceData;
```

```python
# Add more data to the source stream
more_data = '''{"device":"Dev1","status":"ok"}
{"device":"Dev1","status":"ok"}
{"device":"Dev1","status":"ok"}
{"device":"Dev1","status":"ok"}
{"device":"Dev1","status":"error"}
{"device":"Dev2","status":"error"}
{"device":"Dev1","status":"ok"}'''

mssparkutils.fs.put(inputPath + "more-data.txt", more_data, True)
```

```sql
%%sql

SELECT * FROM IotDeviceData;
```

```python
deltastream.stop()
```









