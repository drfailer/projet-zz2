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
    ProgramBuilder pb;
    Type lastType;
    type_t lastValue;
    std::string lastFunctionName;
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
       includes
       {
         std::cout << "create new include" << std::endl;
       }
       |
       functions
       {
         std::cout << "create new function" << std::endl;
       }
       ;

includes: %empty
       |
       INCLUDE IDENTIFIER SEMI
       {
         std::cout << "new include id: " << $2 << std::endl;
         pb.addInclude(new Include($2));
       }
       includes
       ;

functions: %empty
         | function functions
         ;

function:
        FN IDENTIFIER'('')'
        {
          std::cout << "new function id: " << $2 << std::endl;
          pb.createBlock();
          lastFunctionName = $2;
        }
        block
        {
          pb.createFunction(lastFunctionName);
        }
        |
        FN IDENTIFIER'('params')'
        {
          std::cout << "new function id: " << $2 << std::endl;
          pb.createBlock();
          lastFunctionName = $2;
        }
        block
        {
          pb.createFunction(lastFunctionName);
        }
        ;

params: param
      | param COMMA params
      ;

param:
     type IDENTIFIER
     {
       std::cout << "new param: " << $2 << std::endl;
     }
     ;

type:
    NBRT
    {
      lastType = NBR;
    }
    |
    FLTT
    {
      lastType = FLT;
    }
    |
    CHRT
    {
      lastType = CHR;
    }
    ;

block: '{' code '}' { std::cout << "new block" << std::endl; }
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

funcall:
       IDENTIFIER'('')'
       {
         std::cout << "new funcall: " << $1 << std::endl;
       }
       |
       IDENTIFIER'('params')'
       {
         std::cout << "new funcall: " << $1 << std::endl;
       }
       ;

print:
     PRINT'('')'
     {
       std::cout << "new print" << std::endl;
     }
     ;

read:
    READ'('')'
    {
      std::cout << "new read" << std::endl;
    }
     ;

declaration:
           type IDENTIFIER
           {
             std::cout << "new declaration: " << $2 << std::endl;
             pb.pushCommand(new Declaration($2, lastType));
           }
           |
           type IDENTIFIER EQUAL value
           {
             pb.pushCommand(new Declaration($2, lastType));
           }
           ;

assignement:
           IDENTIFIER EQUAL value
           {
             std::cout << "new assignement: " << $1 << std::endl;
             pb.pushCommand(new Assignement($1, lastValue));
           }
           ;

value:
     INT
     {
       std::cout << "new int: " << $1 << std::endl;
       lastValue.i = $1;
     }
     |
     FLOAT
     {
       std::cout << "new double: " << $1 << std::endl;
       lastValue.f = $1;
     }
     |
     CHAR
     {
       std::cout << "new char: " << $1 << std::endl;
       lastValue.c = $1;
     }
     ;

statements: %empty
          | statement statements
          ;

statement: if
         {
           std::cout << "new if" << std::endl;
           pb.createIf();
         }
         |
         for
         {
           std::cout << "new for" << std::endl;
           pb.createFor();
         }
         |
         while
         {
           std::cout << "new for" << std::endl;
           pb.createWhile();
         }
         ;

if: IF
  {
    std::cout << "---- if ----" << std::endl;
    pb.createBlock();
  }
  block
  {
    std::cout << "if" << std::endl;
  }
  |
  if ELSE if
  {
    std::cout << "else if" << std::endl;
  }
  |
  if ELSE block
  {
    std::cout << "else" << std::endl;
  }
  ;

for:
   FOR
   {
      pb.createBlock();
   }
   IDENTIFIER IN range block
   {
     std::cout << "in for" << std::endl;
   }
   ;

range: value DDOT value
     | value DDOT value DDOT value
     ;

while:
     WHILE
     {
      pb.createBlock();
     }
     block
     {
       std::cout << "in for" << std::endl;
     }
     ;
%%

void interpreter::Parser::error(const std::string& msg) {
      std::cerr << msg << '\n';
}

int main() {
  interpreter::Scanner scanner{ std::cin, std::cerr };
  interpreter::Parser parser{ &scanner };
  parser.parse();
  pb.display();
}
