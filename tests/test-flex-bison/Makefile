test:
	flex main_cpp.l
	bison main_cpp.y
	g++ -o test parser.cpp lexer.cpp -lfl

clean:
	rm -rf lex.yy.cc
	rm -rf stack.hh
	rm -rf main_cpp.output
	rm -rf main_cpp.tab.*
	rm -rf parser.cpp parser.hpp
	rm -rf lexer.cpp
