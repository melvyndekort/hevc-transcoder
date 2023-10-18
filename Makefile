.PHONY = shell sync process trigger

shell:
	@docker container run --rm -it \
	-v ./deploy-scripts:/scripts \
	-w /scripts \
  $$(gpg --decrypt env.asc | sed 's/^/ -e /; s/"//' | tr '\n' ' ' | tr -d '"') \
  alpine:latest \
  /bin/sh

sync:
	@docker container run --rm -it \
	-v ./deploy-scripts:/scripts \
	-w /scripts \
  $$(gpg --decrypt env.asc | sed 's/^/ -e /; s/"//' | tr '\n' ' ' | tr -d '"') \
  alpine:latest \
  ./nextcloud-sync.sh

process:
	@docker container run --rm -it \
	-v ./deploy-scripts:/scripts \
	-w /scripts \
  $$(gpg --decrypt env.asc | sed 's/^/ -e /; s/"//' | tr '\n' ' ' | tr -d '"') \
  alpine:latest \
  ./process.sh

trigger:
	@docker container run --rm -it \
	-v ./deploy-scripts:/scripts \
	-w /scripts \
  $$(gpg --decrypt env.asc | sed 's/^/ -e /; s/"//' | tr '\n' ' ' | tr -d '"') \
  alpine:latest \
  ./trigger.sh
