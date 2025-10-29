all: lint test

lint:
	black fail2ban-subnet tests/runner

test:
	python3 tests/runner

.PHONY: lint test
