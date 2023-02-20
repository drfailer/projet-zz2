%{
#include <iostream>
#include <string>
#include <FlexLexer.h>
#include <fstream>
#include "AST/AST.hpp"
#include "AST/ProgramBuilder.hpp"
#include "symtable/Symtable.hpp"
#include "symtable/Symbol.hpp"
#include "symtable/ContextManager.hpp"
#include "errorManager/ErrorManager.hpp"
#define YYLOCATION_PRINT   location_print
#define YYDEBUG 1
#define DBG_PARS 0
#if DBG_PARS == 1
#define DEBUG(A) std::cout << A << std::endl
#else
#define DEBUG(A)
#endif
%}
%language "c++"
%defines "parser.hpp"
%output "parser.cpp"

%define api.parser.class {Parser}
%define api.namespace {interpreter}
%define api.value.type variant
%locations
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
// #define yylex(x) scanner->lex(x)
#define yylex(x, y) scanner->lex(x, y) // now we use yylval and yylloc
ProgramBuilder pb;
Symtable symtable;
ContextManager contextManager;
ErrorManager errMgr;
std::string currentFunction = "";

// symtable check
bool isDefined(std::string name, int line, int column, std::list<Type>& type) {
  bool defined = true;
  std::optional<Symbol> sym = contextManager.lookup(name);

  if (!sym.has_value()) {
    defined = false;
    std::ostringstream oss;
    oss << "undefined Symbol '" << name << "'";
    oss << " at: " << line << ":" << column << std::endl;
    errMgr.newError(oss.str());
    type = std::list<Type>();
  }
  else {
    type = sym.value().getType();
  }
  return defined;
}

void printType(std::ostringstream& oss, std::list<Type> types) {
  for (Type t : types) {
    oss << typeToString(t) << " -> ";
  }
  oss << "." << std::endl;
}

bool checkTypeError(std::list<Type> expectedType, std::list<Type> funcallType) {
  bool typeError = false;
  if (expectedType.size() != funcallType.size()) {
      typeError = true;
  }
  else {
    for (int i = 0; i < funcallType.size(); ++i) {
      if (expectedType.size() == 0 || funcallType.front() != expectedType.front())
        typeError = true;
      funcallType.pop_front();
      expectedType.pop_front();
    }
  }
  return typeError;
}

void checkType(std::string name, int line, int column, Type expected, Type founed)
{
  if (expected != founed) {
   std::ostringstream oss;
   oss << "assignment at " << line << ":" << column
       << " " << name << " is of type "
       << typeToString(expected)
       << " but the value assigned is of type "
       << typeToString(founed) << std::endl;
   errMgr.newWarning(oss.str());
  }
}

// d'avoir le type d'un symbol inline
Type getType(std::shared_ptr<ASTNode> node) {
  Type type = VOID;

  if(std::shared_ptr<Funcall> fun = std::dynamic_pointer_cast<Funcall>(node)) {
    // treat as a funcall
    std::optional<Symbol> funSym = contextManager.lookup(fun->getFunctionName());
    type = funSym.value().getType().back();
  }
  else if (std::shared_ptr<Variable> var = std::dynamic_pointer_cast<Variable>(node)) { // this is a variable
    std::optional<Symbol> varSym = contextManager.lookup(var->getId());
    type = varSym.value().getType().back();
  }
  else if (std::shared_ptr<Value> val = std::dynamic_pointer_cast<Value>(node)) { // this is a value
    type = val->getType();
  }
  // otherwise this is a buildin function
  return type;
}

// permet de récupérer les types des paramètres lors des appels de fonctions
std::list<Type> getTypes(std::list<std::shared_ptr<ASTNode>> nodes) {
  std::list<Type> types;
  for (std::shared_ptr<ASTNode> node : nodes) {
    types.push_back(getType(node));
  }
  return types;
}

}

%token <long long>  INT
%token <double>     FLOAT
%token <char>       CHAR
/* %nonassoc           ASSIGN */
%token INTT FLTT CHRT
%token IF ELSE FOR WHILE FN INCLUDE IN
%token SEMI COMMA ARROW
%token PRINT READ ADD MNS TMS DIV RANGE SET
%token EQL SUP INF SEQ IEQ AND OR XOR NOT
%token <std::string> IDENTIFIER
%token <std::string> STRING
%token ERROR
%token RETURN
%token HASH EOL TEXT

