build-web:
	cd backend && rm -rf priv/static/*
	cd web && npm run build && cp -r build/* ../backend/priv/static
