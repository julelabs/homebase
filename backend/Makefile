# Port 4000 gehört dem menschlichen Entwickler (make start).
# Die SPA in ../src/index.html nimmt am Rechner automatisch http://localhost:4000.

.PHONY: prepare test kill-port-4000 start

prepare:
	mix deps.get
	mix compile

test: prepare
	mix test

kill-port-4000:
	@pids="$$(lsof -tiTCP:4000 -sTCP:LISTEN 2>/dev/null)"; \
	if [ -n "$$pids" ]; then \
		echo "Stopping processes on port 4000: $$pids"; \
		kill $$pids 2>/dev/null || true; \
		sleep 1; \
		pids="$$(lsof -tiTCP:4000 -sTCP:LISTEN 2>/dev/null)"; \
		if [ -n "$$pids" ]; then \
			echo "Force stopping processes on port 4000: $$pids"; \
			kill -9 $$pids 2>/dev/null || true; \
		fi; \
	fi

# Optional: eine git-ignorierte .env wird in den Server geladen, zum Beispiel DATABASE_URL.
# Ohne .env läuft dev gegen ecto://localhost/homebase_dev.
start:
	@$(MAKE) kill-port-4000
	@$(MAKE) prepare
	mix ecto.create --quiet
	mix ecto.migrate
	open ../src/index.html
	@if [ -f .env ]; then set -a && . ./.env && set +a; fi; mix phx.server
