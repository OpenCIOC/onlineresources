update-deps:
	python -m pip install -U pip pip-tools
	pip-compile -U requirements.in
	pip-compile -U requirements-dev.in

compile-deps:
	python -m pip install -U pip pip-tools
	pip-compile requirements.in
	pip-compile requirements-dev.in
