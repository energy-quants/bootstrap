# Install the Simba Spark ODBC Driver

Installs the Simba Spark ODBC Driver
  * https://docs.databricks.com/en/integrations/odbc/download.html


```bash
❯ ./install.sh --help
Installs the specified version of the Simba Spark ODBC driver .
Usage: ./install.sh [-v|--version <arg>] [-h|--help]
        -v, --version: The version of the Simba Spark ODBC driver to download and install. (no default)
        -h, --help: Prints help
```

----

### Documentation

A DSN-less connection string can be created as below:
```python
import pyodbc

connection_str = (
    "Driver=/opt/simba/spark/lib/64/libsparkodbc_sb64.so;"
    f"Host={os.environ['DATABRICKS_HOST']};"
    "Port=443;"
    f"HTTPPath={os.environ['DATABRICKS_HTTP_PATH']};"
    "SSL=1;"
    "ThriftTransport=2;"
    "AuthMech=3;"
    "UID=token;"
    f"PWD={os.environ['DATABRICKS_TOKEN']}"
)
try:
    with pyodbc.connect(connection_str, autocommit=True) as conn:
        with conn.cursor() as cursor:
            cursor.fast_executemany = True
            cursor.execute("select current_user()")
            user = cursor.fetchone()[0]
except Exception:
    raise
else:
    print(user)
finally:
    conn.close()
```
