%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>

%}

%%

[ \t\r\n]+              ;  /* skip whitespace */

"int"                   { return INT; }
"float"                 { return FLOAT; }
"if"                    { return IF; }
"else"                  { return ELSE; }
"while"                 { return WHILE; }
"return"                { return RETURN; }

[0-9]+"."[0-9]+         { yylval.fval = atof(yytext); return FLOAT_CONST; }
[0-9]+                  { yylval.ival = atoi(yytext); return INT_CONST; }

[a-zA-Z_][a-zA-Z0-9_]*  { yylval.sval = strdup(yytext); return ID; }

";"                     { return ';'; }
","                     { return ','; }
"("                     { return '('; }
")"                     { return ')'; }
"{"                     { return '{'; }
"}"                     { return '}'; }
"+"                     { return '+'; }
"-"                     { return '-'; }
"*"                     { return '*'; }
"/"                     { return '/'; }
"="                     { return '='; }

.                       { printf("Unknown character: %s\n", yytext); }

%%
