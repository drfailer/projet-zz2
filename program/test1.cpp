#include "AST.hpp"

int main(void)
{
  Declaration* d = new Declaration{"a", NBR};
  Assignement* a = new Assignement("a", (long long) 0);
  BuildinFunctionCall* fc = new BuildinFunctionCall("add", "3, 4");
  Block *b = new Block();
  Block *bi = new Block();
  bi->addOp(new Assignement("b", 'b'));
  bi->addOp(new BuildinFunctionCall("mns", "a, 1"));
  If *i = new If("equal(a, b)", bi);
  Block *bf = new Block();
  bf->addOp(new BuildinFunctionCall("inc", "a"));
  For *f = new For("a", 1.2, 10.0, 1.0, bf);
  Block *bw = new Block();
  bw->addOp(new Assignement("c", 'b'));
  bw->addOp(new BuildinFunctionCall("tms", "a, 3"));
  bw->addOp(f);
  While* w = new While("true", bw);
  b->addOp(d);
  b->addOp(a);
  b->addOp(fc);
  b->addOp(w);
  b->addOp(i);
  Function *ff = new Function("main", b);
  Include *inc = new Include("test");
  Program p {};
  p.addInclude(inc);
  p.addFunction(ff);
  p.display();
  return 0;
}
