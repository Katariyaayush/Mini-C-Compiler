%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *);
int yylex(void);
%}

%union {
    int ival;
    float fval;
    char* sval;
}

%token <ival> INT_CONST
%token <fval> FLOAT_CONST
%token <sval> ID

%token IF ELSE WHILE RETURN INT FLOAT
%token EQ NE LE GE

%type <ival> type

%start program

%%

program:
    decl_list
    ;

decl_list:
    decl_list decl
    | /* empty */
    ;

decl:
    var_decl
    | func_decl
    ;

var_decl:
    type ID ';'
    {
        printf("Variable declaration: %s of type %s\n", $2, $1==INT?"int":"float");
    }
    ;

type:
    INT { $$ = INT; }
    | FLOAT { $$ = FLOAT; }
    ;

func_decl:
    type ID '(' param_list ')' compound_stmt
    {
        printf("Function declaration: %s returns %s\n", $2, $1==INT?"int":"float");
    }
    ;

param_list:
    param_list ',' param
    | param
    | /* empty */
    ;

param:
    type ID
    ;

compound_stmt:
    '{' decl_list stmt_list '}'
    ;

stmt_list:
    stmt_list stmt
    | /* empty */
    ;

stmt:
    expr_stmt
    | compound_stmt
    | selection_stmt
    | iteration_stmt
    | return_stmt
    | var_decl     /* allow variable declarations inside compound statements */
    ;

expr_stmt:
    expr ';'
    | ';'
    ;

selection_stmt:
    IF '(' expr ')' stmt
    | IF '(' expr ')' stmt ELSE stmt
    ;

iteration_stmt:
    WHILE '(' expr ')' stmt
    ;

return_stmt:
    RETURN expr ';'
    ;

expr:
    ID '=' expr
    | simple_expr
    ;

simple_expr:
    simple_expr '+' term
    | simple_expr '-' term
    | term
    ;

term:
    term '*' factor
    | term '/' factor
    | factor
    ;

factor:
      '(' type ')' factor         /* cast */
    | '(' expr ')'               /* parentheses */
    | ID '(' arg_list ')'        /* function call */
    | ID
    | INT_CONST
    | FLOAT_CONST
    ;

arg_list:
      arg_list ',' expr
    | expr
    | /* empty */
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

int main() {
    printf("Enter MiniC code:\n");
    yyparse();
    return 0;
}
