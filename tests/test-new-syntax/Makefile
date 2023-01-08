test:
	flex main_cpp.l
	bison main_cpp.y
	g++ -o test parser.cpp lexer.cpp AST.cpp

clean:
	rm -rf stack.hh
	rm -rf parser.cpp parser.hpp
	rm -rf lexer.cpp
	rm -rf test
