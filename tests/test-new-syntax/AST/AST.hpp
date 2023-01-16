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

/* class Litteral : public ASTNode // ??? */
/* { */
  /* public: */
  /* /1*   virtual ~Litteral() = 0; *1/ */
/* }; */

class Value : public ASTNode
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

class Variable : public ASTNode
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
    std::list<std::shared_ptr<ASTNode>> params; // TODO: get all params

  public:
    Funcall(std::string, std::list<std::shared_ptr<ASTNode>>);
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
    std::shared_ptr<ASTNode> condition; // TODO: put real conditions

  public:
    If(std::shared_ptr<ASTNode>, std::shared_ptr<Block>);
    void display() override;
};

class For : public Statement
{
  private:
    Variable var;
    std::shared_ptr<ASTNode> begin;
    std::shared_ptr<ASTNode> end;
    std::shared_ptr<ASTNode> step;

  public:
    For(Variable, std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>,
        std::shared_ptr<ASTNode>, std::shared_ptr<Block>);
    void display() override;
};

class While : public Statement
{
  private:
    std::shared_ptr<ASTNode> condition; // TODO: create condition class

  public:
    While(std::shared_ptr<ASTNode>, std::shared_ptr<Block>);
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

// TODO:
// - inf
// - sup
// - ieq
// - seq

class EqlOP: public BinaryOperation
{
  public:
    EqlOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // left == right
};

class OrOP: public BinaryOperation
{
  public:
    OrOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // left || right
};

class AndOP: public BinaryOperation
{
  public:
    AndOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // left && right
};

class XorOP: public BinaryOperation
{
  public:
    XorOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // left ^ right
};

class NotOP: public ASTNode
{
  private:
    std::shared_ptr<ASTNode> param;

  public:
    NotOP(std::shared_ptr<ASTNode>);
    void display() override; // !param
};
