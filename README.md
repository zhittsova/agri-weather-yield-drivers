# agri-weather-yield-drivers

![CI](https://github.com/zhittsova/agri-weather-yield-drivers/actions/workflows/ci.yml/badge.svg?branch=main)

Explainable **weather → yield → soil** drivers and regional **risk zoning** (e.g., sandy-soil zones under rainfall deficit).
Produces a reproducible reporting mart and GeoJSON layers suitable for mapping.

This repo is work in progress. Currently I'm exploring the data sources first but want to produce a quick MVP before going too deep. Check out my progress in the [`notebooks/` folder](notebooks/). GitHub can render the Notebooks, I'll provide a Binder link later.

## Quickstart

### 1. Setup

```sh
make setup
```

### 2. Run tests + lint

```sh
make test
make lint
```

## How to run

### Makefile overview

```sh
make setup     # uv: create venv, install deps, pre-commit install
make sync      # full uv sync --all-packages --all-extras --all-groups
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
- Run tests from Test Explorer (configured to use `pytest` on `packages/*/tests/` and `apps/*/tests`)
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

## About the scaffolding

I usually start with EDA and notebooks, then extract what makes sense into packages, and add a CLI or UI like Streamlit on top of it when stand-alone output is the goal, otherwise I would just extract it into a dashboard in a shared workspace (Metabase, Superset, Power BI, Tableau). And sometimes a notebook is just enough.

So this scaffolding is best suited for the development of an ETL/ELT flow. A data engineer can integrate it well with Airflow and Dagster, for example.

The project structure (uv workspaces, `packages/` + `apps/` + `notebooks/` layout, strict mypy, ruff, pre-commit, CI) comes from a personal starter template I've been building up and have published at [`zhittsova/bi-python-uv-project-template`](https://github.com/zhittsova/bi-python-uv-project-template). Like all templates, it's a bit opinionated and assumes `uv` for Python package management for reproducibility. If you want to dive deeper, the official docs are great:

- [uv workspaces](https://docs.astral.sh/uv/concepts/workspaces/) for the monorepo layout
  with separate packages and apps
- [uv dependency groups](https://docs.astral.sh/uv/concepts/dependencies/#dependency-groups) to keep dev / notebook / production deps cleanly separated
- default [uv build backend](https://docs.astral.sh/uv/concepts/build-backend/) (`uv_build`) so the packages are installable without setuptools
- [ruff](https://docs.astral.sh/ruff/) for linting + formatting in one tool, configured in `pyproject.toml` rather than separate config files
- [mypy strict mode](https://mypy.readthedocs.io/en/stable/command_line.html#cmdoption-mypy-strict) because catching type bugs early is worth the initial friction

The idea is that I can clone the template, rename a few things, and have a working project
with quality gates already in place - so I can focus on the actual analysis instead of
fighting tooling every time.
