.PHONY: start facilitator reset check keys decrypt

start:
	./scripts/start.sh

facilitator:
	./scripts/start.sh --facilitator

reset:
	./scripts/reset.sh

check:
	./scripts/check.sh

keys:
	./scripts/setup-facilitator-keys.sh

decrypt:
	./scripts/decrypt-submission.sh keys/facilitator_private.pem submission.txt
