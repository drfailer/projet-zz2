%{
#include "parser.hpp"
#include "lexer.hpp"
#define YY_DECL int interpreter::Scanner::lex(interpreter::Parser::semantic_type *yylval)
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
nbr   { std::cout << "nbr" << std::endl; return Parser::token::NBRT; }
flt   { std::cout << "flt" << std::endl; return Parser::token::FLTT; }
chr   { std::cout << "chr" << std::endl; return Parser::token::CHRT; }
fn    { std::cout << "function" << std::endl; return Parser::token::FN; }
if    { std::cout << "if" << std::endl; return Parser::token::IF; }
else  { std::cout << "else" << std::endl; return Parser::token::ELSE; }
while { std::cout << "while" << std::endl; return Parser::token::WHILE; }
for   { std::cout << "for" << std::endl; return Parser::token::FOR; }
{identifier} { std::cout << "identifier" << std::endl; return Parser::token::IDENTIFIER; }
{int}   { std::cout << "integer" << std::endl; return Parser::token::INT; }
{float} { std::cout << "float" << std::endl; return Parser::token::FLOAT; }
{char} { std::cout << "float" << std::endl; return Parser::token::CHAR; }
{semi} { std::cout << "semi" << std::endl; return Parser::token::SEMI; }
. { std::cout << "other" << std::endl; return Parser::token::ERROR; }
%%

int yyFlexLexer::yylex() {
    throw std::runtime_error("Bad call to yyFlexLexer::yylex()");
}

int main() {
  interpreter::Scanner scanner{ std::cin, std::cerr };
  interpreter::Parser parser{ &scanner };
  parser.parse();
}