%nterm <Type> type
%nterm <Value> value
%nterm <std::shared_ptr<ASTNode>> inlineSymbol
%nterm <std::shared_ptr<ASTNode>> arithmeticOperations
%nterm <std::shared_ptr<ASTNode>> booleanOperation
%nterm <std::shared_ptr<ASTNode>> funcall
%nterm <std::shared_ptr<ASTNode>> operand
%nterm <std::shared_ptr<Block>> block
%nterm <std::shared_ptr<If>> if
%nterm <std::shared_ptr<If>> simpleIf
%nterm <std::shared_ptr<For>> for
%nterm <std::shared_ptr<While>> while

%%
program: %empty
       | programElt program;

programElt:
       includes
       {
         DEBUG("create new include" );
       }
       |
       function
       {
         DEBUG("create new function" );
       }
       ;

includes: INCLUDE IDENTIFIER SEMI
        {
          DEBUG("new include id: " << $2);
          pb.addInclude(std::make_shared<Include>($2));
        }
        ;

function:
        FN IDENTIFIER[name]'('paramDeclarations')'
        {
          currentFunction = $name;
          std::list<Type> funType = pb.getParamsTypes();
          funType.push_back(VOID);
          contextManager.newSymbol($name, funType, FUNCTION);
          contextManager.enterScope();
        }
        block[ops]
        {
          // error if there is a return statement
          pb.createFunction($name, $ops, VOID);
          contextManager.leaveScope();
        }
        |
        FN IDENTIFIER[name]'('paramDeclarations')' ARROW type[rt]
        {
          currentFunction = $name;
          std::list<Type> funType = pb.getParamsTypes();
          funType.push_back($rt);
          contextManager.newSymbol($name, funType, FUNCTION);
          contextManager.enterScope();
        }
        block[ops]
        {
          pb.createFunction($name, $ops, $rt);
          contextManager.leaveScope();
        }
        ;

paramDeclarations: paramDeclaration
      | paramDeclaration COMMA paramDeclarations
      ;

paramDeclaration: %empty
     | type[t] IDENTIFIER
     {
       DEBUG("new param: " << $2);
       contextManager.newSymbol($2, std::list<Type>($t), FUN_PARAM);
       pb.pushFunctionParam(Variable($2, $t));
     }
     ;

params: param
      | param COMMA params
      ;

param: %empty
     |
     inlineSymbol
     {
        pb.pushFuncallParam($1);
     }
     ;

operand:
     IDENTIFIER
     {
        DEBUG("new param variable" );
        std::shared_ptr<ASTNode> v;
        std::list<Type> type;
        if (isDefined($1, @1.begin.line, @1.begin.column, type)) {
          v = std::make_shared<Variable>($1, type.back());
        }
        else {
          v = std::make_shared<Variable>($1, VOID);
        }
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
       DEBUG("new block");
       $$ = pb.endBlock();
     }
     ;

code: %empty
    | statements code
    | commands code
    | RETURN inlineSymbol[rs] SEMI
    {
      std::optional<Symbol> sym =
        contextManager.lookup(currentFunction);
      Type rtType = getType($rs);
      Type functionType = sym.value().getType().back();
      std::ostringstream oss;

      if (functionType == VOID) { // no return allowed
        oss << "founded return statement in " << currentFunction
            << " at " << @1 << " which is of type void" << std::endl;
        errMgr.newError(oss.str());
      }
      // must check if rtType is not void because of the buildin function (add, ...)
      // which are not in the symtable
      else if (functionType != rtType && rtType != VOID) {
        oss << "in " << currentFunction
            << " at " << @1 << " return of type " << typeToString(rtType)
            << " but this function is of type "
            << typeToString(functionType)
            << std::endl;
        errMgr.newWarning(oss.str());
      }
      // else verify the type and throw a warning
      pb.pushBlock(std::make_shared<Return>($rs));
    }
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
      DEBUG("read");
      std::list<Type> type;
      if (isDefined($v, @v.begin.line, @v.begin.column, type)) {
        pb.pushBlock(std::make_shared<Read>(Variable($v, type.back())));
      }
      else {
        pb.pushBlock(std::make_shared<Read>(Variable($v, VOID)));
      }
    }
    ;

