build-web:
	cd backend && rm -rf priv/static/*
	cd web && npm run build && cp -r build/* ../backend/priv/static

build-prod:
	MIX_ENV=prod cd backend && \
	MIX_ENV=prod mix deps.get --only prod && \
	MIX_ENV=prod mix deps.compile  && \
	MIX_ENV=prod mix ecto.create && \
	MIX_ENV=prod mix ecto.migrate && \
	MIX_ENV=prod mix compile && \
	MIX_ENV=prod mix release

