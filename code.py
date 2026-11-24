import os

import psycopg
from psycopg import sql


def main() -> None:
    required_settings = ("PGHOST", "PGPORT", "PGDATABASE", "PGUSER", "PGPASSWORD", "PGTABLE")
    missing_settings = [name for name in required_settings if not os.environ.get(name)]
    if missing_settings:
        raise SystemExit(
            "Set these environment variables before running: "
            + ", ".join(missing_settings)
        )

    schema = os.environ.get("PGSCHEMA", "public")
    table = os.environ["PGTABLE"]

    with psycopg.connect(
        host=os.environ["PGHOST"],
        port=int(os.environ["PGPORT"]),
        dbname=os.environ["PGDATABASE"],
        user=os.environ["PGUSER"],
        password=os.environ["PGPASSWORD"],
    ) as connection:
        with connection.cursor() as cursor:
            query = sql.SQL("SELECT * FROM {}.{} LIMIT 100").format(
                sql.Identifier(schema),
                sql.Identifier(table),
            )
            cursor.execute(query)

            columns = [column.name for column in cursor.description]
            print(" | ".join(columns))
            for row in cursor.fetchall():
                print(" | ".join(str(value) for value in row))


if __name__ == "__main__":
    main()