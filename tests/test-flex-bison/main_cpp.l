%{
#include "parser.hpp"
#include "lexer.hpp"
#define YY_DECL int interpreter::Scanner::lex(interpreter::Parser::semantic_type *yylval)
#define AFFICHE(A) std::cout << A << std::endl
%}

%option c++ interactive noyywrap noyylineno nodefault outfile="lexer.cpp"

alpha [a-zA-Z]
digit [0-9]
int [+-]?{digit}+
float [+-]?{digit}+\.{digit}+
char '{alpha}'
identifier [a-z]({alpha}|{digit})*
semi ;
comma ,
equal =
blanks [\S\s \t\n]
ddot \.\.

%%
nbr          { AFFICHE("L_nbrt"); return Parser::token::NBRT; }
flt          { AFFICHE("L_fltt"); return Parser::token::FLTT; }
chr          { AFFICHE("L_chrt"); return Parser::token::CHRT; }
fn           { AFFICHE("L_fn"); return Parser::token::FN; }
if           { AFFICHE("L_if"); return Parser::token::IF; }
else         { AFFICHE("L_else"); return Parser::token::ELSE; }
while        { AFFICHE("L_while"); return Parser::token::WHILE; }
for          { AFFICHE("L_for"); return Parser::token::FOR; }
print        { AFFICHE("L_print"); return Parser::token::PRINT; }
read         { AFFICHE("L_read"); return Parser::token::READ; }
add          { AFFICHE("L_add"); return Parser::token::ADD; }
mns          { AFFICHE("L_mns"); return Parser::token::MNS; }
tms          { AFFICHE("L_tms"); return Parser::token::TMS; }
div          { AFFICHE("L_div"); return Parser::token::DIV; }
include      { AFFICHE("L_include"); return Parser::token::INCLUDE; }
{identifier} { AFFICHE("L_id"); /*yylval->build(yytext);*/ return Parser::token::IDENTIFIER; }
{int}        { AFFICHE("L_int"); return Parser::token::INT; }
{float}      { AFFICHE("L_float"); return Parser::token::FLOAT; }
{char}       { AFFICHE("L_char"); return Parser::token::CHAR; }
{semi}       { AFFICHE("L_semi"); return Parser::token::SEMI; }
{comma}      { AFFICHE("L_comma"); return Parser::token::COMMA; }
{equal}      { AFFICHE("L_equal"); return Parser::token::EQUAL; }
{ddot}       { AFFICHE("L_ddot"); return Parser::token::DDOT; }
{blanks}
.            { return yytext[0]; }
%%

int yyFlexLexer::yylex() {
    throw std::runtime_error("Bad call to yyFlexLexer::yylex()");
}
