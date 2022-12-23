prog: lex.yy.c
	g++ -o $@ $^ -lfl

lex.yy.c: main_cpp.l
	lex $^
