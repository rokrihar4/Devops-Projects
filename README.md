# DevOps Project – Vagrant & Cloud-init Application Stack

## 1. Project Overview

This project provisions a complete web application stack on Linux using:

- **Nginx** – HTTP reverse proxy and static file server
- **React (Vite)** – frontend SPA served by Nginx
- **Flask + Gunicorn** – backend API
- **PostgreSQL** – relational database
- **Redis** – in-memory cache / counter

The goal is to demonstrate **Infrastructure as Code** using:

- **Vagrant + shell provisioning** (local VirtualBox VM)
- **Cloud-init** (for running the same/similar stack in a cloud/VM environment)

Everything is versioned in Git and designed to be reproducible from scratch.

---

## 2. Architecture

### Components

- **Frontend** (`frontend/`)
  - React app built with Vite.
  - Built output (`dist/`) is synced into the VM and served by Nginx from `/var/www/html/react`.
  - Talks to the backend over:
    - `GET /api/message`
    - `GET /api/dbdemo`

- **Backend** (`app/app.py`)
  - Flask application with CORS enabled.
  - Runs behind Gunicorn, bound to `127.0.0.1:5000`.
  - Exposes:
    - `GET /api/message`
      - Returns a greeting, Redis hit counter, and current DB time.
    - `GET /api/dbdemo`
      - Returns rows from the `items` table in PostgreSQL.
  - Configuration via environment:
    - `DB_DSN` (PostgreSQL connection string)
    - `REDIS_URL` (Redis connection string)

- **PostgreSQL**
  - Database name: `demo`
  - User: `demo`
  - Password: `demo`
  - Table: `items`
    - `id SERIAL PRIMARY KEY`
    - `name TEXT`
    - `description TEXT`
    - `created_at TIMESTAMPTZ DEFAULT NOW()`
  - Pre-populated with sample rows by provisioning (Vagrant or cloud-init).

- **Redis**
  - Used as a simple cache / counter:
    - `hits` for `/api/message`
    - `dbdemo_hits` for `/api/dbdemo`

- **Nginx**
  - Serves static frontend from `/var/www/html/react`.
  - Reverse-proxies `/api/` to Gunicorn at `http://127.0.0.1:5000`.

---

## 3. Repository Structure

```text
Devops-Projects/
├── .gitattributes
├── .gitignore
├── README.md                # (this file)
├── Vagrantfile              # Vagrant definition for Ubuntu VM
├── setup-myapp.ps1          # Helper script (Windows)
├── app/                     # Flask backend
│   ├── app.py
│   ├── app copy.py
│   ├── requirements.txt
│   └── venv/                # local dev venv (ignored in VM provisioning)
├── frontend/                # React/Vite frontend
│   ├── src/App.jsx          # React app (calls /api/message, /api/dbdemo)
│   ├── ...                  # other Vite/React files
│   └── dist/                # production build served by Nginx
├── provision/               # Vagrant provisioning artifacts
│   ├── provision.sh         # main shell provisioner
│   ├── app.env              # environment vars for app
│   ├── app.service          # systemd unit for Gunicorn
│   └── nginx-default.conf   # Nginx site configuration
└── cloud-init/              # cloud-init configuration (second deployment variant)
    └── user-data.yaml       # cloud-init config for same stack
