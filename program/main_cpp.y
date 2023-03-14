%{
#include <iostream>
#include <string>
#include <FlexLexer.h>
#include <fstream>
#include <filesystem>
#include "AST/AST.hpp"
#include "AST/ProgramBuilder.hpp"
#include "symtable/Symtable.hpp"
#include "symtable/Symbol.hpp"
#include "symtable/ContextManager.hpp"
#include "errorManager/ErrorManager.hpp"
#define YYLOCATION_PRINT   location_print
#define YYDEBUG 1
#define DBG_PARS 1
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
%parse-param {Scanner* scanner} {ProgramBuilder& pb}

%code requires
{
    #include "AST/AST.hpp"
    #include "AST/ProgramBuilder.hpp"
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

void checkType(std::string name, int line, int column, Type expected, Type founded)
{
  if (expected != founded && founded != VOID) {
   std::ostringstream oss;
   oss << "assignment at " << line << ":" << column
       << " " << name << " is of type "
       << typeToString(expected)
       << " but the value assigned is of type "
       << typeToString(founded) << std::endl;
   errMgr.newWarning(oss.str());
  }
}

// permet de récupérer les types des paramètres lors des appels de fonctions
std::list<Type> getTypes(std::list<std::shared_ptr<TypedElement>> nodes) {
  std::list<Type> types;
  for (std::shared_ptr<TypedElement> node : nodes) {
    types.push_back(node->getType());
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
%token SEMI COMMA ARROW OSQUAREB CSQUAREB
%token PRINT READ ADD MNS TMS DIV RANGE SET
%token EQL SUP INF SEQ IEQ AND OR XOR NOT
%token <std::string> IDENTIFIER
%token <std::string> STRING
%token ERROR
%token RETURN
%token HASH EOL TEXT

%nterm <Type> type
%nterm <Value> value
%nterm <std::shared_ptr<TypedElement>> inlineSymbol
%nterm <std::shared_ptr<TypedElement>> container
%nterm <std::shared_ptr<TypedElement>> arithmeticOperations
%nterm <std::shared_ptr<ASTNode>> booleanOperation
%nterm <std::shared_ptr<TypedElement>> funcall
%nterm <std::shared_ptr<Block>> block
%nterm <std::shared_ptr<If>> if
%nterm <std::shared_ptr<If>> simpleIf
%nterm <std::shared_ptr<For>> for
%nterm <std::shared_ptr<While>> while

%start start

%%
start: program;

program: %empty
       | programElt program
       ;

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

includes: INCLUDE STRING[path] SEMI
        {
          DEBUG("new include id: " << $path);
          // TODO: test if the file is not already included
          if (!pb.getProgram()->isIncluded($path)) {
            DEBUG("===========================================");
            pb.addInclude($path);
            std::ifstream is($path, std::ios::in);
            interpreter::Scanner scanner{ is, std::cerr };
            interpreter::Parser parser{ &scanner, pb };
            parser.parse();
            pb.display();
            DEBUG("-------------------------------------------");
          }
        }
        ;

function:
        FN IDENTIFIER[name]'('paramDeclarations')'
        {
          // TODO: check if the function is already defined
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
     | type[t] IDENTIFIER OSQUAREB INT[size] CSQUAREB
     {
        DEBUG("new param: " << $2);
        contextManager.newSymbol($2, std::list<Type>($t), LOCAL_ARRAY);
        pb.pushFunctionParam(Array($2, $size, $t));
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
      Type rtType = $rs->getType();
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

read: READ'('container[c]')'
    {
      DEBUG("read");
      pb.pushBlock(std::make_shared<Read>($c));
    }
    ;

print:
     PRINT'('STRING[s]')'
     {
        DEBUG("print str");
        pb.pushBlock(std::make_shared<Print>($s));
     }
     |
     PRINT'('inlineSymbol[ic]')'
     {
        DEBUG("print var");
        pb.pushBlock(std::make_shared<Print>($ic));
     }
     ;

inlineSymbol:
             arithmeticOperations { $$ = $1; }
            | funcall { $$ = $1; }
            | value { $$ = std::make_shared<Value>($1); }
            | container { $$ = $1; }
            ;

container:
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
            $$ = v;
         }
         | IDENTIFIER OSQUAREB inlineSymbol[index] CSQUAREB
         {
            DEBUG("using an array");
            std::list<Type> type;
            std::shared_ptr<ArrayAccess> v;
            // TODO: refactor isDefined
            if (isDefined($1, @1.begin.line, @1.begin.column, type)) {
              std::optional<Symbol> sym = contextManager.lookup($1);
              // error if the symbol is not an array
              if (sym.value().getKind() != LOCAL_ARRAY) {
                 std::ostringstream oss;
                 oss << $1 << " can't be used as an array at "
                     << @1.begin.line << ":" << @2.begin.column
                     << "." << std::endl;
                 errMgr.newError(oss.str());
              }
              v = std::make_shared<ArrayAccess>($1, -1, type.back(), $index);
            }
            else {
              v = std::make_shared<ArrayAccess>($1, -1, VOID, $index);
            }
            $$ = v;
         }
         ;

arithmeticOperations:
                    ADD'(' inlineSymbol[left] COMMA inlineSymbol[right] ')'
                    {
                      DEBUG("addOP");
                      $$ = std::make_shared<AddOP>($left, $right);
                    }
                    |
                    MNS'(' inlineSymbol[left] COMMA inlineSymbol[right] ')'
                    {
                      DEBUG("mnsOP");
                      $$ = std::make_shared<MnsOP>($left, $right);
                    }
                    |
                    TMS'(' inlineSymbol[left] COMMA inlineSymbol[right] ')'
                    {
                      DEBUG("tmsOP");
                      $$ = std::make_shared<TmsOP>($left, $right);
                    }
                    |
                    DIV'(' inlineSymbol[left] COMMA inlineSymbol[right] ')'
                    {
                      DEBUG("divOP");
                      $$ = std::make_shared<DivOP>($left, $right);
                    }
                    ;

booleanOperation:
                 EQL'(' inlineSymbol[left] COMMA inlineSymbol[right] ')'
                 {
                    DEBUG("EqlOP");
                    $$ = std::make_shared<EqlOP>($left, $right);
                 }
                 |
                 SUP'(' inlineSymbol[left] COMMA inlineSymbol[right] ')'
                 {
                    DEBUG("SupOP");
                    $$ = std::make_shared<SupOP>($left, $right);
                 }
                 |
                 INF'(' inlineSymbol[left] COMMA inlineSymbol[right] ')'
                 {
                    DEBUG("InfOP");
                    $$ = std::make_shared<InfOP>($left, $right);
                 }
                 |
                 SEQ'(' inlineSymbol[left] COMMA inlineSymbol[right] ')'
                 {
                    DEBUG("SeqOP");
                    $$ = std::make_shared<SeqOP>($left, $right);
                 }
                 |
                 IEQ'(' inlineSymbol[left] COMMA inlineSymbol[right] ')'
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
         bool defined = isDefined($1, @1.begin.line, @1.begin.column, expectedType);
         std::shared_ptr<Funcall> funcall = pb.createFuncall();

         if (defined) {
           // get the founded return type (types of the parameters)
           std::list<Type> funcallType = getTypes(funcall->getParams());
           funcall->setType(expectedType.back());
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
             std::list<Type> t;
             t.push_back($t);
             contextManager.newSymbol($2, t, LOCAL_VAR);
             pb.pushBlock(std::make_shared<Declaration>(Variable($2, $t)));
           }
           | type[t] IDENTIFIER OSQUAREB INT[size] CSQUAREB
           {
              DEBUG("new array declaration: " << $2);
              std::list<Type> t;
              t.push_back($t);
              contextManager.newSymbol($2, t, LOCAL_ARRAY);
              pb.pushBlock(std::make_shared<ArrayDeclaration>($2, $size, $t));
           }
           ;

assignement:
           SET'('container[c] COMMA inlineSymbol[ic]')'
           {
             DEBUG("new assignement");
             Type icType = $ic->getType();
             std::shared_ptr<Variable> v = std::static_pointer_cast<Variable>($c);
             checkType(v->getId(), @c.begin.line, @c.begin.column, $c->getType(), icType);
             pb.pushBlock(std::make_shared<Assignement>($c, $ic));
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
   FOR IDENTIFIER[v] IN RANGE'('inlineSymbol[b] COMMA inlineSymbol[e] COMMA inlineSymbol[s]')'
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
       checkType("RANGE_BEGIN", @b.begin.line, @b.begin.column, type.back(), $b->getType());
       checkType("RANGE_END", @e.begin.line, @e.begin.column, type.back(), $e->getType());
       checkType("RANGE_STEP", @s.begin.line, @s.begin.column, type.back(), $s->getType());
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
  ProgramBuilder pb;
  contextManager.enterScope(); // TODO: put the current module/file name here
  // TODO: learn how to properly create steam.
  if (argc == 2) {
    std::ifstream is(argv[1], std::ios::in);
    interpreter::Scanner scanner{ is , std::cerr };
    interpreter::Parser parser{ &scanner, pb };
    parser.parse();
    // loock for main
    std::optional<Symbol> sym = contextManager.lookup("main");
    if (!sym.has_value()) {
      errMgr.newError("no entry point.");
    }
    errMgr.report();
    pb.display();
    if (!errMgr.getErrors()) {
      std::ofstream fs("a.out");
      pb.getProgram()->compile(fs);
      std::filesystem::permissions(
        "a.out",
        std::filesystem::perms::owner_exec | std::filesystem::perms::group_exec
        | std::filesystem::perms::others_exec,
        std::filesystem::perm_options::add
      );
      // pb.display();
    }
  }
  else {
    interpreter::Scanner scanner{ std::cin, std::cerr };
    interpreter::Parser parser{ &scanner, pb };
    parser.parse();
    errMgr.report();
    if (!errMgr.getErrors()) {
      pb.display();
    }
  }
}
