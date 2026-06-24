import duckdb

con = duckdb.connect("/project/airbnb.duckdb")

files = {
    "listings":       "data/listings.csv.gz",
    "calendar":       "data/calendar.csv.gz",
    "reviews":        "data/reviews.csv.gz",
    "neighbourhoods": "data/neighbourhoods.csv",
}

for table, path in files.items():
    print(f"Loading {table}...")
    con.execute(f"""
        CREATE OR REPLACE TABLE {table} AS
        SELECT * FROM read_csv_auto('{path}')
    """)

print("\nDone! Tables loaded:")
for row in con.execute("SHOW TABLES").fetchall():
    print(" -", row[0])