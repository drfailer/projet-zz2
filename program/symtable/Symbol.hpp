#ifndef __SYMBOL__
#define __SYMBOL__
#include <iostream>
#include "../AST/Types.hpp"

enum Kind
{
  FUN_PARAM,
  LOCAL_VAR,
  FUNCTION
};

class Symbol
{
  private:
    std::string name;
    Type type;
    Kind kind;

  public:
    Kind getKind() const;
    Type getType() const;
    std::string getName() const;
    Symbol(std::string name, Type type, Kind kind);
    Symbol() = default;
    ~Symbol() = default;
};

#endif
