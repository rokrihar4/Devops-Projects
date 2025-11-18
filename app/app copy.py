# To je samo backup ker prvision.sh rad koruptira originalen app.py
from flask import Flask, jsonify
from flask_cors import CORS
import os, psycopg2, redis

app = Flask(__name__)
CORS(app)
DB_DSN = os.getenv("DB_DSN", "dbname=demo user=demo password=demo host=127.0.0.1")
REDIS_URL = os.getenv("REDIS_URL", "redis://127.0.0.1:6379/0")
r = redis.from_url(REDIS_URL)

def db_now():
    conn = psycopg2.connect(DB_DSN)
    cur = conn.cursor()
    cur.execute("SELECT now()")
    val = cur.fetchone()[0]
    cur.close() 
    conn.close()
    return val

@app.route("/api/message")
def index():
    hits = r.incr("hits")
    return jsonify({
        "message": "Hello from Flask via Nginx + Gunicorn",
        "hits": hits,
        "db_time": str(db_now())
    })

@app.route("/api/dbdemo")
def dbdemo():
    hits = r.incr("dbdemo_hits")
    conn = psycopg2.connect(DB_DSN)
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT id, name, description FROM items ORDER BY id;")
            rows = cur.fetchall()
        items = [
            {"id": row[0], "name": row[1], "description": row[2]}
            for row in rows
        ]
        return jsonify(items)
    finally:
        conn.close()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)