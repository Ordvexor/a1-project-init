.RECIPEPREFIX := >
.PHONY: init hooks verify clean pin deps

PY := python3.12
VENV := .venv
PIP := $(VENV)/bin/pip

$(VENV):
> $(PY) -m venv $(VENV)
> $(PIP) -q install -U pip

init: $(VENV)
> mkdir -p evidence/logs evidence/reports
> [ -f evidence/logs/bootstrap.log ] || : > evidence/logs/boostrap.log
> echo "[A1] init $$(date -Is)" | tee -a evidence/logs/bootstrap.log
> ./bootstrap.sh

hooks: $(VENV)
> $(PIP) -q install pre-commit detect-secrets
> $(VENV)/bin/pre-commit install
> $(VENV)/bin/pre-commit install --hook-type commit-msg
> @echo "hooks ok"

deps: $(VENV)
> $(PIP) -q install -r requirements.txt -r requirements-dev.txt

verify: deps
> . $(VENV)/bin/activate; \
> ruff check . && black --check . && isort --check-only . && \
> pre-commit run detect-secrets --all-files && \ 
> pre-commit run --all-files && \
> pytest -q
> @echo "verify ok"

clean: 
> rm -rf $(VENV) __pycache__ .evidence-cache

pin: $(VENV)
> $(PIP) -q install pip-tools
> . $(VENV)/bin/activate; \
> pip-compile -q --generate-hashes -o requirements.txt requirements.in; \
> pip-compile -q --generate-hashes -o requirements-dev.txt requirements-dev.in
> @echo "pins updated"
