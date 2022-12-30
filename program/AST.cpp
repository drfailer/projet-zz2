#include "AST.hpp"
#include <iostream>
#include <ostream>

// TODO: create multiple files

ASTNode::~ASTNode() {}

/* -------------------------------------------------------------------------- */

void Function::afficher() {
  std::cout << "(fun: " << id << std::endl;
  instructions->afficher();
  std::cout << ")" << std::endl;
}

Function::Function(std::string nid, Block* ninstructions):
  id(nid),
  instructions(ninstructions)
{
}

Function::~Function()
{
  delete instructions;
}

/* -------------------------------------------------------------------------- */

Block::Block()
{
  operations = std::list<ASTNode*>();
}

Block::~Block()
{
  for (ASTNode* o : operations)
    delete o;
}

void Block::ajoutOp(ASTNode* operation)
{
  operations.push_back(operation);
}

void Block::afficher()
{
  std::cout << "  (block:" << std::endl;
  for (ASTNode* o: operations) {
    std::cout << "    ";
    o->afficher();
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

void Assignement::afficher()
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

void Declaration::afficher()
{
  std::cout << "(declaration: " << var << " " << type << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

int main(void)
{
  Declaration* d = new Declaration{"a", NBR};
  Assignement* a = new Assignement("a", (long long) 0);
  Block *b = new Block();
  b->ajoutOp(d);
  b->ajoutOp(a);
  Function *f = new Function("main", b);
  f->afficher();

  delete f;
  return 0;
}
