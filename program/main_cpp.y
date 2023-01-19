%{
#include <iostream>
#include <string>
#include <FlexLexer.h>
#include "AST/AST.hpp"
#include "AST/ProgramBuilder.hpp"
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
    #include <memory>
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
%token SEMI COMMA ARROW
%token PRINT READ ADD MNS TMS DIV RANGE SET
%token EQL AND OR XOR NOT
%token <std::string> IDENTIFIER
%token <std::string> STRING
%token ERROR

%nterm <Type> type
%nterm <Value> value
%nterm <std::shared_ptr<ASTNode>> inlineSymbol
%nterm <std::shared_ptr<ASTNode>> arithmeticOperations
%nterm <std::shared_ptr<ASTNode>> booleanOperation
%nterm <std::shared_ptr<ASTNode>> funcall
%nterm <std::shared_ptr<ASTNode>> operand
%nterm <std::shared_ptr<Block>> block

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
        FN IDENTIFIER[name]'('paramDeclarations')' block[ops]
        {
          pb.createFunction($name, $ops, VOID);
        }
        |
        FN IDENTIFIER[name]'('paramDeclarations')' ARROW type[rt] block[ops]
        {
          pb.createFunction($name, $ops, $rt);
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
        // TODO: use symTable to get the type
        pb.pushFuncallParam(std::make_shared<Variable>($1, VOID));
     }
     |
     inlineSymbol
     {
        pb.pushFuncallParam($1);
     }
     ;

operand: %empty
     |
     IDENTIFIER
     {
        std::cout << "new param variable" << std::endl;
        std::shared_ptr<ASTNode> v = std::make_shared<Variable>($1, VOID);
        $$ = v;
     }
     |
     inlineSymbol
     {
        $$ = $1;
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

block:
     '{'
     {
        pb.beginBlock();
     }
     code '}'
     {
       std::cout << "new block" << std::endl;
       $$ = pb.endBlock();
     }
     ;

code: %empty
    | statements code
    | commands code
    ;

commands: %empty
        | command SEMI commands
        ;

command: print
        | read
        | declaration
        | assignement
        | funcall { pb.pushBlock($1); }
        ;

read: READ'('IDENTIFIER[v]')'
    {
      std::cout << "read" << std::endl;
      // TODO: use symTable to get the type of the variable
      pb.pushBlock(std::make_shared<Read>(Variable($v, VOID)));
    }
    ;

print:
     PRINT'('STRING[s]')'
     {
        std::cout << "print str" << std::endl;
        // TODO: use symTable to get the type of the variable
        pb.pushBlock(std::make_shared<Print>($s));
     }
     |
     PRINT'('IDENTIFIER[v]')'
     {
        std::cout << "print var" << std::endl;
        // TODO: use symTable to get the type of the variable
        pb.pushBlock(std::make_shared<Print>(std::make_shared<Variable>($v, VOID)));
     }
     ;

inlineSymbol:
             arithmeticOperations { $$ = $1; }
            | funcall { $$ = $1; }
            | value { $$ = std::make_shared<Value>($1); }
            ;

arithmeticOperations:
                    ADD'(' operand[left] COMMA operand[right] ')'
                    {
                      std::cout << "addOP" << std::endl;
                      $$ = std::make_shared<AddOP>($left, $right);
                    }
                    |
                    MNS'(' operand[left] COMMA operand[right] ')'
                    {
                      std::cout << "mnsOP" << std::endl;
                      $$ = std::make_shared<MnsOP>($left, $right);
                    }
                    |
                    TMS'(' operand[left] COMMA operand[right] ')'
                    {
                      std::cout << "tmsOP" << std::endl;
                      $$ = std::make_shared<TmsOP>($left, $right);
                    }
                    |
                    DIV'(' operand[left] COMMA operand[right] ')'
                    {
                      std::cout << "divOP" << std::endl;
                      $$ = std::make_shared<DivOP>($left, $right);
                    }
                    ;

booleanOperation:
                 EQL'(' operand[left] COMMA operand[right] ')'
                 {
                    std::cout << "EqlOP" << std::endl;
                    $$ = std::make_shared<EqlOP>($left, $right);
                 }
                 |
                 AND'('booleanOperation[left] COMMA booleanOperation[right]')'
                 {
                    std::cout << "AndOP" << std::endl;
                    $$ = std::make_shared<AndOP>($left, $right);
                 }
                 |
                 OR'('booleanOperation[left] COMMA booleanOperation[right]')'
                 {
                    std::cout << "OrOP" << std::endl;
                    $$ = std::make_shared<OrOP>($left, $right);
                 }
                 |
                 XOR'('booleanOperation[left] COMMA booleanOperation[right]')'
                 {
                    std::cout << "XorOP" << std::endl;
                    $$ = std::make_shared<XorOP>($left, $right);
                 }
                 |
                 NOT'('booleanOperation[op]')'
                 {
                    std::cout << "NotOP" << std::endl;
                    $$ = std::make_shared<NotOP>($op);
                 }
                 ;

funcall:
       IDENTIFIER'('
       {
          pb.newFuncall($1);
       }
       params')'
       {
         std::cout << "new funcall: " << $1 << std::endl;
         $$ = pb.createFuncall();
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
             pb.pushBlock(std::make_shared<Declaration>(Variable($2, $t)));
           }
           ;

assignement:
           SET'('IDENTIFIER[v] COMMA inlineSymbol[ic]')'
           {
             std::cout << "new assignement: " << $v << std::endl;
             pb.pushBlock(std::make_shared<Assignement>(Variable($v, VOID), $ic));
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
         }
         |
         for
         {
           std::cout << "new for" << std::endl;
         }
         |
         while
         {
           std::cout << "new for" << std::endl;
         }
         ;

if:
  IF '('booleanOperation[cond]')' block[ops]
  {
    std::cout << "if" << std::endl;
    pb.createIf($cond, $ops);
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
   FOR IDENTIFIER[v] IN RANGE'('operand[b] COMMA operand[e] COMMA operand[s]')' block[ops]
   {
     std::cout << "in for" << std::endl;
     pb.createFor(Variable($v, VOID), $b, $e, $s, $ops);
   }
   ;

while:
     WHILE '('booleanOperation[cond]')' block[ops]
     {
       std::cout << "in while" << std::endl;
       pb.createWhile($cond, $ops);
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
