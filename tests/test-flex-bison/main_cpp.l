%{
#include "parser.hpp"
#include "lexer.hpp"
#define YY_DECL int Scanner::lex(yy::Parser::semantic_type *yylval)
void showError();
%}

%option c++ interactive noyywrap noyylineno nodefault outfile="lexer.cpp"

alpha [a-z1-Z]
digit [0-9]
int [+-]?{digit}+
float [+-]?{digit}+\.{digit}+
char '{alpha}'
identifier [a-z]({alpha}|{digit})+
semi ;

%%
nbr   { std::cout << "nbr" << std::endl; return yy::Parser::token::NBRT; }
flt   { std::cout << "flt" << std::endl; return yy::Parser::token::FLTT; }
chr   { std::cout << "chr" << std::endl; return yy::Parser::token::CHRT; }
fn    { std::cout << "function" << std::endl; return yy::Parser::token::FN; }
if    { std::cout << "if" << std::endl; return yy::Parser::token::IF; }
else  { std::cout << "else" << std::endl; return yy::Parser::token::ELSE; }
while { std::cout << "while" << std::endl; return yy::Parser::token::WHILE; }
for   { std::cout << "for" << std::endl; return yy::Parser::token::FOR; }
{identifier} { std::cout << "identifier" << std::endl; return yy::Parser::token::IDENTIFIER; }
{int}   { std::cout << "integer" << std::endl; return yy::Parser::token::INT; }
{float} { std::cout << "float" << std::endl; return yy::Parser::token::FLOAT; }
{char} { std::cout << "float" << std::endl; return yy::Parser::token::CHAR; }
{semi} { std::cout << "semi" << std::endl; return yy::Parser::token::SEMI; }
. { std::cout << "other" << std::endl; return yy::Parser::token::ERROR; }
%%

int yyFlexLexer::yylex() {
    throw std::runtime_error("Bad call to yyFlexLexer::yylex()");
}

int main() {
  Scanner scanner{ std::cin, std::cerr };
  yy::Parser parser{ &scanner };
  parser.parse();
}
