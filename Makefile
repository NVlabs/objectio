#!/bin/bash

# run the unit tests in a virtual environment

tests: venv FORCE
	rm -f objio.yaml objio.yml # config files that interfere with tests
	. ./venv/bin/activate; python3 -m pytest

# build the virtual environment for development and testing

venv: FORCE
	test -d venv || python3 -m venv venv
	. ./venv/bin/activate; python3 -m pip install --no-cache -r requirements.dev.txt
	. ./venv/bin/activate; python3 -m pip install --no-cache -r requirements.txt

# push a new version to github; commit all changes first or this will fail
# after a successful push, it will try to clone the repo into a docker container
# and execute the tests

push: FORCE
	make tests
	make docs
	git add docs/*.md
	git push
	./dockergit

# push a new version to pypi; commit all changes first or this will fail
# after a successful push, it will try to clone the repo into a docker container
# and execute the tests

dist: FORCE
	rm -f dist/*
	. ./venv/bin/activate; python3 setup.py sdist bdist_wheel
	twine upload dist/*
	./dockerpip

# build the documentation

docs: venv FORCE
	./gendocs

# remove temporary build constructs

clean: FORCE
	rm -rf venv build dist
	rm -f objio.yaml objio.yml # config files that interfere with tests

# set the keyring password for pypi uploads

passwd: FORCE
	. ./venv/bin/activate; python3 -m keyring set https://upload.pypi.org/legacy/ tmbdev

FORCE:
