all: lint test

lint:
	black fail2ban-subnet tests/runner

test:
	python3 tests/runner

release:
	gbp dch -Rc
	make -f debian/rules tarball

.PHONY: lint test release
