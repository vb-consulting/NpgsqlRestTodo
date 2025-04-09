FROM vbilopav/npgsqlrest:v2.25.0 AS base
WORKDIR /app

COPY ./config/npgsqlrest/base-settings.json ./base-settings.json
COPY ./config/npgsqlrest/external-auth-providers.* ./external-auth-providers.json

FROM base AS app-dev
COPY ./config/npgsqlrest/dev-settings.json ./dev-settings.json
COPY ./config/npgsqlrest/app-settings.json ./app-settings.json
ENTRYPOINT ["npgsqlrest", "base-settings.json", "dev-settings.json", "app-settings.json", "--optional", "external-auth-providers.json"]

FROM base AS app-prod
COPY ./config/npgsqlrest/app-settings.json ./app-settings.json
ENTRYPOINT ["npgsqlrest", "base-settings.json", "app-settings.json", "--optional", "external-auth-providers.json"]

FROM base AS admin-dev
COPY ./config/npgsqlrest/dev-settings.json ./dev-settings.json
COPY ./config/npgsqlrest/admin-settings.json ./admin-settings.json
ENTRYPOINT ["npgsqlrest", "base-settings.json", "dev-settings.json", "admin-settings.json", "--optional", "external-auth-providers.json"]

FROM base AS admin-prod
COPY ./config/npgsqlrest/admin-settings.json ./admin-settings.json
ENTRYPOINT ["npgsqlrest", "base-settings.json", "admin-settings.json", "--optional", "external-auth-providers.json"]
