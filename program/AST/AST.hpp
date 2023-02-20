#ifndef __AST__
#define __AST__
#include <cstdio>
#include <fstream>
#include <list>
#include <string>
#include <memory>
#include "Types.hpp"

/******************************************************************************/
/*                                    node                                    */
/******************************************************************************/

class ASTNode
{
  public:
    virtual void compile(std::fstream&, int) = 0;
    virtual void display() = 0;
    virtual ~ASTNode() = 0;
};

/******************************************************************************/
/*                                   block                                    */
/******************************************************************************/

/**
 * @brief  A `Block` refer to blocks of code between "{}". It contains the list
 *         of the instructions defined insite the brackets.
 *
 */
class Block : public ASTNode
{
  private:
    std::list<std::shared_ptr<ASTNode>> operations;

  public:
    void compile(std::fstream&, int = 0) override;
    void addOp(std::shared_ptr<ASTNode>);
    std::shared_ptr<ASTNode> getLastNode();
    void display() override;
    Block();
};

/******************************************************************************/
/*                                  includes                                  */
/******************************************************************************/

/**
 * @brief  Include a file. Note: the language doesn't have a module system, so
 *         it acts a bit like a pre-processor instruction.
 */
class Include : public ASTNode
{
  private:
    std::string libName;

  public:
    void display() override;
    void compile(std::fstream&, int) override;
    Include(std::string);
};

/******************************************************************************/
/*                                  factors                                   */
/******************************************************************************/

/**
 * @brief  Basic values of an available type.
 */
class Value : public ASTNode
{
  private:
    type_t value;
    Type type;

  public:
    void compile(std::fstream&, int) override;
    void display() override;
    type_t getValue();
    Type getType() const;
    Value(type_t, Type);
    Value() = default;
};

/**
 * @brief  Reference to a variable.
 *
 * NOTE: the type may be useless, it is here just in case.
 * TODO: justify or not the choice of having a type using the definition of the
 *       variable.
 */
class Variable : public ASTNode
{
  private:
    std::string id;
    Type type;

  public:
    void display() override;
    void compile(std::fstream&, int) override;
    std::string getId();
    Type getType() const;
    Variable(std::string, Type);
};

/******************************************************************************/
/*                                 commands                                   */
/******************************************************************************/

/**
 * @brief  Represent an assignement operation. The "ifdef" check of the
 *         variable is done in the parser using the table of symbols.
 */
class Assignement : public ASTNode
{
  private:
    Variable variable;
    std::shared_ptr<ASTNode> value;

  public:
    void display() override;
    void compile(std::fstream&, int) override;
    Assignement(Variable, std::shared_ptr<ASTNode>);
};

/**
 * @brief  Declare a variable.
 *
 * NOTE: could be nice to have a type here.
 */
class Declaration : public ASTNode
{
  private:
    Variable variable;

  public:
    void display() override;
    void compile(std::fstream&, int) override;
    Declaration(Variable);
};

/******************************************************************************/
/*                                  funcall                                   */
/******************************************************************************/

/**
 * @brief  Calling a function. This function has a name and some parameters. The
 *         parameters are node as the can have multiple types (binary operation,
 *         variable, values, other funcall, ...)
 */
class Funcall : public ASTNode
{
  private:
    std::string functionName;
    std::list<std::shared_ptr<ASTNode>> params; // TODO: get all params

  public:
    std::string getFunctionName() const;
    void compile(std::fstream&, int) override;
    std::list<std::shared_ptr<ASTNode>> getParams() const;
    Funcall(std::string, std::list<std::shared_ptr<ASTNode>>);
    void display() override;
};

// TODO: change this name
/******************************************************************************/
/*                                 statements                                 */
/******************************************************************************/

/**
 * @brief  A `Statement` is somthing that contains a `Block` (function
 *         definitions, if, for, while).
 */
class Statement : public ASTNode
{
  protected:
    std::shared_ptr<Block> block;

  public:
    Statement(std::shared_ptr<Block>);
    void display() override;
};

/**
 * @brief  Fonction declaration. It has an id (function name), some parameters
 *         (which are just variable declarations) and a return type.
 *
 * TODO: create a return statment and manage return type.
 */
