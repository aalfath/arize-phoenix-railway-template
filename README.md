[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/arize-phoenix-1?utm_medium=integration&utm_source=button&utm_campaign=arize-phoenix)

# Arize Phoenix on Railway

A Railway template for [Arize Phoenix](https://github.com/Arize-ai/phoenix), the open-source AI observability and evaluation platform (LLM tracing over OpenTelemetry, evals, datasets, experiments, prompt playground).

## What it deploys

| Service | Source | Notes |
|---|---|---|
| **Phoenix** | this repo (`Dockerfile`) | `arizephoenix/phoenix:21.1.0`, pinned by digest. UI, REST API and OTLP/HTTP on port 6006 (public domain), OTLP/gRPC on 4317 (private network). Health check `/readyz` (checks the database). |
| **Postgres** | Railway Postgres | Holds every trace, project, dataset, experiment, prompt, user and API key. Data lives on its volume. |

The Phoenix container keeps no local state: everything is in Postgres, so a redeploy or restart of Phoenix loses nothing.

## Variables

All are filled in by the template. No prompts.

| Variable | Default | Why |
|---|---|---|
| `PORT` | `6006` | Port Railway routes the public domain to. |
| `PHOENIX_SQL_DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Phoenix's database, over the private network. |
| `PHOENIX_SECRET` | `${{secret(64,"abcdef0123456789")}}` | Signs login tokens and encrypts saved provider keys. Keep it: changing it logs everyone out and makes saved keys unreadable. |
| `PHOENIX_DEFAULT_ADMIN_INITIAL_PASSWORD` | `${{secret(24)}}` | First password of the `admin@localhost` account, so the public URL never accepts `admin`/`admin`. Used only when the admin is first created. |
| `PHOENIX_ROOT_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL used in links and cookies. |
| `PHOENIX_CSRF_TRUSTED_ORIGINS` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Rejects browser requests from other sites. |

Fixed settings are baked into the `Dockerfile`: listen on `::` (IPv4 and IPv6), port 6006, gRPC 4317, authentication on, secure cookies on.

Optional features you can add as variables later: SMTP (`PHOENIX_SMTP_HOSTNAME`, `PHOENIX_SMTP_PORT`, `PHOENIX_SMTP_USERNAME`, `PHOENIX_SMTP_PASSWORD`, `PHOENIX_SMTP_MAIL_FROM`), OAuth2 sign-in, LDAP, `PHOENIX_DEFAULT_RETENTION_POLICY_DAYS`. See the [Phoenix configuration docs](https://arize.com/docs/phoenix/self-hosting/configuration).

## After deploy

1. Open the service's Railway URL and sign in as `admin@localhost` with the value of `PHOENIX_DEFAULT_ADMIN_INITIAL_PASSWORD` (Phoenix service → Variables). Change the password in your profile.
2. Create an API key under **Settings → API Keys**.
3. Send traces: `PHOENIX_COLLECTOR_ENDPOINT=https://YOUR-DOMAIN` and `PHOENIX_API_KEY=<key>` with `phoenix-otel` / OpenInference, or OTLP/HTTP (protobuf) to `https://YOUR-DOMAIN/v1/traces`. Services in the same Railway project can use OTLP/gRPC at `http://${{Phoenix.RAILWAY_PRIVATE_DOMAIN}}:4317`.

## Updates

The Phoenix service builds from this repo. When we bump the pinned version on `main`, Railway shows an "update available" notice on your project, and you choose when to apply it. Phoenix runs its database migrations on start. Read [CHANGELOG.md](CHANGELOG.md) before you apply an update.

## Local test

```sh
docker compose -f local-test/compose.yaml up -d --build
# open http://localhost:6006, sign in as admin@localhost / LocalTestPass123
```

Phoenix is licensed under the [Elastic License 2.0](https://github.com/Arize-ai/phoenix/blob/main/LICENSE); this wrapper only adds Railway settings.
