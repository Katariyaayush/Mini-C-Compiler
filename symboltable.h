#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Symbol structure for variables, functions, etc.
typedef struct symrec {
    char *name;          // Identifier name
    char *type;          // Data type: "int", "float", etc.
    int scope_level;     // For future scope-based features
    struct symrec *next; // Linked list for chaining
} symrec;

// Head of the symbol table (linked list)
extern symrec *sym_table;

// Insert a symbol into the symbol table
symrec *putsym(const char *name, const char *type);

// Retrieve a symbol from the table
symrec *getsym(const char *name);

// Print the entire symbol table
void print_sym_table(void);

// Clear/free the symbol table memory
void clear_sym_table(void);

#endif
