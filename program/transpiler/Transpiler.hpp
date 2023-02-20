#ifndef __TRANSPILER__
#define __TRANSPILER__
#include "../AST/AST.hpp"
#include "../AST/Program.hpp"

class Transpiler
{
  private:
    Program program;

  public:
    Transpiler(Program);
    ~Transpiler() = default;
};

#endif


