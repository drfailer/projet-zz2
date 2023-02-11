#include "Symbol.hpp"

Symbol::Symbol(std::string name, std::string scope, Type type, Kind kind):
  name(name), scope(scope), type(type), kind(kind)
{
}

std::string Symbol::getName() const
{
  return name;
}

std::string Symbol::getScope() const
{
  return scope;
}

Type Symbol::getType() const
{
  return type;
}

Kind Symbol::getKind() const
{
  return kind;
}
