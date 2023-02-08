#ifndef __SYMTABLE__
#define __SYMTABLE__
#include <unordered_map>
#include <iostream>

class Symtable
{
  private:
    std::unordered_map<std::string, Symbol> tabel;

  public:
    Symtable() = default;
    ~Symtable() = default;
};


#endif
