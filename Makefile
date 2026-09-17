.PHONY: hook scan demo test env-example

hook:
	pre-commit install

scan:
	pre-commit run --all-files

demo:
	bash demo/simulate_leak.sh

test:
	python3 tools/test_make_env_example.py

env-example:
	python3 tools/make_env_example.py .env -o .env.example
