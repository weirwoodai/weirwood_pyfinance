.PHONY: clean build docs help
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean:  ## clean all build, python, and testing files
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +
	rm -fr .tox/
	rm -fr .coverage
	rm -fr coverage.xml
	rm -fr htmlcov/
	rm -fr .pytest_cache
	rm -rf venv/

test: ## run tox / run tests and lint
	tox .

gen-docs: ## generate Sphinx HTML documentation, including API docs
	rm -f docs/weirwood_pyfinance*.rst
	rm -f docs/modules.rst
	sphinx-apidoc -o docs/ weirwood_pyfinance **/tests/
	$(MAKE) -C docs html

docs: ## generate Sphinx HTML documentation, including API docs, and serve to browser
	make gen-docs
	$(BROWSER) docs/_build/html/index.html

env:clean
	python -m virtualenv venv

install-dev:env
	( \
       source venv/bin/activate; \
	   pip install --upgrade pip; \
       pip install -e .[dev] --no-cache --use-deprecated=legacy-resolver; \
    )

# Simulation of github actions in local
isort:
	python -m isort .

black:
	python -m black .

flake8:
	python -m flake8 weirwood_pyfinance --count --verbose --show-source --statistics

test:
	python -m pytest --verbose .

check_all:
	(\
	make isort;\
	make black;\
	make flake8;\
	make test;\
	)

