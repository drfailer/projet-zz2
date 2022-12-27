%{
#include <iostream>
#include <string>
#include <FlexLexer.h>
%}
%language "c++"
%defines "parser.hpp"
%output "parser.cpp"

%define api.parser.class {Parser}
%define api.namespace {interpreter}
%define api.value.type variant
%parse-param {Scanner* scanner}

%code requires
{
    namespace interpreter {
      class Scanner;
    }
}

%code
{
    #include "lexer.hpp"
    #define yylex(x) scanner->lex(x)
}

%token              EOL LPAREN RPAREN
%token <long long>  INT
%token <double>     FLOAT
%token <char>       CHAR
/* %nonassoc           ASSIGN */
%token NBRT FLTT CHRT
%token IF ELSE FOR WHILE FN
%token SEMI
%token ERROR
%token <std::string> IDENTIFIER
%token <int> NBR
%token <double> FLT


%%
prog: commands
    | stmts
;

commands: %empty
  | command SEMI commands
;

stmts: %empty
     | stmt stmts

command:
  declaration { std::cout << "declaration" << std::endl; }
  | assignment {  std::cout << "assignment" << std::endl; }
;

stmt:
  if { std::cout << "stmt if" << std::endl; }
  | else {  std::cout << "stmt else" << std::endl; }
  | for { std::cout << "stmt for" << std::endl; }
  | while {  std::cout << "stmt while" << std::endl; }
  | function {  std::cout << "stmt fun" << std::endl; }
;

type:
  NBRT | FLTT | CHRT
;

value:
  INT | FLOAT | CHAR
;

assignment: IDENTIFIER '=' value
;

declaration:
  type IDENTIFIER { std::cout << "declaration simple"; }
  | type assignment { std::cout << "declaration assignment"; }
;

if: IF '{' commands '}'
;

else: ELSE '{' commands '}'
;

for: FOR '{' commands '}'
;

while: WHILE '{' commands '}'
;

function: FN IDENTIFIER'(' ')' '{' commands '}'
{ std::cout << "function: " << $2 << std::endl; }
;
%%

void interpreter::Parser::error(const std::string& msg) {
      std::cerr << msg << '\n';
}

int main() {
  interpreter::Scanner scanner{ std::cin, std::cerr };
  interpreter::Parser parser{ &scanner };
  parser.parse();
}
