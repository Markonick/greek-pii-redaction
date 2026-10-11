.PHONY: setup model test lint cli

setup:  ## install deps (offline-capable once cached)
	uv sync

# Greek spaCy NER model — ONLY needed for the use_ner=True path (free-text names /
# addresses). `make test` does NOT need it (the suite runs use_ner=False).
model:
	uv run python -m spacy download el_core_news_sm

# Deterministic, offline, key-free — the whole suite. No model download required.
test:
	uv run pytest -q

lint:
	uv run ruff check redaction tests && uv run ruff format --check redaction tests && uv run mypy redaction

# Redact a local folder of real PDFs → ./redacted (+ ./quarantine for no-text-layer /
# locked files). Human-verify every output before trusting it. Usage: make cli IN=/path/to/real
cli:
	uv run python -m redaction.cli --in $(IN) --out ./redacted --quarantine ./quarantine
