#!/usr/bin/env bash
set -euxo pipefail

sudo apt-get install -y nginx python3-pip python3-venv postgresql redis-server

sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='demo'" | grep -q 1 || sudo -u postgres createdb demo
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='demo'" | grep -q 1 || sudo -u postgres psql -c "CREATE USER demo WITH PASSWORD 'demo';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE demo TO demo"

sudo mkdir -p /opt/myapp
sudo cp -r /vagrant/app/* /opt/myapp/
sudo chown -R www-data:www-data /opt/myapp

sudo -u www-data python3 -m venv /opt/myapp/.venv
sudo -u www-data /opt/myapp/.venv/bin/pip install -U pip
sudo -u www-data /opt/myapp/.venv/bin/pip install -r /opt/myapp/requirements.txt

sudo sed -i 's#/usr/bin/gunicorn#/opt/myapp/.venv/bin/gunicorn#' /vagrant/provision/app.service

sudo systemctl enable --now redis-server

sudo cp /vagrant/provision/nginx-default.conf /etc/nginx/sites-available/default
sudo mkdir -p /var/www/html && echo "<h1>Welcome (static)</h1>" | sudo tee /var/www/html/index.html >/dev/null
sudo nginx -t
sudo systemctl enable --now nginx

sudo mkdir -p /etc/myapp
sudo cp /vagrant/provision/app.env /etc/myapp/app.env
sudo cp /vagrant/provision/app.service /etc/systemd/system/app.service
sudo systemctl daemon-reload
sudo systemctl enable --now app

curl -fsS http://127.0.0.1/ >/dev/null && echo "App reachable via Nginx."
