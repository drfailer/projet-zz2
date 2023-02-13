#include "ContextManager.hpp"
#include <sstream>

std::shared_ptr<Symtable> ContextManager::getScope() const
{
  return currentScope;
}

void ContextManager::enterScope()
{
  std::shared_ptr<Symtable> newScope = std::make_shared<Symtable>(currentScope);
  currentScope->addScope(newScope);
  currentScope = newScope;
}

void ContextManager::leaveScope()
{
  currentScope = currentScope->getFather();
}

