param(
  [string]$Name = "myapp"
)

multipass set local.privileged-mounts=true

multipass launch jammy `
  --name $Name `
  --cloud-init cloud-init/cloud-config.yaml `
  --mount .\app:/opt/myapp `
  --mount .\frontend\dist:/var/www/html/react

multipass exec $Name -- bash -lc "cloud-init status --wait"

multipass exec $Name -- sudo -u ubuntu /opt/venvs/myapp/bin/pip install -r /opt/myapp/requirements.txt

multipass exec $Name -- sudo systemctl restart app
