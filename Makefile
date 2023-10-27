.PHONY = clean install test build full-build
.DEFAULT_GOAL := full-build

clean:
	@cd hevc-portainer; rm -rf .pytest_cache dist */__pycache__

install:
	@cd hevc-portainer; poetry install

test: install
	@cd hevc-portainer; poetry run pytest

build: test
	@cd hevc-portainer; poetry build

full-build:
	@docker image build -t hevc-portainer hevc-portainer
