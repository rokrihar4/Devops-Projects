from flask import Flask, jsonify, request
from flask_cors import CORS
import os
import psycopg2
import psycopg2.extras
import redis

app = Flask(__name__)
CORS(app)

DB_DSN = os.getenv(
    "DB_DSN",
    "dbname=demo user=demo password=demo host=127.0.0.1"
)
REDIS_URL = os.getenv("REDIS_URL", "redis://127.0.0.1:6379/0")
r = redis.from_url(REDIS_URL)

def get_conn():
    return psycopg2.connect(DB_DSN)

def db_now():
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT now()")
            return cur.fetchone()[0]

@app.route("/api/message", methods=["GET"])
def message():
    hits = r.incr("hits")
    return jsonify({
        "message": "Hello from Flask via Nginx + Gunicorn",
        "hits": hits,
        "db_time": str(db_now())
    })

# 1) READ all items
@app.route("/api/items", methods=["GET"])
def list_items():
    r.incr("items_list_hits")
    with get_conn() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute("""
                SELECT id, name, description, created_at
                FROM items
                ORDER BY id;
            """)
            rows = cur.fetchall()
            # rows are dicts already with RealDictCursor
            # convert datetime to string for JSON safety
            for row in rows:
                row["created_at"] = row["created_at"].isoformat() if row["created_at"] else None
            return jsonify(rows)

# (Optional) keep your old endpoint name as alias
@app.route("/api/dbdemo", methods=["GET"])
def dbdemo_alias():
    return list_items()

# 2) CREATE item
@app.route("/api/items", methods=["POST"])
def add_item():
    r.incr("items_add_hits")
    data = request.get_json(silent=True) or {}

    name = (data.get("name") or "").strip()
    description = (data.get("description") or "").strip()

    if not name:
        return jsonify({"error": "name is required"}), 400

    with get_conn() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute("""
                INSERT INTO items (name, description)
                VALUES (%s, %s)
                RETURNING id, name, description, created_at;
            """, (name, description or None))
            row = cur.fetchone()
            row["created_at"] = row["created_at"].isoformat() if row["created_at"] else None
            return jsonify(row), 201

# 3) DELETE item by id
@app.route("/api/items/<int:item_id>", methods=["DELETE"])
def delete_item(item_id: int):
    r.incr("items_delete_hits")
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM items WHERE id = %s RETURNING id;", (item_id,))
            deleted = cur.fetchone()
            if not deleted:
                return jsonify({"error": "not found"}), 404
            return jsonify({"deleted_id": deleted[0]})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
