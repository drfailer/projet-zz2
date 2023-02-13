#include "Symbol.hpp"

Symbol::Symbol(std::string name, Type type, Kind kind):
  name(name), type(type), kind(kind)
{
}

std::string Symbol::getName() const
{
  return name;
}

Type Symbol::getType() const
{
  return type;
}

Kind Symbol::getKind() const
{
  return kind;
}
