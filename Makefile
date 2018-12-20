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

.ONESHELL:
real-clean: clean
	$(MAKE) -C code-examples/fire-lexer/ clean

# Building the tarball

TESTS = \
  add1 arith1 arith2 arith3 arr-all arr1 arr2 arr3 arr4 arr5 arr6 arr7 arr8 arr9 \
  arraylen atoi1 fib filter1 func1 func1 func2 func3 func4 func5 func6 func7 func8 \
  func9 func10 if1 if2 if3 if4 keys1 ops1 print regx1 regx2 split split1 sprint

FAILS = \
  assign1 assign2 assign3 binop1 binop2 binop3 binop4 binop5 binop6 binop7 binop8 \
  binop_10 binop_11 formals1 formals2 formals3 formals4 func1 func2 func3 func4 \
  identifier1 identifier2 identifier3 if1 if2 if3 if4 if5 nomain print1 print2 \
  sprint1 sprint2 unop1 unop2 unop3 unop4 while1 while2

TESTFILES = $(TESTS:%=test-%.fire) $(TESTS:%=test-%.out) \
	    $(FAILS:%=fail-%.fire) $(FAILS:%=fail-%.err)

SRC = ast.ml sast.ml codegen.ml Makefile fire.ml parser.mly scanner.mll semant.ml \
  	  arrlib.c arrlib.h filelib.c regexlib.c printlib.c util.c util.h \

EXAMPLE = binarytree/binarytree.fire binarytree/treedata.txt \
		  computation/compiler-src computation/compile computation/sieve.fire \
		  dragon-heap/dragon-heap.fire dragon-heap/dragon-heap.out dragon-heap/dragonbook.txt \
		  fire-lexer/compiler-src/ fire-lexer/compile fire-lexer/Makefile \
		  fire-lexer/maximalMunch.fire fire-lexer/runtest fire-lexer/simple.accepting.conf \
		  fire-lexer/simple.dfa.conf fire-lexer/simple.lexed.ir fire-lexer/simple.target \
		  fire-lexer/simple.grammar.conf

DOCS = LRM.md project1.png project2.png proposal.md fire-final-report.pdf \
	   fire-final-report.md architectureDiagram.png

TARFILES = Dockerfile Makefile README.md testall.sh \
		   $(SRC:%=src/%) $(TESTFILES:%=test/%) $(EXAMPLE:%=code-examples/%) $(DOCS:%=docs/%)

fire.tar.gz : $(TARFILES)
	cd .. && tar czf plt-f18/fire.tar.gz \
		$(TARFILES:%=plt-f18/%)
