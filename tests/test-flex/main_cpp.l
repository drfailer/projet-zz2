%{
#include <iostream>
#define YY_DECL extern "C" int yylex()
  int chars = 0;
  int words = 0;
  int lines = 0;
%}

%%

[a-zA-Z]+ {
  words++;
  chars += strlen(yytext);
}
\n {
  lines++;
}
. {
  chars++;
}

%%

int main(int argc, char ** argv) {
  yylex();
  std::cout << chars << " " << words << " " << lines << std::endl;
  return 0;
}
