# hockey-infra

Infrastructure repository for a hockey ticket purchasing application.

Contains Docker Compose stacks, Caddy configuration, deploy scripts and CI/CD for [`https://hockey.zudar.ru`](https://hockey.zudar.ru).

Application repositories:

- [`hockey-team`](https://github.com/TanyaMasharova/hockey-team) — Go REST API
- [`hockey_team_front`](https://github.com/TanyaMasharova/hockey_team_front) — Next.js frontend

## Repository Structure

```
hockey-infra/
├── compose.local.yml       # Local stack (built from source)
├── compose.prod.yml        # Production stack (images from GHCR)
├── Caddyfile.local         # Caddy for local development (port 80)
├── Caddyfile               # Caddy for production (HTTPS, hockey.zudar.ru)
├── .env.example            # Environment variable template for local stack
├── .env.prod.example       # Environment variable template for production stack
└── scripts/
    ├── deploy-backend.sh   # Deploy a new backend version
    └── deploy-frontend.sh  # Deploy a new frontend version
```

For local use the application repositories must be placed alongside:

```
hockey/
├── hockey-infra/
├── hockey-team/
└── hockey_team_front/
```

## Local Stack

### Prerequisites

- Docker with Compose plugin
- Source code of `hockey-team` and `hockey_team_front` in sibling directories

### Quick Start

```bash
cp .env.example .env
# Set DB_PASSWORD in .env

docker compose -f compose.local.yml up --build
```

Services in the local stack:

| Service | Image | Description |
|---|---|---|
| `postgres` | `postgres:17-alpine` | Database |
| `migrate` | `migrate/migrate:v4.18.1` | Applies migrations and exits |
| `backend` | built from `../hockey-team` | Go API on port 8080 |
| `frontend` | built from `../hockey_team_front` | Next.js on port 3000 |
| `caddy` | `caddy:2-alpine` | Reverse proxy on port 80 |

The application is available at `http://localhost`.
Caddy routes `/api/*` to the backend and everything else to the frontend.

### Stopping

```bash
# Stop the stack
docker compose -f compose.local.yml down

# Stop and remove database volume
docker compose -f compose.local.yml down -v
```

## Production Stack

### Environment Variables

Create a `.env` file in `~/hockey-infra/` on the server:

```bash
cp .env.prod.example .env
```

| Variable | Description |
|---|---|
| `DB_USER` | PostgreSQL user |
| `DB_PASSWORD` | PostgreSQL password |
| `DB_NAME` | Database name |
| `BACKEND_TAG` | Backend image tag (updated by deploy script) |
| `FRONTEND_TAG` | Frontend image tag (updated by deploy script) |

### Initial Start

```bash
docker compose -f compose.prod.yml pull
docker compose -f compose.prod.yml up -d
```

### Deploying a New Version

Update the backend:

```bash
./scripts/deploy-backend.sh v1.2.3
```

The script updates `BACKEND_TAG` in `.env`, pulls the new image, runs migrations and restarts only the `backend` service without stopping the rest of the stack.

Update the frontend:

```bash
./scripts/deploy-frontend.sh v1.2.3
```

Under normal operation deploys are triggered automatically by GitHub Actions when a GitHub Release is published in the application repository.

## CI/CD

### PR Validation

On every PR to `master`:

- `compose.local.yml` syntax is validated (`docker compose config`)
- `Caddyfile.local` configuration is validated (`caddy validate`)

### GitHub Secrets

The following secrets must be added to the `hockey-team` and `hockey_team_front` repositories:

| Secret | Value |
|---|---|
| `SSH_PRIVATE_KEY` | ED25519 private key for server access |
| `SSH_HOST` | Production server IP address |
| `SSH_USER` | `hockey-deploy` |

`GITHUB_TOKEN` is generated automatically. **Read and write permissions** must be enabled in Settings → Actions → General for both repositories.

## Server Bootstrap

One-time setup for a new production server (Ubuntu 24.04, Docker already installed):

```bash
# 1. Create the deploy user
useradd -m -s /bin/bash hockey-deploy
usermod -aG docker hockey-deploy

# 2. Add the GitHub Actions public SSH key
mkdir -p /home/hockey-deploy/.ssh
echo "<public_key>" >> /home/hockey-deploy/.ssh/authorized_keys
chmod 700 /home/hockey-deploy/.ssh
chmod 600 /home/hockey-deploy/.ssh/authorized_keys
chown -R hockey-deploy:hockey-deploy /home/hockey-deploy/.ssh

# 3. Log in to GHCR (requires a PAT with read:packages scope)
su - hockey-deploy -c "echo '<PAT>' | docker login ghcr.io -u TanyaMasharova --password-stdin"

# 4. Clone this repository
su - hockey-deploy -c "git clone https://github.com/TanyaMasharova/hockey-infra.git ~/hockey-infra"

# 5. Create .env with production secrets
su - hockey-deploy -c "cp ~/hockey-infra/.env.prod.example ~/hockey-infra/.env"
# Edit .env manually (DB_PASSWORD, image tags)

# 6. Start the stack
su - hockey-deploy -c "docker compose -f ~/hockey-infra/compose.prod.yml up -d"
```

After the first start Caddy will automatically obtain a TLS certificate from Let's Encrypt for `hockey.zudar.ru`.
