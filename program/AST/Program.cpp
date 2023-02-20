#include "Program.hpp"
#include <memory>

Program::Program()
{
  includes = std::list<std::shared_ptr<Include>>();
  functions = std::list<std::shared_ptr<Function>>();
}

void Program::addInclude(std::shared_ptr<Include> i) {
  includes.push_back(i);
}

void Program::addFunction(std::shared_ptr<Function> f) {
  functions.push_back(f);
}

void Program::display()
{
  for (std::shared_ptr<Include> i : includes)
    i->display();
  for (std::shared_ptr<Function> f : functions)
    f->display();
}

std::list<std::shared_ptr<Include>> Program::getIncludes() const
{
  return includes;
}

std::list<std::shared_ptr<Function>> Program::getFunctions() const
{
  return functions;
}

void Program::compile(std::fstream& fs)
{
  fs << "# generated using ISIMA's transpiler" << std::endl;
  fs << "#!/usr/bin/env python3" << std::endl << std::endl;
  for (std::shared_ptr<Function> function : functions) {
    function->compile(fs, 0);
    fs << std::endl;
  }
  fs << std::endl
     << "if __name__ == '__main__':" << std::endl
     << "\tmain()";
}

