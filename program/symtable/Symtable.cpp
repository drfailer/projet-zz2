#include "Symtable.hpp"

std::optional<Symbol> Symtable::lookup(std::string name, std::string scope)
{
  // todo
  // std::list<Symbol> lst = table[name];
  std::optional<Symbol> foundSymbol;
  for (Symbol symbol : table[name]) {
    // TODO
  }
  return {};
}

void Symtable::add(std::string name, std::string scope, Type type, Kind kind)
{
  table[name].push_back(Symbol(name, scope, type, kind));
}
