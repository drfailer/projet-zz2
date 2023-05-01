#include "preprocessor.hpp"
#include <algorithm>
#include <regex>

void Preprocessor::process(std::string fileName) {
  std::string line;
  std::string includedFileName;
  std::regex  includeStmt("^include .+;$");

  if (currentFile.is_open())
    currentFile.close();
  filesStack.push_back(fileName);
  currentFile.open(fileName);

  while (std::getline(currentFile, line)) {
    if (std::regex_match(line, includeStmt)) {
      includedFileName = line.substr(8, line.length() - 9) + ".prog";
      bool isTreated = std::find(treatedFiles.begin(), treatedFiles.end(),
                                 includedFileName) != treatedFiles.end();
      bool isInStack = std::find(filesStack.begin(), filesStack.end(),
                                 includedFileName) != filesStack.end();
      if (!isTreated && !isInStack) {
        // treat the file
        process(includedFileName);
        currentFile.open(filesStack.back());
      }
    }
    else {
      // put the line in the output file
      outputFile << line << std::endl;
    }
  }
  // when it's done, the file is considered as treated
  treatedFiles.push_back(filesStack.back());
  filesStack.pop_back();
  currentFile.close();
}
