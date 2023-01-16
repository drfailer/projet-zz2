#ifndef __PROGRAM__
#define __PROGRAM__
#include "AST.hpp"

/******************************************************************************/
/*                                  program                                   */
/******************************************************************************/

class Program
{
  private:
    std::list<std::shared_ptr<Include>> includes;
    std::list<std::shared_ptr<Function>> functions;

  public:
    Program();
    void addInclude(std::shared_ptr<Include>);
    void addFunction(std::shared_ptr<Function>);
    void display();
};

#endif
