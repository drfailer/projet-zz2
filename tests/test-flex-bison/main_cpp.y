%{
#include <iostream>
%}
%language "c++"

%define api.value.type variant
%define api.token.constructor

%token NBR_T FLT_T CHR_T
%token ERROR
%token <std::string> IDENTIFIER
%token <int> NBR
%token <double> FLT


%%
program:
  commands
;

commands:
  | command ';' commands

command:
  declaration
;

type:
  NBR_T | FLT_T | CHR_T
;

value:
  NBR | FLT
;

declaration:
  type IDENTIFIER ';'
  | type IDENTIFIER  '=' value ';'
;
%%

namespace yy
{
  // Report an error to the user.
  auto parser::error (const std::string& msg) -> void
  {
    std::cerr << msg << '\n';
  }
}

int main()
{
    yy::parser parse;
    return parse();
}
