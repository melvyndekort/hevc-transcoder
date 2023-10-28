.PHONY = clean install test build full-build init plan apply
.DEFAULT_GOAL := build

clean:
	@cd hevc-portainer; rm -rf .pytest_cache dist */__pycache__ */*/__pycache__
	@cd hevc-processor; rm -rf .pytest_cache dist */__pycache__ */*/__pycache__

install:
	@cd hevc-portainer; poetry install
	@cd hevc-processor; poetry install

test: install
	@cd hevc-portainer; poetry run pytest
	@cd hevc-processor; poetry run pytest

build: test
	@cd hevc-portainer; poetry build
	@cd hevc-processor; poetry build

full-build:
	@docker image build -t hevc-portainer hevc-portainer
	@docker image build -t hevc-processor hevc-processor

init:
	@terraform -chdir=terraform init

plan: init
	@terraform -chdir=terraform plan

apply: init
	@terraform -chdir=terraform apply
