#ifndef __PROGRAMBUILDER__
#define __PROGRAMBUILDER__
#include "Program.hpp"

// TODO: cette classe doit être utilisée pour construire l'abre avec le parser.
// elle doit contenir des piles tampons pour pouvoir ajouter les opération, les
// block, les statements, ... quand le parser les trouves. Les éléments en haut
// de l'arbre sont construit en derniers ! => on doit pouvoir créer une liste de
// commandes, qu'on peut combiner dans un block, block qu'on peut ajouter à un
// statement qui sera lui aussi ajouter à une liste pour pouvoir créer une
// fonction ou être ajouter à un autre block.
class ProgramBuilder
{
  private:
    std::shared_ptr<Program> program;         // current program
    std::list<std::shared_ptr<Block>> blocks; // stack of blocks (the last
                                              // element is the current block)
    std::list<Variable> funParams;        // parameters of the last function
    std::list<std::list<std::shared_ptr<ASTNode>>> funcallParams;    // parameters of the last funcall
    // NOTE: maybe move this to the .y file as global variable:
    std::string lastFunctionName;      // the name of the last function parsed
    std::list<std::string> funcallIds;

  public:
    void display();
    void pushBlock(std::shared_ptr<ASTNode>);
    void pushFuncallParam(std::shared_ptr<ASTNode>);
    void pushFunctionParam(Variable);
    void newFuncall(std::string);
    void newFunctionName(std::string);
    void createBlock();
    void createIf(std::shared_ptr<ASTNode>);
    void createFor(Variable, std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>,
        std::shared_ptr<ASTNode>);
    void createWhile(std::shared_ptr<ASTNode>);
    std::shared_ptr<ASTNode> createFuncall();
    void createFunction(); // TODO: add the return type
    void addInclude(std::shared_ptr<Include>);
    ProgramBuilder();
};


#endif
