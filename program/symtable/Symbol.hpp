#ifndef __SYMBOL__
#define __SYMBOL__
#include <iostream>

class Symbol
{
  private:
    std::string name;
    std::string scope; // fonction/if/for/

  public:
    Symbol() = default;
    ~Symbol() = default;
};

#endif
