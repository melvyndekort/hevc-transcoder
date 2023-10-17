.PHONY = shell sync upload trigger download

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

upload:
	@docker container run --rm -it \
	-v ./deploy-scripts:/scripts \
	-w /scripts \
  $$(gpg --decrypt env.asc | sed 's/^/ -e /; s/"//' | tr '\n' ' ' | tr -d '"') \
  alpine:latest \
  ./upload.sh

trigger:
	@docker container run --rm -it \
	-v ./deploy-scripts:/scripts \
	-w /scripts \
  $$(gpg --decrypt env.asc | sed 's/^/ -e /; s/"//' | tr '\n' ' ' | tr -d '"') \
  alpine:latest \
  ./trigger.sh

download:
	@docker container run --rm -it \
	-v ./deploy-scripts:/scripts \
	-w /scripts \
  $$(gpg --decrypt env.asc | sed 's/^/ -e /; s/"//' | tr '\n' ' ' | tr -d '"') \
  alpine:latest \
  ./download.sh
