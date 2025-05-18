%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *);
int yylex(void);

typedef struct symrec {
    char *name;
    char *type; // "int" or "float"
    struct symrec *next;
} symrec;

symrec *sym_table = NULL;

symrec *putsym(char *name, char *type);
symrec *getsym(char *name);
void print_sym_table();

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
%type <type_name> expr
%type <type_name> simple_expr term factor

%start program

%%

program:
    decl_list
    {
        if (!semantic_error) {
            printf("\nParsing and semantic analysis successful!\n");
            print_sym_table();
        } else {
            printf("\nSemantic errors found.\n");
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
        if (getsym($2) != NULL) {
            printf("Semantic error: Redeclaration of variable '%s'\n", $2);
            semantic_error = 1;
        } else {
            putsym($2, $1);
            printf("Declared variable '%s' of type '%s'\n", $2, $1);
        }
    }
    ;

type:
    INT { $$ = "int"; }
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
        if (getsym($2) != NULL) {
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
        } else if ($3 == NULL) {
            $$ = NULL;
        } else if (strcmp(sym->type, $3) != 0) {
            printf("Semantic error: Type mismatch in assignment to '%s'\n", $1);
            semantic_error = 1;
            $$ = NULL;
        } else {
            $$ = sym->type;
        }
    }
    | simple_expr
    ;

simple_expr:
    simple_expr '+' term
    {
        if ($1 && $3) {
            if (strcmp($1, $3) == 0)
                $$ = $1;
            else {
                printf("Semantic error: Type mismatch in '+' operation\n");
                semantic_error = 1;
                $$ = NULL;
            }
        } else {
            $$ = NULL;
        }
    }
    | simple_expr '-' term
    {
        if ($1 && $3) {
            if (strcmp($1, $3) == 0)
                $$ = $1;
            else {
                printf("Semantic error: Type mismatch in '-' operation\n");
                semantic_error = 1;
                $$ = NULL;
            }
        } else {
            $$ = NULL;
        }
    }
    | term
    ;

term:
    term '*' factor
    {
        if ($1 && $3) {
            if (strcmp($1, $3) == 0)
                $$ = $1;
            else {
                printf("Semantic error: Type mismatch in '*' operation\n");
                semantic_error = 1;
                $$ = NULL;
            }
        } else {
            $$ = NULL;
        }
    }
    | term '/' factor
    {
        if ($1 && $3) {
            if (strcmp($1, $3) == 0)
                $$ = $1;
            else {
                printf("Semantic error: Type mismatch in '/' operation\n");
                semantic_error = 1;
                $$ = NULL;
            }
        } else {
            $$ = NULL;
        }
    }
    | factor
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

symrec *putsym(char *name, char *type) {
    symrec *ptr = (symrec *) malloc(sizeof(symrec));
    ptr->name = strdup(name);
    ptr->type = strdup(type);
    ptr->next = sym_table;
    sym_table = ptr;
    return ptr;
}

symrec *getsym(char *name) {
    symrec *ptr = sym_table;
    while (ptr != NULL) {
        if (strcmp(ptr->name, name) == 0)
            return ptr;
        ptr = ptr->next;
    }
    return NULL;
}

void print_sym_table() {
    printf("\nSymbol Table:\n");
    symrec *ptr = sym_table;
    while (ptr != NULL) {
        printf("Name: %s, Type: %s\n", ptr->name, ptr->type);
        ptr = ptr->next;
    }
}

int main() {
    printf("Enter MiniC code:\n");
    yyparse();
    return 0;
}
