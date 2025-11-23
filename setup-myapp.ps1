param(
  [string]$Name = "myapp"
)

# 1. Ustvari VM + mounta kode in frontenda
multipass launch jammy `
  --name $Name `
  --cloud-init cloud-init/cloud-config.yaml `
  --mount .\app:/opt/myapp `
  --mount .\frontend\dist:/var/www/html/react

# 2. Počakaj, da cloud-init v VM-ju konča
multipass exec $Name -- bash -lc "cloud-init status --wait"

# 3. Namesti Python pakete iz mountanega folderja
multipass exec $Name -- sudo -u ubuntu /opt/venvs/myapp/bin/pip install -r /opt/myapp/requirements.txt

# 4. Restartaj app service (zdaj ima vse pakete)
multipass exec $Name -- sudo systemctl restart app
