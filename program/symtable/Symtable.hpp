#ifndef __SYMTABLE__
#define __SYMTABLE__
#include <iostream>
#include <unordered_map>
#include <list>
#include <optional>
#include "Symbol.hpp"

class Symtable
{
  private:
    std::unordered_map<std::string, std::list<Symbol>> table;

  public:
    std::optional<Symbol> lookup(std::string name, std::string scope);
    void add(std::string name, std::string scope, Type type, Kind kind);
    Symtable();
    ~Symtable() = default;
};

#endif
