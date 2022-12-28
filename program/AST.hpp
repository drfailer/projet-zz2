#include <list>
#include <string>

// TODO: create multiple files

union type_t
{
  int i;
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

class Node
{
  public:
    virtual void afficher();
};

class Block : public Node
{
  private:
    std::list<Node> operations;

  public:
    void ajoutOp(Node);
    void afficher() override;
    Block();
};

class Function : public Node
{
  private:
    std::string id;
    Block instructions;

  public:
    void afficher() override;
    Function(std::string, Block);
};

class Include : public Node
{
  private:
    std::string libName;

  public:
    void afficher() override;
};

/******************************************************************************/
/*                                 commands                                   */
/******************************************************************************/

class Command : public Node
{
};

class Assignement : public Command
{
  private:
    std::string var;
    type_t value;
    Type type;

  public:
    void afficher() override;
    Assignement(std::string, type_t, Type);
};

class Declaration : public Command
{
  private:
    std::string var;
    Type type;

  public:
    void afficher() override;
};

class BuildinFunctionCall : public Command
{
  private:
    std::string functionName;
    std::string params; // TODO: get all params

  public:
    void afficher() override;
};

/******************************************************************************/
/*                                 statements                                 */
/******************************************************************************/

class Statement : public Node
{
  private:
    Block block;

  public:
    void afficher() override;
};

// TODO: else | else if

class If : public Statement
{
  private:
    std::string condition; // TODO: put real conditions

  public:
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
    void afficher() override;
};

class While : public Statement
{
  private:
    std::string condtion; // TODO: create condition class

  public:
    void afficher() override;
};

class AST
{
  private:
    Node program;

  public:
    void afficher();
};

