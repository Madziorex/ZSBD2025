import oracledb
import oracledb

def get_connection():
    dsn = oracledb.makedsn(
        host="213.184.8.44",
        port=1521,
        service_name="orcl"
    )

    return oracledb.connect(
        user="WOJCIECHOWSKAM",
        password="TheBest4Madzia",
        dsn=dsn
    )

conn = get_connection()
cur = conn.cursor()
cur.execute("SELECT 'OK' FROM dual")
print(cur.fetchone())
conn.close()
