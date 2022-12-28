#include "AST.hpp"
#include <iostream>

// TODO: create multiple files

/* -------------------------------------------------------------------------- */

void Function::afficher() {
  std::cout << "(fun: " << id << std::endl;
  instructions.afficher();
  std::cout << ")" << std::endl;
}

Function::Function(std::string nid, Block ninstructions):
  id(nid),
  instructions(ninstructions)
{
}

/* -------------------------------------------------------------------------- */

Block::Block()
{
  operations = std::list<Node>();
}

void Block::ajoutOp(Node operation)
{
  operations.push_back(operation);
}

void Block::afficher()
{
  std::cout << "(block:" << std::endl;
  for (Node o: operations) {
    std::cout << "\t";
    o.afficher();
  }
  std::cout << ")" << std::endl;
}

/* -------------------------------------------------------------------------- */

Assignement::Assignement(std::string nvar, type_t v, Type t):
  var(nvar), value(v), type(t)
{
}

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

int main(void)
{
  std::cout << "Hello, World!" << std::endl;
  return 0;
}