print:
     PRINT'('STRING[s]')'
     {
        DEBUG("print str");
        pb.pushBlock(std::make_shared<Print>($s));
     }
     |
     PRINT'('IDENTIFIER[v]')'
     {
        DEBUG("print var");
        std::list<Type> type;
        if (isDefined($v, @v.begin.line, @v.begin.column, type)) {
          pb.pushBlock(std::make_shared<Print>(std::make_shared<Variable>($v,
            type.back())));
        }
        else {
          pb.pushBlock(std::make_shared<Print>(std::make_shared<Variable>($v, VOID)));
        }
     }
     ;

inlineSymbol:
             arithmeticOperations { $$ = $1; }
            | funcall { $$ = $1; }
            | value { $$ = std::make_shared<Value>($1); }
            |
            IDENTIFIER
            {
               DEBUG("new param variable");
               std::list<Type> type;
               std::shared_ptr<Variable> v;
               if (isDefined($1, @1.begin.line, @1.begin.column, type)) {
                 v = std::make_shared<Variable>($1, type.back());
               }
               else {
                 v = std::make_shared<Variable>($1, VOID);
               }
               $$ = std::make_shared<Variable>($1, VOID);
            }
            ;

arithmeticOperations:
                    ADD'(' operand[left] COMMA operand[right] ')'
                    {
                      DEBUG("addOP");
                      $$ = std::make_shared<AddOP>($left, $right);
                    }
                    |
                    MNS'(' operand[left] COMMA operand[right] ')'
                    {
                      DEBUG("mnsOP");
                      $$ = std::make_shared<MnsOP>($left, $right);
                    }
                    |
                    TMS'(' operand[left] COMMA operand[right] ')'
                    {
                      DEBUG("tmsOP");
                      $$ = std::make_shared<TmsOP>($left, $right);
                    }
                    |
                    DIV'(' operand[left] COMMA operand[right] ')'
                    {
                      DEBUG("divOP");
                      $$ = std::make_shared<DivOP>($left, $right);
                    }
                    ;

booleanOperation:
                 EQL'(' operand[left] COMMA operand[right] ')'
                 {
                    DEBUG("EqlOP");
                    $$ = std::make_shared<EqlOP>($left, $right);
                 }
                 |
                 SUP'(' operand[left] COMMA operand[right] ')'
                 {
                    DEBUG("SupOP");
                    $$ = std::make_shared<SupOP>($left, $right);
                 }
                 |
                 INF'(' operand[left] COMMA operand[right] ')'
                 {
                    DEBUG("InfOP");
                    $$ = std::make_shared<InfOP>($left, $right);
                 }
                 |
                 SEQ'(' operand[left] COMMA operand[right] ')'
                 {
                    DEBUG("SeqOP");
                    $$ = std::make_shared<SeqOP>($left, $right);
                 }
                 |
                 IEQ'(' operand[left] COMMA operand[right] ')'
                 {
                    DEBUG("IeqOP");
                    $$ = std::make_shared<IeqOP>($left, $right);
                 }
                 |
                 AND'('booleanOperation[left] COMMA booleanOperation[right]')'
                 {
                    DEBUG("AndOP");
                    $$ = std::make_shared<AndOP>($left, $right);
                 }
                 |
                 OR'('booleanOperation[left] COMMA booleanOperation[right]')'
                 {
                    DEBUG("OrOP");
                    $$ = std::make_shared<OrOP>($left, $right);
                 }
                 |
                 XOR'('booleanOperation[left] COMMA booleanOperation[right]')'
                 {
                    DEBUG("XorOP");
                    $$ = std::make_shared<XorOP>($left, $right);
                 }
                 |
                 NOT'('booleanOperation[op]')'
                 {
                    DEBUG("NotOP");
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
         std::list<Type> expectedType;
         isDefined($1, @1.begin.line, @1.begin.column, expectedType);
         std::shared_ptr<Funcall> funcall = pb.createFuncall();

         // get the founded return type (types of the parameters)
         std::list<Type> funcallType = getTypes(funcall->getParams());

         expectedType.pop_back(); // remove the return type
         bool typeError = checkTypeError(expectedType, funcallType);

         if (typeError) {
           std::ostringstream oss;
           oss << "Type error: at " << @1 << " in " << $1 << ": the expected type was:" << std::endl;
           printType(oss, expectedType);
           oss << "founded:" << std::endl;
           printType(oss, funcallType);
           errMgr.newError(oss.str());
         }
         DEBUG("new funcall: " << $1);
         // check the type
         $$ = funcall;
       }
       ;

declaration:
           type[t] IDENTIFIER
           {
             DEBUG("new declaration: " << $2);
             contextManager.newSymbol($2, std::list<Type>($t), LOCAL_VAR);
             pb.pushBlock(std::make_shared<Declaration>(Variable($2, VOID)));
           }
           ;

