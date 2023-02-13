#include "Symtable.hpp"

Symtable::Symtable():
  table(std::unordered_map<std::string, std::list<Symbol>>())
{
}

/**
 * @brief  Return if `scope` is reachable from the `current` scope.
 *
 * @param  current  Current scope.
 * @param  scope    Scope to test.
 *
 * @return  true if `scope` is reachable.
 */
bool isReachable(std::string current, std::string scope)
{
  bool reachable = true;
  for (int i = 0; i < scope.length() && reachable; ++i) {
    if (current[i] != scope[i])
      reachable = false;
  }
  return reachable;
}

/**
 * @brief  Lookup for a symbol in the symtable.
 *
 * @param  name  Name of the symbol to look up of for.
 * @param  scope  Current scope where the methode is called.
 *
 * NOTE: may be better if the symtable can interact with the contextManager
 *       directly
 *
 * @return  Optional symbol which is the symbol corresponding to `name` in the
 *          current scope.
 */
std::optional<Symbol> Symtable::lookup(std::string name, std::string scope)
{
  // todo
  // std::list<Symbol> lst = table[name];
  for (Symbol symbol : table[name]) {
    if (isReachable(scope, symbol.getScope())) {
      return std::optional<Symbol>{ symbol };
    }
  }
  return {};
}

/**
 * @brief  Add a new Symbol to the symtable.
 *
 * @param  name   Name of the new symbol.
 * @param  scope  Scope where the symbol has been declared.
 * @param  type   Type of the new symbol.
 * @param  kind   Kind of the new symbol (param, local variable, ...)
 */
void Symtable::add(std::string name, std::string scope, Type type, Kind kind)
{
  table[name].push_front(Symbol(name, scope, type, kind));
}
