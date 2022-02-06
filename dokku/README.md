# Dokku

A collection of terraform, packer, nginx, and systemd scripts to build out and configure my own heroku.

## Cheatsheet

### App Management

- Create app: `dokku apps:create mammoth`
- Run script: `dokku run mammoth python scripts/jobs/seed_lifts.py`
- Set environment variable: `dokku config:set mammoth BASE_URL=http://mammoth.dokku.maxworld.tech`

### Postgres

- Create a db: `dokku postgres:create mammoth-db`
- Link db to app: `dokku postgres:link mammoth-db mammoth`
- Connect via psql: `dokku postgres:connect mammoth-db`

### Set Up Cron

Use `dokku` user's crontab (e.g. `sudo crontab -u dokku -e`) and then something like `*/10 * * * * dokku run python app/jobs/update_lift_statuses.py`.
