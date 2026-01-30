import pandas as pd
import os
import shutil
import logging
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

INPUT_DIR = "data/input"
ARCHIVE_DIR = "data/archive"
ERROR_DIR = "data/error"

logging.basicConfig(
    filename="logs/loader.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def validate_row(row):
    if pd.isna(row["name"]) or pd.isna(row["city"]):
        return False
    return True

def load_cinemas():
    conn = get_connection()
    cursor = conn.cursor()

    for file in os.listdir(INPUT_DIR):
        if not file.endswith(".csv"):
            continue

        file_path = os.path.join(INPUT_DIR, file)
        try:
            df = pd.read_csv(file_path, sep=";")

            for _, row in df.iterrows():
                if not validate_row(row):
                    raise ValueError("Niepoprawne dane")

                cursor.execute("""
                    INSERT INTO pr_cinemas
                    (name, city, address, phone, email)
                    VALUES (:1, :2, :3, :4, :5)
                """, (
                    row["name"],
                    row["city"],
                    row["address"],
                    row["phone"],
                    row["email"]
                ))

            conn.commit()
            cursor.execute("""
                INSERT INTO pr_load_log
                (file_name, status, rows_loaded)
                VALUES (:1, 'SUCCESS', :2)
            """, (file, len(df)))
            conn.commit()
            shutil.move(file_path, os.path.join(ARCHIVE_DIR, file))
            logging.info(f"Załadowano plik {file}")

        except Exception as e:
            conn.rollback()
            cursor.execute("""
                INSERT INTO pr_load_log
                (file_name, status, rows_loaded, error_message)
                VALUES (:1, 'ERROR', 0, :2)
            """, (file, str(e)))
            conn.commit()
            shutil.move(file_path, os.path.join(ERROR_DIR, file))
            logging.error(f"Błąd w pliku {file}: {e}")

    cursor.close()
    conn.close()

if __name__ == "__main__":
    load_cinemas()
