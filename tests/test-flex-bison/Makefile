test:
	flex -l main_cpp.l
	bison -dv main_cpp.y
	g++ -o test main_cpp.tab.cc lex.yy.cc -lfl

clean:
	rm -rf lex.yy.cc
	rm -rf main_cpp.output
	rm -rf main_cpp.tab.*
