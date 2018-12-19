all: clean source tests

source:
	$(MAKE) -C src/ all

tests:
	./testall.sh

lexer:
	$(MAKE) -C code-examples/fire-lexer/ test

.ONESHELL:
clean:
	./testall.sh -c
	$(MAKE) -C src/ clean
	$(MAKE) -C code-examples/fire-lexer/ clean
