.PHONY = clean install test build full-build init plan apply
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
	@docker image build -t hevc-processor .

init:
	@terraform -chdir=terraform init

plan: init
	@terraform -chdir=terraform plan

apply: init
	@terraform -chdir=terraform apply
