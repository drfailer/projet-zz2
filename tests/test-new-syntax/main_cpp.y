%{
#include <iostream>
#include <string>
#include <FlexLexer.h>
#include "AST/AST.hpp"
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
    #include "AST/AST.hpp"
    namespace interpreter {
      class Scanner;
    }
}

%code
{
    #include "lexer.hpp"
    #define yylex(x) scanner->lex(x)
    ProgramBuilder pb;
}

%token              EOL LPAREN RPAREN
%token <long long>  INT
%token <double>     FLOAT
%token <char>       CHAR
/* %nonassoc           ASSIGN */
%token INTT FLTT CHRT
%token IF ELSE FOR WHILE FN INCLUDE IN
%token SEMI COMMA
%token PRINT READ ADD MNS TMS DIV DDOT SET
%token <std::string> IDENTIFIER
%token ERROR

%nterm <Type> type
%nterm <Value> value

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
         pb.addInclude(std::make_shared<Include>($2));
       }
       includes
       ;

functions: %empty
         | function functions
         ;

function:
        FN IDENTIFIER'('paramDeclarations')'
        {
          std::cout << "new function id: " << $2 << std::endl;
          pb.createBlock();
          pb.newFunctionName($2);
        }
        block
        {
          pb.createFunction();
        }
        |
        FN IDENTIFIER'('params')'
        {
          std::cout << "new function id: " << $2 << std::endl;
          pb.createBlock();
          pb.newFunctionName($2);
        }
        block
        {
          pb.createFunction();
        }
        ;

paramDeclarations: paramDeclaration
      | paramDeclaration COMMA paramDeclarations
      ;

paramDeclaration: %empty
     | type[t] IDENTIFIER
     {
       std::cout << "new param: " << $2 << std::endl;
       pb.pushFunctionParam(Variable($2, $t));
     }
     ;

params: param
      | param COMMA params
      ;

param: %empty
     |
     IDENTIFIER
     {
        std::cout << "new param variable" << std::endl;
        pb.pushFuncallParam(std::make_shared<Variable>($1, VOID)); // use symTable to get the type
     }
     |
     value[v]
     {
        std::cout << "new param value" << std::endl;
        pb.pushFuncallParam(std::make_shared<Value>($v));
     }
     ;

type:
    INTT
    {
      $$ = INT;
    }
    |
    FLTT
    {
      $$ = FLT;
    }
    |
    CHRT
    {
      $$ = CHR;
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
       IDENTIFIER'('params')'
       {
         std::cout << "new funcall: " << $1 << std::endl;
         pb.createFuncall($1);
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
           type[t] IDENTIFIER
           {
             std::cout << "new declaration: " << $2 << std::endl;
             pb.pushCommand(std::make_shared<Declaration>(Variable($2, $t)));
           }
           ;

assignement:
           SET'('IDENTIFIER COMMA value[v]')'
           {
             std::cout << "new assignement: " << $3 << std::endl;
             pb.pushCommand(std::make_shared<Assignement>(Variable($3, VOID), $v));
           }
           ;

value:
     INT
     {
       std::cout << "new int: " << $1 << std::endl;
       type_t v;
       v.i = $1;
       $$ = Value(v, INT);
     }
     |
     FLOAT
     {
       std::cout << "new double: " << $1 << std::endl;
       type_t v;
       v.f = $1;
       $$ = Value(v, FLT);
     }
     |
     CHAR
     {
       std::cout << "new char: " << $1 << std::endl;
       type_t v;
       v.c = $1;
       $$ = Value(v, CHR);
     }
     ;

statements: %empty
          | statement statements
          ;

statement:
         if
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
