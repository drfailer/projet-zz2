#ifndef PREPROCESSOR_HPP
#define PREPROCESSOR_HPP
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

class Preprocessor {
public:
  void process(std::string fileName);
  Preprocessor(std::string outputFileName)
      : outputFile(std::ofstream(outputFileName)),
        currentFile(std::ifstream()) {}
  ~Preprocessor() = default;

private:
  std::vector<std::string> treatedFiles;
  std::vector<std::string> filesStack;
  std::ofstream            outputFile;
  std::ifstream            currentFile;
};

#endif
