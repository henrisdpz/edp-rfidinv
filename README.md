# PostgreSQL connection example

`src/db.py` connects to PostgreSQL with Psycopg and prints the server version.

## Configure the connection

Copy `src/.env.example` to `src/.env` and fill in the values for your database.
Keep `src/.env` private; Git ignores it.

Install the dependencies and run the module from the repository root:

```powershell
python -m pip install -r requirements.txt
python -m src.db
```