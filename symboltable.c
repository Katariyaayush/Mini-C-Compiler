#include "symboltable.h"

symrec *sym_table = NULL;

symrec *putsym(const char *name, const char *type) {
    symrec *ptr = (symrec *) malloc(sizeof(symrec));
    ptr->name = strdup(name);
    ptr->type = strdup(type);
    ptr->scope_level = 0; // Default: global scope
    ptr->next = sym_table;
    sym_table = ptr;
    return ptr;
}

symrec *getsym(const char *name) {
    symrec *ptr = sym_table;
    while (ptr != NULL) {
        if (strcmp(ptr->name, name) == 0) return ptr;
        ptr = ptr->next;
    }
    return NULL;
}

void print_sym_table() {
    printf("\nSymbol Table:\n");
    symrec *ptr = sym_table;
    while (ptr != NULL) {
        printf("Name: %s, Type: %s, Scope: %d\n", ptr->name, ptr->type, ptr->scope_level);
        ptr = ptr->next;
    }
}

void clear_sym_table() {
    symrec *ptr = sym_table;
    while (ptr != NULL) {
        symrec *temp = ptr;
        ptr = ptr->next;
        free(temp->name);
        free(temp->type);
        free(temp);
    }
    sym_table = NULL;
}
