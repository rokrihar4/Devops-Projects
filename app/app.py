from flask import Flask, jsonify
import os, psycopg2, redis

app = Flask(__name__)

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

@app.route("/")
def index():
    hits = r.incr("hits")
    return jsonify({
        "message": "Hello from Flask via Nginx + Gunicorn",
        "hits": hits,
        "db_time": str(db_now())
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
