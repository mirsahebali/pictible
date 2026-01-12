build-web:
	cd backend && rm -rf priv/static/*
	cd web && pnpm run build && cp -r build/* ../backend/priv/static