class Function : public Statement
{
  private:
    std::string id;
    std::list<Variable> params;
    std::list<Type> type;

  public:
    void display() override;
    void compile(std::fstream&, int) override;
    Function(std::string, std::list<Variable>, std::shared_ptr<Block>,
        std::list<Type>);
};

/**
 * @brief  If declaration. It has a condition which is a boolean operation (ref:
 *         parser).
 */
class If : public Statement
{
  private:
    std::shared_ptr<ASTNode> condition; // TODO: put real conditions
    std::shared_ptr<Block> elseBlock;

  public:
    If(std::shared_ptr<ASTNode>, std::shared_ptr<Block>);
    void createElse(std::shared_ptr<Block>);
    void display() override;
    void compile(std::fstream&, int) override;
};

/**
 * @brief  For declaration. The for loop has a "range" which has a begin, an end
 *         and a step value. It also has a loop variable.
 */
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
    void compile(std::fstream&, int) override;
};

/**
 * @brief  While declaration. The while loop just has a condition.
 */
class While : public Statement
{
  private:
    std::shared_ptr<ASTNode> condition; // TODO: create condition class

  public:
    While(std::shared_ptr<ASTNode>, std::shared_ptr<Block>);
    void display() override;
    void compile(std::fstream&, int) override;
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
    void compile(std::fstream&, int) override;
};

class MnsOP: public BinaryOperation
{
  public:
    MnsOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // -
    void compile(std::fstream&, int) override;
};

class TmsOP: public BinaryOperation
{
  public:
    TmsOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // *
    void compile(std::fstream&, int) override;
};

class DivOP: public BinaryOperation
{
  public:
    DivOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // /
    void compile(std::fstream&, int) override;
};

/******************************************************************************/
/*                             boolean operations                             */
/******************************************************************************/

class EqlOP: public BinaryOperation
{
  public:
    EqlOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // left == right
    void compile(std::fstream&, int) override;
};

class SupOP: public BinaryOperation
{
  public:
    SupOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // left == right
    void compile(std::fstream&, int) override;
};

class InfOP: public BinaryOperation
{
  public:
    InfOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // left == right
    void compile(std::fstream&, int) override;
};

class SeqOP: public BinaryOperation
{
  public:
    SeqOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // left == right
    void compile(std::fstream&, int) override;
};

class IeqOP: public BinaryOperation
{
  public:
    IeqOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // left == right
    void compile(std::fstream&, int) override;
};

class OrOP: public BinaryOperation
{
  public:
    OrOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // left || right
    void compile(std::fstream&, int) override;
};

class AndOP: public BinaryOperation
{
  public:
    AndOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // left && right
    void compile(std::fstream&, int) override;
};

class XorOP: public BinaryOperation
{
  public:
    XorOP(std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>);
    void display() override; // left ^ right
    void compile(std::fstream&, int) override;
};

class NotOP: public ASTNode
{
  private:
    std::shared_ptr<ASTNode> param;

  public:
    NotOP(std::shared_ptr<ASTNode>);
    void display() override; // !param
    void compile(std::fstream&, int) override;
};

/******************************************************************************/
/*                                     IO                                     */
/******************************************************************************/

/**
 * @brief  Gestion de l'affichage. On ne peut afficher que soit une chaine de
 *         caratères (`"str"`), soit une variable.
 */
class Print: public ASTNode
{
  private:
    std::string str;
    std::shared_ptr<ASTNode> content;

  public:
    void display() override;
    Print(std::string);
    Print(std::shared_ptr<ASTNode>);
    void compile(std::fstream&, int) override;
};

/**
 * @brief  Gestion de la saisie clavier.
 */
class Read: public ASTNode
{
  private:
    Variable variable;

  public:
    void display() override;
    Read(Variable);
    void compile(std::fstream&, int) override;
};

/******************************************************************************/
/*                                   return                                   */
/******************************************************************************/

class Return: public ASTNode
{
  private:
    std::shared_ptr<ASTNode> returnExpr;

  public:
    void display() override;
    void compile(std::fstream&, int) override;
    Return(std::shared_ptr<ASTNode>);
};

#endif
