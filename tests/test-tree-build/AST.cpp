#include "AST.hpp"
#include <iostream>
#include <list>
#include <ostream>

// TODO: create multiple files

ASTNode::~ASTNode() {}

/* -------------------------------------------------------------------------- */

void Function::display() {
  std::cout << "(fun: " << id << std::endl;
  Statement::display();
  std::cout << ")" << std::endl;
}

Function::Function(std::string nid, Block* instructions):
  Statement(instructions), id(nid)
{
}

Function::~Function()
{
}

/* -------------------------------------------------------------------------- */

Include::Include(std::string name): libName(name)
{
}

Include::~Include()
{
}

void Include::display()
{
  std::cout << "(include: " << libName << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

Block::Block()
{
  operations = std::list<ASTNode*>();
}

Block::Block(std::list<ASTNode*> ops)
{
  operations = ops;
}

Block::~Block()
{
  for (ASTNode* o : operations)
    delete o;
}

void Block::addOp(ASTNode* operation)
{
  operations.push_back(operation);
}

void Block::display()
{
  std::cout << "  (block:" << std::endl;
  for (ASTNode* o: operations) {
    std::cout << "    ";
    o->display();
  }
  std::cout << "  )" << std::endl;
}

/* -------------------------------------------------------------------------- */

Assignement::Assignement(std::string nvar, long long v)
{
  var = nvar;
  value.i = v;
  type = NBR;
}

Assignement::Assignement(std::string nvar, double v)
{
  var = nvar;
  value.f = v;
  type = FLT;
}

Assignement::Assignement(std::string nvar, char v)
{
  var = nvar;
  value.c = v;
  type = CHR;
}

Assignement::~Assignement() {}

void Assignement::display()
{
  // TODO: trouver mieux qu'un switch
  switch (type) {
    case NBR:
      std::cout << "(nbr-assign: " << var << " '" << value.i << "')" << std::endl;
      break;
    case FLT:
      std::cout << "(flt-assign: " << var << " '" << value.f << "')" << std::endl;
      break;
    case CHR:
      std::cout << "(chr-assign: " << var << " '" << value.c << "')" << std::endl;
      break;
    default:
      std::cout << "ERROR" << std::endl;
      break;
  }
}

/* -------------------------------------------------------------------------- */

Declaration::Declaration(std::string nvar, Type ntype):
  var(nvar), type(ntype)
{}

Declaration::~Declaration() {}

void Declaration::display()
{
  std::cout << "(declaration: " << var << " " << type << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

BuildinFunctionCall::BuildinFunctionCall(std::string name, std::string p):
  functionName(name), params(p)
{
}

BuildinFunctionCall::~BuildinFunctionCall() {}

void BuildinFunctionCall::display()
{
  std::cout << "(fncall: " << functionName << " [" << params << "])" << std::endl;
}

/* -------------------------------------------------------------------------- */

Statement::Statement(Block* b): block(b) {}

Statement::~Statement()
{
  delete block;
}

void Statement::display()
{
  block->display();
}

/* -------------------------------------------------------------------------- */

If::If(std::string c, Block* b): Statement(b), condition(c)
{
}

If::~If()
{
}

void If::display()
{
  std::cout << "(if: " << condition << std::endl;
  Statement::display();
  std::cout << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

For::For(std::string v, Block* b): Statement(b), var(v)
{
}

For::For(std::string v, long long be, long long e, long long s, Block* b):
  For(v, b)
{
  begin.i = be;
  end.i = e;
  step.i = s;
  type = NBR;
}

For::For(std::string v, double be, double e, double s, Block* b):
  For(v, b)
{
  begin.f = be;
  end.f = e;
  step.f = s;
  type = FLT;
}

For::~For()
{
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

While::While(std::string c, Block* b): Statement(b), condition(c)
{
}

While::~While()
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
  includes = std::list<Include*>();
  functions = std::list<Function*>();
}

Program::~Program()
{
  for (Include* i : includes)
    delete i;
  for (Function* f : functions)
    delete f;
}

void Program::addInclude(Include *i) {
  includes.push_back(i);
}

void Program::addFunction(Function *f) {
  functions.push_back(f);
}

void Program::display()
{
  for (Include* i : includes)
    i->display();
  for (Function* f : functions)
    f->display();
}

/* -------------------------------------------------------------------------- */

ProgramBuilder::ProgramBuilder()
{
  program = new Program();
}

ProgramBuilder::~ProgramBuilder()
{
  delete program;
}

void ProgramBuilder::display()
{
  program->display();
}

void ProgramBuilder::addInclude(Include *i)
{
  program->addInclude(i);
}

void ProgramBuilder::pushCommand(ASTNode * command)
{
  blocks.back()->addOp(command);
}

// FIXME: unsafe operations
void ProgramBuilder::createBlock()
{
  blocks.push_back(new Block());
}

void ProgramBuilder::createIf()
{
}

/* -------------------------------------------------------------------------- */
