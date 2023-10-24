.PHONY = clean install test build full-build
.DEFAULT_GOAL := full-build

clean:
	@cd docker/hevc-portainer; rm -rf .pytest_cache dist */__pycache__

install:
	@cd docker/hevc-portainer; poetry install

test: install
	@cd docker/hevc-portainer; poetry run pytest

build: test
	@cd docker/hevc-portainer; poetry build

full-build:
	@docker image build -t hevc-portainer docker/hevc-portainer
