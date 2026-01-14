# Web build container

FROM node:20-slim AS web-builder

WORKDIR /app/web

RUN corepack enable

COPY web/package*json ./

RUN npm ci --only=production && npm cache clean --force

COPY web .

RUN npm i

RUN npm run build

# Elixir build container
FROM elixir:1.19.4-alpine AS backend-builder

WORKDIR /app/backend

COPY backend .

ENV MIX_ENV=prod

RUN mix deps.get --only prod

RUN mix deps.compile

RUN mix ecto.create

RUN mix ecto.migrate

RUN mix compile

RUN mix release


FROM elixir:1.19.4-alpine AS runner

WORKDIR /app
ENV MIX_ENV=prod

RUN mkdir -p lib/pictible-0.1.0/priv/static
COPY --from=backend-builder /app/backend/_build/prod/rel/pictible .
COPY --from=web-builder /app/web/build lib/pictible-0.1.0/priv/static

EXPOSE 4069

CMD ["bin/pictible", "start"]
