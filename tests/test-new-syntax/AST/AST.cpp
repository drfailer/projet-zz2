#include "AST.hpp"
#include <iostream>
#include <list>
#include <memory>
#include <ostream>
#include <string>
#include <type_traits>

// TODO: create multiple files

std::string typToString(Type type)
{
  std::string output;

  switch (type) {
    case INT:
      output = "int";
      break;
    case FLT:
      output = "flt";
      break;
    case CHR:
      output = "chr";
      break;
    default:
      output = "void";
      break;
  }
  return output;
}

/* -------------------------------------------------------------------------- */

Value::Value(type_t value, Type type): value(value), type(type)
{
}

type_t Value::getValue()
{
  return value;
}

Type Value::getType()
{
  return type;
}

void Value::display()
{
  switch (type) {
    case INT:
      std::cout << value.i;
      break;
    case FLT:
      std::cout << value.f;
      break;
    case CHR:
      std::cout << "'" << value.c << "'";
      break;
    default:
      break;
  }
}

/* -------------------------------------------------------------------------- */

Variable::Variable(std::string id, Type type): id(id), type(type)
{
}

std::string Variable::getId()
{
  return id;
}

Type Variable::getType()
{
  return type;
}

void Variable::display()
{
  std::cout << id << " " << typToString(type);
}

/* -------------------------------------------------------------------------- */

void Function::display() {
  std::cout << "Function(" << id << ", " << typToString(returnType) << ", [";
  for (Variable p: params) {
    p.display();
    std::cout << ", ";
  }
  std::cout << "], ";
  Statement::display();
  std::cout << ")" << std::endl;
}

Function::Function(std::string id, std::list<Variable> params, Type returnType, std::shared_ptr<Block> instructions):
  Statement(instructions), id(id), params(params), returnType(returnType)
{
}

/* -------------------------------------------------------------------------- */

Include::Include(std::string name): libName(name)
{
}

void Include::display()
{
  std::cout << "Include(" << libName << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

Block::Block()
{
  operations = std::list<std::shared_ptr<ASTNode>>();
}

void Block::addOp(std::shared_ptr<ASTNode> operation)
{
  operations.push_back(operation);
}

void Block::display()
{
  std::cout << "Block(" << std::endl;
  for (std::shared_ptr<ASTNode> o: operations) {
    o->display();
  }
  std::cout << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

Assignement::Assignement(Variable variable, std::shared_ptr<ASTNode> value): variable(variable), value(value)
                                                         {}

void Assignement::display()
{
  std::cout << "Assignement(";
  variable.display();
  std::cout << ",";
  value->display();
  std::cout << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

Declaration::Declaration(Variable variable):
  variable(variable)
{}

void Declaration::display()
{
  std::cout << "Declaration(";
  variable.display();
  std::cout << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

Funcall::Funcall(std::string functionName,
    std::list<std::shared_ptr<ASTNode>> params):
  functionName(functionName), params(params)
{
}

void Funcall::display()
{
  std::cout << "Funcall(" << functionName << ", [";
  for (std::shared_ptr<ASTNode> p : params) {
    p->display();
    std::cout << ", ";
  }
  std::cout << "])" << std::endl;
}

/* -------------------------------------------------------------------------- */

Statement::Statement(std::shared_ptr<Block> b): block(b) {}

void Statement::display()
{
  block->display();
}

/* -------------------------------------------------------------------------- */

If::If(std::shared_ptr<ASTNode> c, std::shared_ptr<Block> b): Statement(b), condition(c)
{
}

void If::display()
{
  std::cout << "If(";
  condition->display();
  std::cout << ", ";
  Statement::display();
  std::cout << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

For::For(Variable v, std::shared_ptr<ASTNode> begin, std::shared_ptr<ASTNode> end,
    std::shared_ptr<ASTNode> step, std::shared_ptr<Block> b):
  Statement(b), begin(begin), end(end), step(step), var(v)
{
}

void For::display()
{
  std::cout << "For(";
  var.display();
  std::cout << ", range(";
  begin->display();
  std::cout << ",";
  end->display();
  std::cout << ",";
  step->display();
  std::cout << "), ";
  Statement::display();
  std::cout << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

While::While(std::shared_ptr<ASTNode> c, std::shared_ptr<Block> b): Statement(b), condition(c)
{
}

void While::display()
{
  std::cout << "While(";
  condition->display();
  std::cout << ", ";
  Statement::display();
  std::cout << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

BinaryOperation::BinaryOperation(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
  : left(left), right(right)
{
}

void BinaryOperation::display()
{
  left->display();
  std::cout << ", ";
  right->display();
  std::cout << ")";
}

AddOP::AddOP(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
  : BinaryOperation(left, right)
{
}

void AddOP::display()
{
  std::cout << "AddOP(";
  BinaryOperation::display();
}

MnsOP::MnsOP(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
  : BinaryOperation(left, right)
{
}

void MnsOP::display()
{
  std::cout << "MnsOP(";
  BinaryOperation::display();
}

TmsOP::TmsOP(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
  : BinaryOperation(left, right)
{
}

void TmsOP::display()
{
  std::cout << "TmsOP(";
  BinaryOperation::display();
}

DivOP::DivOP(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
  : BinaryOperation(left, right)
{
}

void DivOP::display()
{
  std::cout << "DivOP(";
  BinaryOperation::display();
}

/* -------------------------------------------------------------------------- */

EqlOP::EqlOP(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
  : BinaryOperation(left, right)
{}

void EqlOP::display()
{
  std::cout << "EqlOP(";
  BinaryOperation::display();
}

OrOP::OrOP(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
  : BinaryOperation(left, right)
{}

void OrOP::display()
{
  std::cout << "OrOP(";
  BinaryOperation::display();
}

AndOP::AndOP(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
  : BinaryOperation(left, right)
{}

void AndOP::display()
{
  std::cout << "AndOP(";
  BinaryOperation::display();
}

XorOP::XorOP(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
  : BinaryOperation(left, right)
{}

void XorOP::display()
{
  std::cout << "XorOP(";
  BinaryOperation::display();
}

NotOP::NotOP(std::shared_ptr<ASTNode> param): param(param)
{}

void NotOP::display()
{
  std::cout << "NotOP(";
  param->display();
  std::cout << ")";
}
