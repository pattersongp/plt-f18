all: clean source tests examples

source:
	$(MAKE) -C src/ all

tests:
	./testall.sh

examples:
	$(MAKE) -C code-examples/fire-lexer/ test

.ONESHELL:
clean:
	./testall.sh -c
	$(MAKE) -C src/ clean
	$(MAKE) -C code-examples/fire-lexer/ clean
