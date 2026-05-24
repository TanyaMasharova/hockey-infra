## What changed

<!-- Briefly describe the nature of the change -->

## Type of change

- [ ] Local stack change (`compose.local.yml`)
- [ ] Production stack change (`compose.prod.yml`)
- [ ] Caddy configuration change
- [ ] Deploy scripts change
- [ ] CI/CD change
- [ ] Documentation

## Checklist

- [ ] `docker compose -f compose.local.yml config` passes without errors
- [ ] If `Caddyfile.local` was modified — validated with `caddy validate`
- [ ] No secrets or real credentials are present in the changes