assignement:
           SET'('IDENTIFIER[v] COMMA inlineSymbol[ic]')'
           {
             DEBUG("new assignement: " << $v);
             std::list<Type> type;
             if (isDefined($v, @v.begin.line, @v.begin.column, type)) {
               // TODO: check the type of the symbol and raise a warning if cast
               // needed
               Type icType = getType($ic);
               checkType($v, @v.begin.line, @v.begin.column, type.back(), icType);
               pb.pushBlock(std::make_shared<Assignement>(Variable($v,
                 type.back()), $ic));
             }
             else {
               pb.pushBlock(std::make_shared<Assignement>(Variable($v, VOID), $ic));
             }
           }
           ;

value:
     INT
     {
       DEBUG("new int: " << $1);
       type_t v = { .i = $1 };
       $$ = Value(v, INT);
     }
     |
     FLOAT
     {
       DEBUG("new double: " << $1);
       type_t v = { .f = $1 };
       $$ = Value(v, FLT);
     }
     |
     CHAR
     {
       DEBUG("new char: " << $1);
       type_t v = { .c = $1 };
       $$ = Value(v, CHR);
     }
     ;

statements: %empty
          | statement statements
          ;

statement:
         if
         {
           DEBUG("new if");
           pb.pushBlock($1);
         }
         |
         for
         {
           DEBUG("new for");
           pb.pushBlock($1);
         }
         |
         while
         {
           DEBUG("new for");
           pb.pushBlock($1);
         }
         ;

if:
  simpleIf
  {
    $$ = $1;
  }
  |
  simpleIf[sif] ELSE
  {
    contextManager.enterScope();
  }
  block[ops]
  {
    DEBUG("else");
    std::shared_ptr<If> ifstmt = $sif;
    // adding else block
    ifstmt->createElse($ops);
    $$ = ifstmt;
    contextManager.leaveScope();
  }
  ;

simpleIf:
  IF '('booleanOperation[cond]')'
  {
    contextManager.enterScope();
  }
  block[ops]
  {
    DEBUG("if");
    $$ = pb.createIf($cond, $ops);
    contextManager.leaveScope();
  }
  ;

for:
   FOR IDENTIFIER[v] IN RANGE'('operand[b] COMMA operand[e] COMMA operand[s]')'
   {
     contextManager.enterScope();
   }
   block[ops]
   {
     DEBUG("in for");
     Variable v($v, VOID);
     std::list<Type> type;
     if (isDefined($v, @v.begin.line, @v.begin.column, type)) {
       v = Variable($v, type.back());
       checkType("RANGE_BEGIN", @b.begin.line, @b.begin.column, type.back(), getType($b));
       checkType("RANGE_END", @e.begin.line, @e.begin.column, type.back(), getType($e));
       checkType("RANGE_STEP", @s.begin.line, @s.begin.column, type.back(), getType($s));
     }
     $$ = pb.createFor(v, $b, $e, $s, $ops);
     contextManager.leaveScope();
   }
   ;

while:
     WHILE '('booleanOperation[cond]')'
     {
       contextManager.enterScope();
     }
     block[ops]
     {
       DEBUG("in while");
       $$ = pb.createWhile($cond, $ops);
       contextManager.leaveScope();
     }
     ;
%%

void interpreter::Parser::error(const location_type& loc, const std::string& msg) {
      std::ostringstream oss;
      oss << msg << " at: " << loc << std::endl;
      errMgr.newError(oss.str());
}

int main(int argc, char **argv) {
  contextManager.enterScope(); // TODO: put the current module/file name here
  // TODO: learn how to properly create steam.
  if (argc == 2) {
    std::ifstream is(argv[1], std::ios::in);
    interpreter::Scanner scanner{ is , std::cerr };
    interpreter::Parser parser{ &scanner };
    parser.parse();
    // loock for main
    std::optional<Symbol> sym = contextManager.lookup("main");
    if (!sym.has_value()) {
      errMgr.newError("no entry point.");
    }
    errMgr.report();
    if (!errMgr.getErrors()) {
      pb.display();
    }
  }
  else {
    interpreter::Scanner scanner{ std::cin, std::cerr };
    interpreter::Parser parser{ &scanner };
    parser.parse();
    errMgr.report();
    if (!errMgr.getErrors()) {
      pb.display();
    }
  }
}
