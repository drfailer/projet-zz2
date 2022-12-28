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
%token IF ELSE FOR WHILE FN INCLUDE IN
%token SEMI COMMA
%token PRINT READ ADD MNS TMS DIV EQUAL DDOT
%token ERROR
%token <std::string> IDENTIFIER
%token <int> NBR
%token <double> FLT

%%
program: %empty
       | programElt program;

programElt:
       includes | functions | commands | statements
       ;

includes: %empty
       | INCLUDE IDENTIFIER SEMI includes
       ;

functions: %empty
         | function functions
         ;

function: FN IDENTIFIER'('')' block
        | FN IDENTIFIER'('params')' block
        ;

params: %empty
      | param COMMA params
      ;

param: type IDENTIFIER
     ;

type: NBRT | FLTT | CHRT
    ;

block: '{' code '}'
     ;

code: %empty | statements | commands
    ;

commands: %empty
        | command SEMI commands
        ;

command: funcall
        | print
        | read
        | declaration
        | assignement
        ;

funcall: IDENTIFIER'('')'
       | IDENTIFIER'('params')'
       ;

print: PRINT'('')'
     ;

read: READ'('')'
     ;

declaration: type IDENTIFIER
           | type assignement
           ;

assignement: IDENTIFIER EQUAL value
           ;

value: INT | FLOAT | CHAR
     ;

statements: %empty
          | statement statements
          ;

statement: if | for | while
         ;

if: IF block
  | IF block ELSE
  | IF block ELSE if
  ;

for: FOR IDENTIFIER IN range block
   ;

range: value DDOT value
     | value DDOT value DDOT value
     ;

while: WHILE block
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
