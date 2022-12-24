%{
#include "main_cpp.tab.hh"
void showError();
%}

%%
nbr { return parser::make_NBR_T(loc); }
flt { return parser::make_FLT_T(loc); }
chr { return parser::make_CHR_T(loc); }
. { return parser::make_ERROR(loc); }
%%

void showError(){
    printf("Other input");
}

int yywrap(){
    return 1;
}

/* "fn" { return FN; } */
/* "if" { return IF; } */
/* "else" { return ELSE; } */
/* "while" { return WHILE; } */
/* "for" { return FOR; } */
/* [a-z]([a-zA-Z0-9])+ { strcpy(yylval.id, yytext); return IDENTIFIER; } */
/* ([0-9])+ { yylval.nbr = atoi(yytext); return NBR; } */
/* ([0-9])+'.'([0-9])+ { yylval.flt = atof(yytext); return FLT; } */
