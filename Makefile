.PHONY: clean install test build full-build init plan apply manual-run manual-run-spot
.DEFAULT_GOAL := build

clean:
	@rm -rf .pytest_cache dist */__pycache__ */*/__pycache__

install:
	@poetry install

test: install
	@poetry run pytest

build: test
	@poetry build

full-build:
	@docker image build -t hevc-transcoder .

init:
	@terraform -chdir=terraform init

plan: init
	@terraform -chdir=terraform plan

apply: init
	@terraform -chdir=terraform apply

manual-run:
	@/bin/sh scripts/manual-run.sh

manual-run-spot:
	@/bin/sh scripts/manual-run-spot.sh
