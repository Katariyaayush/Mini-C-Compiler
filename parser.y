%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symboltable.h"

void yyerror(const char *s);
int yylex(void);

int semantic_error = 0;
%}

%union {
    int ival;
    float fval;
    char* sval;
    char* type_name;
}

%token <ival> INT_CONST
%token <fval> FLOAT_CONST
%token <sval> ID

%token IF ELSE WHILE RETURN INT FLOAT
%token EQ NE LE GE

%type <type_name> type
%type <type_name> expr simple_expr term factor

%start program

%%

program:
    decl_list
    {
        if (!semantic_error) {
            printf("\nParsing and semantic analysis successful.\n");
            print_sym_table();
        } else {
            printf("\nSemantic errors detected.\n");
        }
    }
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
        if (getsym($2)) {
            printf("Semantic error: Redeclaration of variable '%s'\n", $2);
            semantic_error = 1;
        } else {
            putsym($2, $1);
            printf("Declared variable '%s' of type '%s'\n", $2, $1);
        }
    }
    ;

type:
    INT   { $$ = "int"; }
    | FLOAT { $$ = "float"; }
    ;

func_decl:
    type ID '(' param_list ')' compound_stmt
    {
        printf("Declared function '%s' returning '%s'\n", $2, $1);
    }
    ;

param_list:
    param_list ',' param
    | param
    | /* empty */
    ;

param:
    type ID
    {
        if (getsym($2)) {
            printf("Semantic error: Redeclaration of parameter '%s'\n", $2);
            semantic_error = 1;
        } else {
            putsym($2, $1);
            printf("Parameter '%s' of type '%s'\n", $2, $1);
        }
    }
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
    {
        symrec *sym = getsym($1);
        if (!sym) {
            printf("Semantic error: Undeclared variable '%s'\n", $1);
            semantic_error = 1;
            $$ = NULL;
        } else if ($3 && strcmp(sym->type, $3) != 0) {
            printf("Semantic error: Type mismatch in assignment to '%s'\n", $1);
            semantic_error = 1;
            $$ = NULL;
        } else {
            $$ = sym ? sym->type : NULL;
        }
    }
    | simple_expr
    {
        $$ = $1;
    }
    ;

simple_expr:
    simple_expr '+' term
    {
        if ($1 && $3 && strcmp($1, $3) == 0)
            $$ = $1;
        else {
            printf("Semantic error: Type mismatch in '+' expression\n");
            semantic_error = 1;
            $$ = NULL;
        }
    }
    | simple_expr '-' term
    {
        if ($1 && $3 && strcmp($1, $3) == 0)
            $$ = $1;
        else {
            printf("Semantic error: Type mismatch in '-' expression\n");
            semantic_error = 1;
            $$ = NULL;
        }
    }
    | term
    {
        $$ = $1;
    }
    ;

term:
    term '*' factor
    {
        if ($1 && $3 && strcmp($1, $3) == 0)
            $$ = $1;
        else {
            printf("Semantic error: Type mismatch in '*' expression\n");
            semantic_error = 1;
            $$ = NULL;
        }
    }
    | term '/' factor
    {
        if ($1 && $3 && strcmp($1, $3) == 0)
            $$ = $1;
        else {
            printf("Semantic error: Type mismatch in '/' expression\n");
            semantic_error = 1;
            $$ = NULL;
        }
    }
    | factor
    {
        $$ = $1;
    }
    ;

factor:
    '(' expr ')'
    {
        $$ = $2;
    }
    | ID
    {
        symrec *sym = getsym($1);
        if (!sym) {
            printf("Semantic error: Undeclared variable '%s'\n", $1);
            semantic_error = 1;
            $$ = NULL;
        } else {
            $$ = sym->type;
        }
    }
    | INT_CONST
    {
        $$ = "int";
    }
    | FLOAT_CONST
    {
        $$ = "float";
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

int main() {
    printf("Enter MiniC code below:\n");
    yyparse();
    clear_sym_table();
    return 0;
}
