.PHONY: setup sync test lint format typecheck check precommit clean

setup: sync
	uv run pre-commit install

sync:
	uv sync --all-packages --all-extras --all-groups

test:
	uv run pytest -q

lint:
	uv run ruff check . --fix

format:
	uv run ruff format .

typecheck:
	uv run mypy

check: format lint typecheck test

precommit:
	uv run pre-commit run --all-files

clean:
	rm -rf .pytest_cache .ruff_cache .mypy_cache htmlcov .coverage coverage.xml
	rm -rf outputs/
	touch outputs/figures/.gitkeep
	touch outputs/map_layers/.gitkeep
