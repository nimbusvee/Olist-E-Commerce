import psycopg2
import pandas as pd
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

# Load security credentials
load_dotenv()

def ingest_csv(csv_path, table_name, db_user, db_pass, db_name):    
    
    # SQLAlchemy connection string (needed for Pandas)
    db_url = f"postgresql://{db_user}:{db_pass}@localhost:5432/{db_name}"
    engine = create_engine(db_url)

    conn = None
    cur = None

    try:
        #Read only the header row (0 rows of data) to get the schema
        print(f"📊 Inspecting {csv_path} to generate table schema...")
        df_empty = pd.read_csv(csv_path, nrows=0)
        
        # Create the empty table in Postgres automatically
        df_empty.to_sql(table_name, engine, if_exists='replace', index=False)
        print(f"🏗️ Empty table '{table_name}' successfully created with {len(df_empty.columns)} columns.")

      # Connect via psycopg2 for the high-speed COPY
        print("⚡ Initiating high-speed Bulk COPY...")
        conn = psycopg2.connect(
            host="localhost",
            database=db_name,
            user=db_user,
            password=db_pass,
            port="5432"
        )
        cur = conn.cursor()

        with open(csv_path, 'r', encoding='utf-8') as f:
            sql = f"COPY {table_name} FROM STDIN WITH (FORMAT CSV, HEADER)"
            cur.copy_expert(sql, f)
        
        conn.commit()
        print(f"🚀 Success! All records from {csv_path} have been loaded into '{table_name}'.\n")

    except Exception as e:
        print(f"❌ Error during ingestion of {table_name}: {e}\n")
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

if __name__ == "__main__":
    # Setup connection variables
    db_user = os.getenv("DB_USER")
    db_pass = os.getenv("DB_PASSWORD")
    db_name = os.getenv("DB_NAME")
    
    # Mapping the Olist CSV files to their Postgres bronze tables
    tables_to_load = {
        "data/olist_customers_dataset.csv": "bronze_customers",
        "data/olist_orders_dataset.csv": "bronze_orders",
        "data/olist_order_items_dataset.csv": "bronze_order_items",
        "data/olist_order_payments_dataset.csv": "bronze_order_payments",
        "data/olist_order_reviews_dataset.csv": "bronze_order_reviews",
        "data/olist_products_dataset.csv": "bronze_products",
        "data/olist_sellers_dataset.csv": "bronze_sellers",
        "data/olist_geolocation_dataset.csv": "bronze_geolocation",
        "data/product_category_name_translation.csv": "bronze_category_translation"
    }
    
    # Loop through the dictionary and load each file
    for csv_file, table in tables_to_load.items():
        if os.path.exists(csv_file):
            ingest_csv(csv_file, table, db_user, db_pass, db_name)
        else:
            print(f"⚠️ Warning: File {csv_file} not found. Skipping...\n")