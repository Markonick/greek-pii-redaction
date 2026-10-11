# greek-pii-redaction

PII detection + **true** PDF redaction for Greek documents — Presidio (detection) + PyMuPDF
(redaction that *removes* the underlying text, not a drawn-over box that leaves it
extractable). Standalone, **offline**, deterministic. No API keys, no network.

The hard part is the Greek-specific PII that Presidio's stock recognizers miss, and doing
it without over-redacting (which destroys a document's utility) or under-redacting (which
leaks PII).

## What's here

```
greek-pii-redaction/
├── redaction/
│   ├── recognizers.py   # custom Greek recognizers Presidio lacks: ΑΦΜ (checksum),
│   │                    #   ΑΜΚΑ (date), ID card, passport, phone, label-anchored names,
│   │                    #   + wrapped/label-less email heads
│   ├── redactor.py      # PiiAnalyzer (detect: regex + optional Greek NER) and
│   │                    #   PdfRedactor (true PyMuPDF redaction; quarantines no-text/locked)
│   ├── positional.py    # word-level field/label rect geometry for two-column tax forms
│   └── cli.py           # python -m redaction.cli --in <dir> --out <dir>
└── tests/               # 55 deterministic, offline tests (recognizers / redactor / positional)
```

## Run (all keyless, offline)

```bash
uv sync          # or: make setup
make test        # 55 tests — recognizers + redactor + positional. No model, no key.
make lint        # ruff + mypy
```

Python 3.12 via [uv](https://docs.astral.sh/uv/) (pinned: the spaCy/Presidio stack has no
cp314 wheels).

### Optional: the Greek NER path

`PiiAnalyzer(use_ner=True)` adds spaCy Greek NER (PERSON/LOCATION) for free-text names and
addresses the regex recognizers don't anchor. It needs the `el_core_news_sm` model
(`make model`) and is exercised manually — **`make test` runs the `use_ner=False` path**, so
the whole suite stays model-free and offline.

## Safety model — read before running on real data

Automated redaction is **never 100%**. Therefore:

- **Nothing derived from real documents is committed.** `redacted/`, `quarantine/`, `real/`
  are gitignored. Human-verify a file before trusting or sharing it.
- **No-text-layer / locked PDFs are quarantined**, never emitted unredacted — a scanned,
  image-only document needs OCR, not text redaction.
- **ID cards / passports** survive text redaction (a face photo + layout remain), so they
  should never be treated as "safe" after redaction.

```bash
make cli IN=/path/to/real    # → ./redacted  (+ ./quarantine) — then hand-verify each file
```
