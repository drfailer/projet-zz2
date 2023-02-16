#include "Program.hpp"

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
