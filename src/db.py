import os
from pathlib import Path

import psycopg
from psycopg import sql

from typing import LiteralString, cast

from dotenv import load_dotenv
load_dotenv(Path(__file__).with_name(".env"))

required_settings = ("PGHOST", "PGDATABASE", "PGUSER", "PGPASSWORD")
missing_settings = [name for name in required_settings if not os.getenv(name)]
if missing_settings:
    raise RuntimeError(
        f"Missing database settings in src/.env: {', '.join(missing_settings)}"
    )

def get_connection():
    try:
        conn = psycopg.connect(
            host=os.environ["PGHOST"],
            port=os.getenv("PGPORT") or "5432",
            dbname=os.environ["PGDATABASE"],
            user=os.environ["PGUSER"],
            password=os.environ["PGPASSWORD"],
        )
        return conn
    except psycopg.OperationalError as e:
        raise RuntimeError(f"Failed to connect to the database: {e}")

def init_db():
    with get_connection() as conn:
        with conn.cursor() as cur:
            init_sql_path = Path(__file__).with_name("init.sql")
            with open(init_sql_path, "r", encoding="utf-8") as f:
                cur.execute(sql.SQL(cast(LiteralString, f.read())))
            conn.commit()

init_db()



'''
Teste de conexão com o banco de dados

with get_connection() as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT version()")
        print(cur.fetchone())
'''

