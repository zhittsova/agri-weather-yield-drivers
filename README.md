# agri-weather-yield-drivers

Explainable **weather → yield → soil** drivers and regional **risk zoning** (e.g., sandy-soil zones under rainfall deficit).
Produces a reproducible reporting mart and GeoJSON layers suitable for mapping.

## Quickstart

### 1. Setup

```sh
make setup
```

## 2. Run tests + lint

```sh
make test
make lint
```

## How to run

### Makefile overview
```sh
make setup     # uv: create venv, install deps, pre-commit install
make sync      # full uv sync --all-packages --akk-extras --akk-groups
make test      # unit tests
make lint      # run ruff with --fix
make format    # run ruff
make typecheck # run mypy
make precommit # run pre-commit on all files
make clean     # remove build artifacts
```

### 1. Install and sync environment

```sh
make setup
```

This project is fully managed by `uv` workspaces, using the layout:

- `/apps` for frontends and
- `/packages` for the logic,

and expects both Python and dependencies to be managed by `uv`.

### 2. Open in VS Code (workspace provided)

- Select interpreter: `.venv/bin/python`
- Run tests from Test Explorer (configured to use `pytest` on `tests/`)
- Use tasks: `uv: sync`, `test: pytest`, `lint: ruff`, `typecheck: mypy`

### 3. Local quality checks

```sh
make check
```

Or run individual commands:

```sh
uv run pytest
uv run ruff check .
uv run mypy
```
