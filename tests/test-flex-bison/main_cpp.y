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
commands: %empty
  | command ';' commands

command:
  declaration { std::cout << "declaration" << std::endl; }
  | assignment {  std::cout << "assignment" << std::endl; }
  | if {  std::cout << "if" << std::endl; }
  | else {  std::cout << "else" << std::endl; }
  | for {  std::cout << "for" << std::endl; }
  | while {  std::cout << "while" << std::endl; }
  | function {  std::cout << "fun" << std::endl; }
;

type:
  NBRT | FLTT | CHRT
;

value:
  INT | FLOAT | CHAR
;

assignment: IDENTIFIER '=' value SEMI

declaration:
  type IDENTIFIER SEMI
  | type assignment
;

if: IF '{' commands '}'
;


else: ELSE '{' '}'
;

for: FOR '{' commands '}'
;

while: WHILE '{' commands '}'
;

function: FN IDENTIFIER'(' ')' '{' commands '}'
;


%%

void interpreter::Parser::error(const std::string& msg) {
      std::cerr << msg << '\n';
}
