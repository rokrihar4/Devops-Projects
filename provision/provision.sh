#!/usr/bin/env bash
set -eux

sudo apt-get update -y
sudo apt-get install -y \
  nginx \
  python3 \
  python3-venv \
  postgresql \
  lsb-release \
  curl \
  gpg \
  ca-certificates

curl -fsSL https://packages.redis.io/gpg \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/redis-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/redis.list >/dev/null

sudo apt-get update -y
sudo apt-get install -y redis

# Redis tuning
echo 'vm.overcommit_memory=1' | sudo tee /etc/sysctl.d/99-redis.conf
sudo sysctl -p /etc/sysctl.d/99-redis.conf || true

sudo systemctl enable --now redis-server

sudo -u postgres -H psql -tc "SELECT 1 FROM pg_database WHERE datname='demo'" | grep -q 1 || sudo -u postgres createdb demo
sudo -u postgres -H psql -tc "SELECT 1 FROM pg_roles WHERE rolname='demo'" | grep -q 1 || sudo -u postgres psql -c "CREATE USER demo WITH PASSWORD 'demo';"
sudo -u postgres -H psql -c "GRANT ALL PRIVILEGES ON DATABASE demo TO demo"

sudo -u postgres psql -d demo <<'SQL'
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO items (name, description)
VALUES
    ('The first one', 'Created by provision.sh'),
    ('Second one', 'Also from provision.sh')
ON CONFLICT (name) DO NOTHING;
SQL

sudo -u postgres psql -d demo -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO demo;"
sudo -u postgres psql -d demo -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO demo;"


sudo mkdir -p /opt/myapp
sudo rsync -a --exclude 'venv/' /vagrant/app/ /opt/myapp/

sudo mkdir -p /opt/venvs
sudo chown -R vagrant:vagrant /opt/venvs

sudo -u vagrant python3 -m venv /opt/venvs/myapp
sudo -u vagrant /opt/venvs/myapp/bin/pip install -U pip setuptools wheel
sudo -u vagrant /opt/venvs/myapp/bin/pip install -r /opt/myapp/requirements.txt

#  Systemd service za gunicorn, referencira /usr/bin/gunicorn,
#  tu ga prepišemo na venv gunicorn:
sudo sed -i 's#/usr/bin/gunicorn#/opt/venvs/myapp/bin/gunicorn#' /vagrant/provision/app.service

sudo mkdir -p /etc/myapp
sudo cp /vagrant/provision/app.env /etc/myapp/app.env
sudo cp /vagrant/provision/app.service /etc/systemd/system/app.service
sudo systemctl daemon-reload
sudo systemctl enable --now app

# Nginx za proxy do app-a in statični React
sudo mkdir -p /var/www/html/react

sudo cp /vagrant/provision/nginx-default.conf /etc/nginx/sites-available/default
sudo nginx -t
sudo systemctl reload nginx

curl -fsS http://127.0.0.1/api/message >/dev/null \
  && echo "App dela čez nginx." \
  || echo "Use zagnal sam ni html 200 response"
