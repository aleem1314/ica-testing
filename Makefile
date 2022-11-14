
init-chains: 
	@echo "Initializing akash and regen blockchains..."
	./scripts/akash/init.sh
	./scripts/regen/init.sh

start-chains: 
	@echo "Starting up a akash and regen nodes..."
	./scripts/akash/start.sh
	./scripts/regen/start.sh

init-hermes: kill-dev init-chains start-chains
	@echo "Initializing relayer..." 
	./scripts/hermes/restore-keys.sh
	./scripts/hermes/create-conn.sh

start-hermes:
	./scripts/hermes/start.sh

kill-dev:
	@echo "Killing akash, regen and removing previous data"
	-@rm -rf ./data
	-@killall akash 2>/dev/null
	-@killall regen 2>/dev/null

PHONY: kill-dev start-hermes init-hermes init-chains start-chains