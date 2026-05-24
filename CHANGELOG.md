# Changelog

All notable changes to this repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [0.1.0] — 2026-05-19

### Added

- `compose.local.yml`: five-service local stack (postgres, migrate, backend, frontend, caddy) with a single entry point on port 80.
- `Caddyfile.local`: routes `/api/*` to backend, everything else to frontend.
- `compose.prod.yml`: production stack with GHCR images, Caddy on ports 80 and 443, automatic TLS.
- `Caddyfile`: HTTPS for `hockey.zudar.ru` via Let's Encrypt.
- `scripts/deploy-backend.sh`: updates image tag, pulls image, runs migrations, restarts backend.
- `scripts/deploy-frontend.sh`: updates image tag, pulls image, restarts frontend.
- `.env.example` and `.env.prod.example`: environment variable templates with no secrets.
- CI: `compose.local.yml` and `Caddyfile.local` validation on every PR to `master`.
