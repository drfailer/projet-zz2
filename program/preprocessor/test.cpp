#include "preprocessor.hpp"

int main(int, char**)
{
  Preprocessor p("result.prog");
  p.process("./test/main.prog");
  return 0;
}
