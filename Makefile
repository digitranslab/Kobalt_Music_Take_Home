# Define variables
PYTHON = python3.9
POETRY = poetry
VENV_DIR = .venv
SRC_DIR = backend/lambdas
LAMBDA_DIRS = $(SRC_DIR)/check_service $(SRC_DIR)/front_service $(SRC_DIR)/monitor_service

# Setup Python virtual environment
setup_venv:
	$(POETRY) install

# Source the virtual environment
source_venv:
	@echo "Run 'source $(VENV_DIR)/bin/activate' to activate the virtual environment."

freeze: ## compile pip packages
	@pip3 install --force-reinstall pip==22.0.4
	@pip3 install pip-tools --force-reinstall
	@python3 -m piptools compile requirements/requirements.in --output-file=requirements/requirements.txt
	@python3 -m piptools compile requirements/requirements-dev.in --output-file=requirements/requirements-dev.txt

# Install requirements
install_requirements:
	@pip3 install --upgrade setuptools wheel
	@pip3 install -r requirements/requirements.txt --force-reinstall
	@pip3 install -r requirements/requirements-dev.txt --force-reinstall

# Build all Lambda packages
build_lambdas:
	@for dir in $(LAMBDA_DIRS); do \
		(cd $$dir && zip -r $$(basename $$dir).zip *.py); \
	done

# Run unit tests
test:
	$(POETRY) run pytest tests/

# Run code style checks and security checks
lint:
	$(POETRY) run flake8 $(SRC_DIR)
	$(POETRY) run bandit -r $(SRC_DIR)

# Deploy with Terraform
deploy:
	cd infra && terraform init && terraform apply -auto-approve

# =========================================
#       			CLEAR
# -----------------------------------------

.PHONY: clean-build
clean-build: ## remove build artifacts
#	rm -fr dist/
	rm -fr build/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -fr {} +

.PHONY: clean-pyc
clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +
	find . -name '__pycache__2' -exec rm -fr {} +
	find . -type d -name venv -prune -o -type d -name __pycache__ -print0 | xargs -0 rm -rf

.PHONY: clean-test
clean-test: ## remove test and coverage artifacts
	rm -f .coverage
	rm -fr .tox/
	rm -f coverage.xml
	rm -f report.xml
	rm -f report.html
	rm -f logs.txt
	rm -fr coverage/
	rm -fr htmlcov/
	rm -fr building/
	rm -fr htmlcov/
	rm -fr .pytest_cache
	rm -fr .mypy_cache/
	rm -fr requirements.txt


# Help
help:
	@echo "Makefile commands:"
	@echo "  setup_venv          - Setup Python virtual environment"
	@echo "  source_venv         - Source the virtual environment"
	@echo "  freeze 			 - Compile requirements"
	@echo "  install_requirements - Install all requirements using Poetry"
	@echo "  build_lambdas       - Build all Lambda packages"
	@echo "  test                - Run unit tests"
	@echo "  lint                - Run code style and security checks"
	@echo "  deploy              - Deploy with Terraform"
	@echo "  clean               - Clean project"
