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

function: FN IDENTIFIER'('')' block { std::cout << "fonction: " << $2 << std::endl; }
        | FN IDENTIFIER'('params')' block
        ;

params: param
      | param COMMA params
      ;

param: type IDENTIFIER
     ;

type: NBRT | FLTT | CHRT
    ;

block: '{' code '}' { std::cout << "block d'instruction" << std::endl; }
     ;

code: %empty
    | statements code
    | commands code
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

declaration: type IDENTIFIER { std::cout << "déclaration de: " << $2 << std::endl; }
           | type assignement { std::cout << "declaration assignement" << std::endl; }
           ;

assignement: IDENTIFIER EQUAL value { std::cout << "assignement de: " << $1 << std::endl; }
           ;

value: INT { std::cout << "value: " << $1 << std::endl; }
     | FLOAT { std::cout << "value: " << $1 << std::endl; }
     | CHAR { std::cout << "value: " << $1 << std::endl; }
     ;

statements: %empty
          | statement statements
          ;

statement: if | for | while
         ;

if: IF block { std::cout << "if" << std::endl; }
  | if ELSE if { std::cout << "else if" << std::endl; }
  | if ELSE block { std::cout << "else" << std::endl; }
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
