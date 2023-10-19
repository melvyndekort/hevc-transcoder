.PHONY = shell sync process trigger

shell:
	@docker container run --rm -it \
	-v ./deploy-scripts:/scripts \
	-w /scripts \
  $$(gpg --decrypt env.asc | sed 's/^/ -e /; s/"//' | tr '\n' ' ' | tr -d '"') \
  melvyndekort/portainer-api-client:latest \
  /bin/sh

sync:
	@docker container run --rm -it \
	-v ./deploy-scripts:/scripts \
	-w /scripts \
  $$(gpg --decrypt env.asc | sed 's/^/ -e /; s/"//' | tr '\n' ' ' | tr -d '"') \
  melvyndekort/portainer-api-client:latest \
  ./nextcloud-sync.sh

process:
	@docker container run --rm -it \
	-v ./deploy-scripts:/scripts \
	-w /scripts \
  $$(gpg --decrypt env.asc | sed 's/^/ -e /; s/"//' | tr '\n' ' ' | tr -d '"') \
  melvyndekort/portainer-api-client:latest \
  ./process.sh

trigger:
	@docker container run --rm -it \
	-v ./deploy-scripts:/scripts \
	-w /scripts \
  $$(gpg --decrypt env.asc | sed 's/^/ -e /; s/"//' | tr '\n' ' ' | tr -d '"') \
  melvyndekort/portainer-api-client:latest \
  ./trigger.sh
