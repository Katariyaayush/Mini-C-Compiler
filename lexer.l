%{
#include "y.tab.h"
#include <stdlib.h>
#include <string.h>

void yyerror(const char *);
%}

%%
"if"            return IF;
"else"          return ELSE;
"while"         return WHILE;
"return"        return RETURN;
"int"           return INT;
"float"         return FLOAT;

[0-9]+          { yylval.ival = atoi(yytext); return INT_CONST; }
[0-9]+"."[0-9]+ { yylval.fval = atof(yytext); return FLOAT_CONST; }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.sval = strdup(yytext);
    return ID;
}

"=="            return EQ;
"!="            return NE;
"<="            return LE;
">="            return GE;
"<"             return '<';
">"             return '>';

"+"             return '+';
"-"             return '-';
"*"             return '*';
"/"             return '/';

"="             return '=';

";"             return ';';
","             return ',';
"("             return '(';
")"             return ')';
"{"             return '{';
"}"             return '}';

[ \t\n]+        ;  // skip whitespace

.               { printf("Unknown character: %s\n", yytext); }

%%
