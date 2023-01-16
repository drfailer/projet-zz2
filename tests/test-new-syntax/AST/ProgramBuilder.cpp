#include "ProgramBuilder.hpp"

ProgramBuilder::ProgramBuilder()
{
  program = std::make_shared<Program>();
  blocks = std::list<std::shared_ptr<Block>>();
  funParams = std::list<Variable>();
  funcallParams = std::list<std::list<std::shared_ptr<ASTNode>>>();
}

void ProgramBuilder::display()
{
  program->display();
}

void ProgramBuilder::addInclude(std::shared_ptr<Include> i)
{
  program->addInclude(i);
}

/******************************************************************************/
/*                                   blocks                                   */
/******************************************************************************/

void ProgramBuilder::pushBlock(std::shared_ptr<ASTNode> command)
{
  blocks.back()->addOp(command);
}

// FIXME: unsafe operations
void ProgramBuilder::createBlock()
{
  blocks.push_back(std::make_shared<Block>());
}

/******************************************************************************/
/*                                 statements                                 */
/******************************************************************************/

/**
 * @brief take the last block, add it to a new If and add the new If to the
 * parent block.
 */
void ProgramBuilder::createIf(std::shared_ptr<ASTNode> condition)
{
  std::shared_ptr<If> newif = std::make_shared<If>(condition, blocks.back());
  blocks.pop_back();
  blocks.back()->addOp(newif);
}

/**
 * @brief take the last block, add it to a new For and add the new For to the
 * parent block.
 */
void ProgramBuilder::createFor(Variable v, std::shared_ptr<ASTNode> begin,
    std::shared_ptr<ASTNode> end, std::shared_ptr<ASTNode> step)
{
  std::shared_ptr<For> newfor = std::make_shared<For>(v, begin, end, step, blocks.back());
  blocks.pop_back();
  blocks.back()->addOp(newfor);
}

/**
 * @brief take the last block, add it to a new While and add the new If to the
 * parent block.
 */
void ProgramBuilder::createWhile(std::shared_ptr<ASTNode> condition)
{
  std::shared_ptr<While> newwhile = std::make_shared<While>(condition, blocks.back());
  blocks.pop_back();
  blocks.back()->addOp(newwhile);
}


/******************************************************************************/
/*                                  funcalls                                  */
/******************************************************************************/

std::shared_ptr<ASTNode> ProgramBuilder::createFuncall()
{
  std::shared_ptr<Funcall> newFuncall =
    std::make_shared<Funcall>(funcallIds.back(), funcallParams.back());
  funcallParams.pop_back();
  funcallIds.pop_back();
  return newFuncall;
}

void ProgramBuilder::newFuncall(std::string name)
{
  funcallIds.push_back(name);
  funcallParams.push_back(std::list<std::shared_ptr<ASTNode>>());
}

void ProgramBuilder::createFunction()
{
  std::shared_ptr<Function> newfun =
    std::make_shared<Function>(lastFunctionName, funParams, VOID, blocks.back());
  blocks.pop_back(); // NOTE: should be empty at this point
                     // TODO: throw error if not empty
  program->addFunction(newfun);
  funcallParams.clear();
}

void ProgramBuilder::pushFuncallParam(std::shared_ptr<ASTNode> newParam)
{
  funcallParams.back().push_back(newParam);
}

/******************************************************************************/
/*                                 functions                                  */
/******************************************************************************/

void ProgramBuilder::newFunctionName(std::string name)
{
  lastFunctionName = name;
}

void ProgramBuilder::pushFunctionParam(Variable newParam)
{
  funParams.push_back(newParam);
}
