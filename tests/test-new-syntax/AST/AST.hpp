#pragma once
#include <list>
#include <string>
#include <memory>

// TODO: create multiple files
// TODO: arithmetic operations
// TODO: boolean operations

union type_t
{
  long long i;
  double f;
  char c;
};

enum Type
{
  INT,
  FLT,
  CHR,
  VOID
};

/******************************************************************************/
/*                                    node                                    */
/******************************************************************************/

class ASTNode
{
  public:
    virtual void display() = 0;
};

class Block : public ASTNode
{
  private:
    std::list<std::shared_ptr<ASTNode>> operations;

  public:
    void addOp(std::shared_ptr<ASTNode>);
    void display() override;
    Block();
};

class Include : public ASTNode
{
  private:
    std::string libName;

  public:
    void display() override;
    Include(std::string);
};

/******************************************************************************/
/*                                 litterals                                  */
/******************************************************************************/

class Litteral : public ASTNode // ???
{
  /* public: */
  /*   virtual ~Litteral() = 0; */
};

class Value : public Litteral
{
  private:
    type_t value;
    Type type;

  public:
    void display() override;
    type_t getValue();
    Type getType();
    Value(type_t, Type);
    Value() = default;
};

class Variable : public Litteral
{
  private:
    std::string id;
    Type type;

  public:
    void display() override;
    std::string getId();
    Type getType();
    Variable(std::string, Type);
};

/******************************************************************************/
/*                                 commands                                   */
/******************************************************************************/

// NOTE: may be not as usefull for the implementation
/* class Command : public ASTNode */
/* { */
/*   public: */
/*     virtual void display() override; */
/*     virtual ~Command(); */
/* }; */

class Assignement : public ASTNode
{
  private:
    Variable variable;
    std::shared_ptr<ASTNode> value;

  public:
    void display() override;
    /* Assignement(std::string, long long); */
    /* Assignement(std::string, double); */
    /* Assignement(std::string, char); */
    Assignement(Variable, std::shared_ptr<ASTNode>);
};

class Declaration : public ASTNode
{
  private:
    Variable variable;

  public:
    void display() override;
    Declaration(Variable);
};

// TODO: may be an abstract class and have one class per function will be esier
class Funcall : public ASTNode
{
  private:
    std::string functionName;
    std::list<std::shared_ptr<Litteral>> params; // TODO: get all params

  public:
    Funcall(std::string, std::list<std::shared_ptr<Litteral>>);
    void display() override;
};

/******************************************************************************/
/*                                 statements                                 */
/******************************************************************************/

class Statement : public ASTNode
{
  private:
    std::shared_ptr<Block> block;

  public:
    Statement(std::shared_ptr<Block>);
    void display() override;
};

class Function : public Statement
{
  private:
    std::string id;
    std::list<Variable> params; // NOTE: ????
    Type returnType;

  public:
    void display() override;
    Function(std::string, std::list<Variable>, Type, std::shared_ptr<Block>);
};

// TODO: else | else if

class If : public Statement
{
  private:
    std::string condition; // TODO: put real conditions

  public:
    If(std::string, std::shared_ptr<Block>);
    void display() override;
};

class For : public Statement
{
  private:
    std::string var;
    Type type;
    type_t begin;
    type_t end;
    type_t step;

  public:
    For(std::string, std::shared_ptr<Block>);
    For(std::string, long long, long long, long long, std::shared_ptr<Block>);
    For(std::string, double, double, double, std::shared_ptr<Block>);
    void display() override;
};

class While : public Statement
{
  private:
    std::string condition; // TODO: create condition class

  public:
    While(std::string, std::shared_ptr<Block>);
    void display() override;
};

/******************************************************************************/
/*                           arithmetic operations                            */
/******************************************************************************/

class BinaryOperation: public ASTNode
{
  protected:
    std::shared_ptr<ASTNode> left;
    std::shared_ptr<ASTNode> right;

  public:
    BinaryOperation(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override;
};

class AddOP: public BinaryOperation
{
  public:
    AddOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // +
};

class MnsOP: public BinaryOperation
{
  public:
    MnsOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // -
};

class TmsOP: public BinaryOperation
{
  public:
    TmsOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // *
};

class DivOP: public BinaryOperation
{
  public:
    DivOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // /
};

/******************************************************************************/
/*                             boolean operations                             */
/******************************************************************************/

class EqlOP: BinaryOperation
{
  public:
    void display() override; // left == right
};

class OrOP: BinaryOperation
{
  public:
    void display() override; // left || right
};

class AndOP: BinaryOperation
{
  public:
    void display() override; // left && right
};

class XorOP: BinaryOperation
{
  public:
    void display() override; // left ^ right
};

class NotOP: ASTNode
{
  private:
    std::shared_ptr<ASTNode> param;

  public:
    void display() override; // !param
};

/******************************************************************************/
/*                                  program                                   */
/******************************************************************************/

class Program: public ASTNode
{
  private:
    std::list<std::shared_ptr<Include>> includes;
    std::list<std::shared_ptr<Function>> functions;

  public:
    Program();
    void addInclude(std::shared_ptr<Include>);
    void addFunction(std::shared_ptr<Function>);
    void display() override;
};

/******************************************************************************/
/*                                    AST                                     */
/******************************************************************************/

// TODO: cette classe doit être utilisée pour construire l'abre avec le parser.
// elle doit contenir des piles tampons pour pouvoir ajouter les opération, les
// block, les statements, ... quand le parser les trouves. Les éléments en haut
// de l'arbre sont construit en derniers ! => on doit pouvoir créer une liste de
// commandes, qu'on peut combiner dans un block, block qu'on peut ajouter à un
// statement qui sera lui aussi ajouter à une liste pour pouvoir créer une
// fonction ou être ajouter à un autre block.
class ProgramBuilder
{
  private:
    std::shared_ptr<Program> program;         // current program
    std::list<std::shared_ptr<Block>> blocks; // stack of blocks (the last
                                              // element is the current block)
    std::list<Variable> funParams;        // parameters of the last function
    std::list<std::shared_ptr<Litteral>> funcallParams;    // parameters of the last funcall
    // NOTE: maybe move this to the .y file as global variable:
    std::string lastFunctionName;      // the name of the last function parsed
    /* std::list<std::shared_ptr<ASTNode>> commands; */

  public:
    void display();
    void pushBlock(std::shared_ptr<ASTNode>);
    /* void pushCommand(std::shared_ptr<ASTNode>); */
    /* std::shared_ptr<ASTNode> popCommand(); */
    void pushFuncallParam(std::shared_ptr<Litteral>);
    std::shared_ptr<Litteral> popFuncallParam();
    void pushFunctionParam(Variable);
    void newValue(long long);
    void newValue(double);
    void newValue(char);
    type_t getLastValue();
    void newValueType(Type);
    Type getLastValueType();
    void newFunctionName(std::string);
    void createBlock();
    void createIf(); // TODO: gérer les conditions
    void createFor();
    void createWhile();
    std::shared_ptr<ASTNode> createFuncall(std::string);
    void createFunction(); // TODO: add the return type
    void addInclude(std::shared_ptr<Include>);
    ProgramBuilder();
};
