%{

#include "compil.tab.h"
#include <stdlib.h>
%}

white [ \t]+
digit [0-9]
integer {digit}+
real {integer}("."{integer})?

%%

{white} { }
{real} { yylval.value=atof(yytext); 
 return NUMBER;
}

"moyenne" return MOYENNE;
"somme" return SOMME;
"produit" return PRODUCT;
"variance" return VARIANCE;
"ecart-type" return ECARTTYPE ;
, return COMMA;
"+" return PLUS;
"-" return MINUS;
"*" return TIMES;
"/" return DIVIDE;
"^" return POWER;
"(" return LEFT;
")" return RIGHT;
"\n" return END;
"exit" return EXIT;

%%

int yywrap(void){return 1;}