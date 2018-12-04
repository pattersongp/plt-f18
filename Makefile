all: clean source tests

source:
	$(MAKE) -C src/ all

tests:
	./testall.sh

.ONESHELL:
clean:
	./testall.sh -c
	$(MAKE) -C src/ clean
