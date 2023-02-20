#include "Transpiler.hpp"

Transpiler::Transpiler(Program program): program(program)
{
}

void Transpiler::Transpile(std::string filename)
{
  output = std::fstream(filename);
  // TODO: shebang
  for (std::shared_ptr<Function> function : program.getFunctions()) {
    transpile(function, 0);
  }
  // TODO:
  // if __name__ == '__main__':
  //    main()
}

void Transpiler::transpile(std::shared_ptr<Block> block, int lvl)
{
  for (std::shared_ptr<ASTNode> op : block->getOperations()) {
    transpile(op, lvl + 1);
  }
}
