%{
#include <iostream>
#include <string>
#include <FlexLexer.h>
#include "AST.hpp"
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
    Program program;
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
       includes { std::cout << "create new include" << std::endl; }
       | functions { std::cout << "create new function" << std::endl; }
       ;

includes: %empty
       | INCLUDE IDENTIFIER SEMI includes { std::cout << "new include id: " << $2 << std::endl; }
       ;

functions: %empty
         | function functions
         ;

function: FN IDENTIFIER'('')' block { std::cout << "new function id: " << $2 << std::endl;}
        | FN IDENTIFIER'('params')' block { std::cout << "new function id: " << $2 << std::endl;}
        ;

params: param
      | param COMMA params
      ;

param: type IDENTIFIER { std::cout << "new param" << std::endl; }
     ;

type: NBRT | FLTT | CHRT
    ;

block: '{' code '}' { std::cout << "new block" << std::endl; }
     ;

code: %empty
    | statements
    | commands
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

funcall: IDENTIFIER'('')' { std::cout << "new funcall: " << $1 << std::endl; }
       | IDENTIFIER'('params')' { std::cout << "new funcall: " << $1 << std::endl; }
       ;

print: PRINT'('')' { std::cout << "new print" << std::endl; }
     ;

read: READ'('')' { std::cout << "new read" << std::endl; }
     ;

declaration: type IDENTIFIER { std::cout << "new declaration: " << $2 << std::endl; }
           | type assignement
           ;

assignement: IDENTIFIER EQUAL value { std::cout << "new assignement: " << $1 << std::endl; }
           ;

value: INT { std::cout << "new int: " << $1 << std::endl; }
     | FLOAT { std::cout << "new double: " << $1 << std::endl; }
     | CHAR { std::cout << "new char: " << $1 << std::endl; }
     ;

statements: %empty
          | statement statements
          ;

statement: if { std::cout << "new if" << std::endl; }
         | for { std::cout << "new for" << std::endl; }
         | while { std::cout << "new for" << std::endl; }
         ;

if: IF block { std::cout << "in if" << std::endl; }
  | IF block ELSE
  | IF block ELSE if
  ;

for: FOR IDENTIFIER IN range block { std::cout << "in for" << std::endl; }
   ;

range: value DDOT value
     | value DDOT value DDOT value
     ;

while: WHILE block { std::cout << "in for" << std::endl; }
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
