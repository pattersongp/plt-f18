all : deep-clean build test

build :
	$(MAKE) -C ./compiler-src all

test : build
	./runtest

clean :
	ocamlbuild -clean
	rm -rf *.cmx *.cmi *.cmo *.cmx *.o *.s *.ll *.out *.flames

deep-clean : clean
	$(MAKE) -C ./compiler-src clean
