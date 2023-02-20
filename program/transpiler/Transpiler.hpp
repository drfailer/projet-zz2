#ifndef __TRANSPILER__
#define __TRANSPILER__
#include "../AST/AST.hpp"
#include "../AST/Program.hpp"
#include <fstream>

class Transpiler
{
  private:
    Program program;
    std::fstream output;

  public:
    void Transpile(std::string);
    Transpiler(Program);
    ~Transpiler() = default;

  private:
    void transpile(std::shared_ptr<Block>, int);
    void transpile(std::shared_ptr<Value>, int);
    void transpile(std::shared_ptr<Variable>, int);
    void transpile(std::shared_ptr<Assignement>, int);
    void transpile(std::shared_ptr<Declaration>, int);
    void transpile(std::shared_ptr<Funcall>, int);
    void transpile(std::shared_ptr<Function>, int);
    void transpile(std::shared_ptr<If>, int);
    void transpile(std::shared_ptr<For>, int);
    void transpile(std::shared_ptr<While>, int);
    void transpile(std::shared_ptr<AddOP>, int);
    void transpile(std::shared_ptr<MnsOP>, int);
    void transpile(std::shared_ptr<TmsOP>, int);
    void transpile(std::shared_ptr<DivOP>, int);
    void transpile(std::shared_ptr<EqlOP>, int);
    void transpile(std::shared_ptr<SupOP>, int);
    void transpile(std::shared_ptr<InfOP>, int);
    void transpile(std::shared_ptr<SeqOP>, int);
    void transpile(std::shared_ptr<IeqOP>, int);
    void transpile(std::shared_ptr<OrOP>, int);
    void transpile(std::shared_ptr<AndOP>, int);
    void transpile(std::shared_ptr<XorOP>, int);
    void transpile(std::shared_ptr<NotOP>, int);
    void transpile(std::shared_ptr<Print>, int);
    void transpile(std::shared_ptr<Read>, int);
    void transpile(std::shared_ptr<Return>, int);
};

#endif
