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
    virtual void afficher() = 0;
    virtual ~ASTNode() = 0;
};

class Block : public ASTNode
{
  private:
    std::list<ASTNode*> operations;

  public:
    void ajoutOp(ASTNode*);
    void afficher() override;
    Block();
    ~Block();
};

class Function : public ASTNode
{
  private:
    std::string id;
    Block* instructions;

  public:
    void afficher() override;
    Function(std::string, Block*);
    ~Function();
};

class Include : public ASTNode
{
  private:
    std::string libName;

  public:
    void afficher() override;
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
/*     virtual void afficher() override; */
/*     virtual ~Command(); */
/* }; */

class Assignement : public ASTNode
{
  private:
    std::string var;
    type_t value;
    Type type;

  public:
    void afficher() override;
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
    void afficher() override;
    Declaration(std::string, Type);
    ~Declaration();
};

class BuildinFunctionCall : public ASTNode
{
  private:
    std::string functionName;
    std::string params; // TODO: get all params

  public:
    BuildinFunctionCall(std::string, std::string);
    ~BuildinFunctionCall();
    void afficher() override;
};

/******************************************************************************/
/*                                 statements                                 */
/******************************************************************************/

class Statement : public ASTNode
{
  private:
    Block block;

  public:
    Statement(Block);
    ~Statement();
    void afficher() override;
};

// TODO: else | else if

class If : public Statement
{
  private:
    std::string condition; // TODO: put real conditions

  public:
    If(std::string, Block);
    ~If();
    void afficher() override;
};

class For : public Statement
{
  private:
    std::string var;
    type_t begin;
    type_t end;
    type_t step;

  public:
    For(std::string, type_t, type_t, type_t, Block);
    ~For();
    void afficher() override;
};

class While : public Statement
{
  private:
    std::string condtion; // TODO: create condition class

  public:
    While(std::string, Block);
    ~While();
    void afficher() override;
};

class AST
{
  private:
    ASTNode* program;

  public:
    void afficher();
    AST(ASTNode&);
    ~AST();
};

