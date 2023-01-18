test: parser.o lexer.o AST.o Program.o ProgramBuilder.o
	g++ -o test $^ -g

# -------------------------------------------------------------- flex and bison

lexer:
	flex main_cpp.l

parser:
	bison main_cpp.y

# ---------------------------------------------------------------- Object files

AST.o: AST/AST.cpp
	g++ -c $^

Program.o: AST/Program.cpp
	g++ -c $^

ProgramBuilder.o: AST/ProgramBuilder.cpp
	g++ -c $^

parser.o: parser parser.cpp
	g++ -c parser.cpp

lexer.o: lexer lexer.cpp
	g++ -c lexer.cpp

# ----------------------------------------------------------------------- clean

clean:
	rm -rf stack.hh
	rm -rf parser.cpp parser.hpp
	rm -rf lexer.cpp
	rm -rf test

cleaner: clean
	rm -rf *.o
