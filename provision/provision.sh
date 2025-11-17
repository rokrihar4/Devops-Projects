#!/usr/bin/env bash
set -euxo pipefail

# offical redis install
sudo apt-get update -y
sudo apt-get install -y nginx python3 postgresql lsb-release curl gpg ca-certificates python3.10-venv

curl -fsSL https://packages.redis.io/gpg \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/redis-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/redis.list >/dev/null

sudo apt-get update -y
sudo apt-get install -y redis

sudo -u postgres -H psql -tc "SELECT 1 FROM pg_database WHERE datname='demo'" | grep -q 1 || sudo -u postgres createdb demo
sudo -u postgres -H psql -tc "SELECT 1 FROM pg_roles WHERE rolname='demo'" | grep -q 1 || sudo -u postgres psql -c "CREATE USER demo WITH PASSWORD 'demo';"
sudo -u postgres -H psql -c "GRANT ALL PRIVILEGES ON DATABASE demo TO demo"

sudo rm -rf /opt/myapp/.venv

sudo mkdir -p /opt/myapp
#sudo cp -r /vagrant/app/* /opt/myapp/
sudo chown -R www-data:www-data /opt/myapp

sudo mkdir -p /opt/venvs
sudo chown -R www-data:www-data /opt/venvs
sudo -u www-data /usr/bin/python3 -m venv /opt/venvs/myapp
sudo -u www-data /opt/venvs/myapp/bin/pip install -U pip setuptools wheel
sudo -u www-data /opt/venvs/myapp/bin/pip install -r /opt/myapp/requirements.txt
# sudo pip3 install -r requirments.txt

sudo sed -i 's#/usr/bin/gunicorn#/opt/myapp/.venv/bin/gunicorn#' /vagrant/provision/app.service

sudo cp /vagrant/provision/nginx-default.conf /etc/nginx/sites-available/default
sudo mkdir -p /var/www/html/react
sudo nginx -t
sudo systemctl enable --now nginx
#sudo rm -rf /var/www/html/index.nginx-debian.html

# sudo python3 flash run

sudo mkdir -p /etc/myapp
sudo cp /vagrant/provision/app.env /etc/myapp/app.env
sudo cp /vagrant/provision/app.service /etc/systemd/system/app.service
sudo systemctl daemon-reload
sudo systemctl enable --now app

curl -fsS http://127.0.0.1/ >/dev/null && echo "App reachable via Nginx."
