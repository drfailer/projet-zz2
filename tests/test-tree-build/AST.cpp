#include "AST.hpp"
#include <iostream>
#include <list>
#include <memory>
#include <ostream>
#include <type_traits>

// TODO: create multiple files

/* -------------------------------------------------------------------------- */

void Function::display() {
  std::cout << "(fun: " << id << std::endl;
  Statement::display();
  std::cout << ")" << std::endl;
}

Function::Function(std::string nid, std::shared_ptr<Block> instructions):
  Statement(instructions), id(nid)
{
}

/* -------------------------------------------------------------------------- */

Include::Include(std::string name): libName(name)
{
}

void Include::display()
{
  std::cout << "(include: " << libName << ")" << std::endl;
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
  std::cout << "  (block:" << std::endl;
  for (std::shared_ptr<ASTNode> o: operations) {
    std::cout << "    ";
    o->display();
  }
  std::cout << "  )" << std::endl;
}

/* -------------------------------------------------------------------------- */

/* Assignement::Assignement(std::string nvar, long long v) */
/* { */
/*   var = nvar; */
/*   value.i = v; */
/*   type = NBR; */
/* } */

/* Assignement::Assignement(std::string nvar, double v) */
/* { */
/*   var = nvar; */
/*   value.f = v; */
/*   type = FLT; */
/* } */

/* Assignement::Assignement(std::string nvar, char v) */
/* { */
/*   var = nvar; */
/*   value.c = v; */
/*   type = CHR; */
/* } */

Assignement::Assignement(std::string var, type_t value): var(var), value(value)
                                                         {}

void Assignement::display()
{
  std::cout << "(nbr-assign: " << var << " '" << value.i << "')" << std::endl;
  // TODO: use the symtable
  /* switch (type) { */
  /*   case NBR: */
  /*     std::cout << "(nbr-assign: " << var << " '" << value.i << "')" << std::endl; */
  /*     break; */
  /*   case FLT: */
  /*     std::cout << "(flt-assign: " << var << " '" << value.f << "')" << std::endl; */
  /*     break; */
  /*   case CHR: */
  /*     std::cout << "(chr-assign: " << var << " '" << value.c << "')" << std::endl; */
  /*     break; */
  /*   default: */
  /*     std::cout << "ERROR" << std::endl; */
  /*     break; */
  /* } */
}

/* -------------------------------------------------------------------------- */

Declaration::Declaration(std::string nvar, Type ntype):
  var(nvar), type(ntype)
{}

void Declaration::display()
{
  std::cout << "(declaration: " << var << " " << type << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

BuildinFunctionCall::BuildinFunctionCall(std::string name, std::string p):
  functionName(name), params(p)
{
}

void BuildinFunctionCall::display()
{
  std::cout << "(fncall: " << functionName << " [" << params << "])" << std::endl;
}

/* -------------------------------------------------------------------------- */

Statement::Statement(std::shared_ptr<Block> b): block(b) {}

void Statement::display()
{
  block->display();
}

/* -------------------------------------------------------------------------- */

If::If(std::string c, std::shared_ptr<Block> b): Statement(b), condition(c)
{
}

void If::display()
{
  std::cout << "(if: " << condition << std::endl;
  Statement::display();
  std::cout << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

For::For(std::string v, std::shared_ptr<Block> b): Statement(b), var(v)
{
}

For::For(std::string v, long long be, long long e, long long s, std::shared_ptr<Block> b):
  For(v, b)
{
  begin.i = be;
  end.i = e;
  step.i = s;
  type = NBR;
}

For::For(std::string v, double be, double e, double s, std::shared_ptr<Block> b):
  For(v, b)
{
  begin.f = be;
  end.f = e;
  step.f = s;
  type = FLT;
}

void For::display()
{
  if (type == NBR)
    std::cout << "(if: " << var << " " << begin.i << ".." << end.i << ".." << step.i << std::endl;
  else
    std::cout << "(flt: " << var << " " << begin.f << ".." << end.f << ".." << step.f << std::endl;
  Statement::display();
  std::cout << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

While::While(std::string c, std::shared_ptr<Block> b): Statement(b), condition(c)
{
}

void While::display()
{
  std::cout << "(while: " << condition << std::endl;
  Statement::display();
  std::cout << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

Program::Program()
{
  includes = std::list<std::shared_ptr<Include>>();
  functions = std::list<std::shared_ptr<Function>>();
}

void Program::addInclude(std::shared_ptr<Include> i) {
  includes.push_back(i);
}

void Program::addFunction(std::shared_ptr<Function> f) {
  functions.push_back(f);
}

void Program::display()
{
  for (std::shared_ptr<Include> i : includes)
    i->display();
  for (std::shared_ptr<Function> f : functions)
    f->display();
}

/* -------------------------------------------------------------------------- */

ProgramBuilder::ProgramBuilder()
{
  program = std::make_shared<Program>();
}

void ProgramBuilder::display()
{
  program->display();
}

void ProgramBuilder::addInclude(std::shared_ptr<Include> i)
{
  program->addInclude(i);
}

void ProgramBuilder::pushCommand(std::shared_ptr<ASTNode> command)
{
  blocks.back()->addOp(command);
}

// FIXME: unsafe operations
void ProgramBuilder::createBlock()
{
  blocks.push_back(std::make_shared<Block>());
}

/**
 * @brief take the last block, add it to a new If and add the new if to the
 * parent block.
 */
void ProgramBuilder::createIf()
{
  std::shared_ptr<If> newif = std::make_shared<If>("condition", blocks.back());
  blocks.pop_back();
  blocks.back()->addOp(newif);
}

/**
 * @brief take the last block, add it to a new If and add the new if to the
 * parent block.
 */
void ProgramBuilder::createFor()
{
  std::shared_ptr<For> newfor = std::make_shared<For>("n..m..s", blocks.back());
  blocks.pop_back();
  blocks.back()->addOp(newfor);
}

/**
 * @brief take the last block, add it to a new If and add the new if to the
 * parent block.
 */
void ProgramBuilder::createWhile()
{
  std::shared_ptr<While> newwhile = std::make_shared<While>("condition", blocks.back());
  blocks.pop_back();
  blocks.back()->addOp(newwhile);
}

void ProgramBuilder::createFunction()
{
  std::shared_ptr<Function> newfun = std::make_shared<Function>(lastFunctionName, blocks.back());
  blocks.pop_back(); // NOTE: should be empty at this point
                     // TODO: throw error if not empty
  program->addFunction(newfun);
}

void ProgramBuilder::newValue(long long i)
{
  lastValue.i = i;
}

void ProgramBuilder::newValue(double f)
{
  lastValue.f = f;
}

void ProgramBuilder::newValue(char c)
{
  lastValue.c = c;
}

void ProgramBuilder::newType(Type type)
{
  lastType = type;
}

void ProgramBuilder::newFunctionName(std::string name)
{
  lastFunctionName = name;
}

type_t ProgramBuilder::getLastValue()
{
  return lastValue;
}

Type ProgramBuilder::getLastType()
{
  return lastType;
}

/* -------------------------------------------------------------------------- */
