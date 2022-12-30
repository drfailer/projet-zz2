#pragma once
#include <list>
#include <string>

// TODO: create multiple files

union type_t
{
  long long i;
  double f;
  char c;
};

enum Type
{
  NBR,
  FLT,
  CHR
};

/******************************************************************************/
/*                                    node                                    */
/******************************************************************************/

class ASTNode
{
  public:
    virtual void display() = 0;
    virtual ~ASTNode() = 0;
};

class Block : public ASTNode
{
  private:
    std::list<ASTNode*> operations;

  public:
    void addOp(ASTNode*);
    void display() override;
    Block();
    ~Block();
};

class Include : public ASTNode
{
  private:
    std::string libName;

  public:
    void display() override;
    Include(std::string);
    ~Include();
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
    std::string var;
    type_t value;
    Type type;

  public:
    void display() override;
    Assignement(std::string, long long);
    Assignement(std::string, double);
    Assignement(std::string, char);
    ~Assignement();
};

class Declaration : public ASTNode
{
  private:
    std::string var;
    Type type;

  public:
    void display() override;
    Declaration(std::string, Type);
    ~Declaration();
};

// TODO: may be an abstract class and have one class per function will be esier
class BuildinFunctionCall : public ASTNode
{
  private:
    std::string functionName;
    std::string params; // TODO: get all params

  public:
    BuildinFunctionCall(std::string, std::string);
    ~BuildinFunctionCall();
    void display() override;
};

/******************************************************************************/
/*                                 statements                                 */
/******************************************************************************/

class Statement : public ASTNode
{
  private:
    Block* block;

  public:
    Statement(Block*);
    ~Statement();
    void display() override;
};

class Function : public Statement
{
  private:
    std::string id;

  public:
    void display() override;
    Function(std::string, Block*);
    ~Function();
};

// TODO: else | else if

class If : public Statement
{
  private:
    std::string condition; // TODO: put real conditions

  public:
    If(std::string, Block*);
    ~If();
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
    For(std::string, Block*);
    For(std::string, long long, long long, long long, Block*);
    For(std::string, double, double, double, Block*);
    ~For();
    void display() override;
};

class While : public Statement
{
  private:
    std::string condition; // TODO: create condition class

  public:
    While(std::string, Block*);
    ~While();
    void display() override;
};

/******************************************************************************/
/*                                  program                                   */
/******************************************************************************/

class Program: public ASTNode
{
  private:
    std::list<Include*> includes;
    std::list<Function*> functions;

  public:
    Program();
    ~Program();
    void addInclude(Include*);
    void addFunctioin(Function*);
    void display() override;
};

/******************************************************************************/
/*                                    AST                                     */
/******************************************************************************/

class AST
{
  private:
    Program* program;

  public:
    void display();
    AST(ASTNode&);
    ~AST();
};

