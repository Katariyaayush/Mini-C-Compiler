#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>
#include "parser.tab.h"

#define HASH_TABLE_SIZE 100
#define NUM_TABLES 10

// Forward declare yyerror defined in parser.y
void yyerror(const char *);

// Define the global symbol table list here
typedef struct entry_s
{
    char* lexeme;
    double value;
    int data_type;
    int* parameter_list; // for functions
    int array_dimension;
    int is_constant;
    int num_params;
    struct entry_s* successor;
} entry_t;

typedef struct table_s
{
    entry_t** symbol_table;
    int parent;
} table_t;

table_t symbol_table_list[NUM_TABLES] = {0};

int table_index = 0;
int current_scope = 0;

/* Create a new hash_table. */
entry_t** create_table()
{
    entry_t** hash_table_ptr = NULL;

    if( ( hash_table_ptr = malloc( sizeof( entry_t* ) * HASH_TABLE_SIZE ) ) == NULL )
        return NULL;

    for(int i = 0; i < HASH_TABLE_SIZE; i++ )
    {
        hash_table_ptr[i] = NULL;
    }

    return hash_table_ptr;
}

int create_new_scope()
{
    table_index++;

    symbol_table_list[table_index].symbol_table = create_table();
    symbol_table_list[table_index].parent = current_scope;

    return table_index;
}

int exit_scope()
{
    return symbol_table_list[current_scope].parent;
}

/* Jenkins' hash function */
uint32_t hash( char *lexeme )
{
    size_t i;
    uint32_t hash;

    for ( hash = i = 0; i < strlen(lexeme); ++i ) {
        hash += lexeme[i];
        hash += ( hash << 10 );
        hash ^= ( hash >> 6 );
    }
    hash += ( hash << 3 );
    hash ^= ( hash >> 11 );
    hash += ( hash << 15 );

    return hash % HASH_TABLE_SIZE;
}

entry_t *create_entry( char *lexeme, int value, int data_type )
{
    entry_t *new_entry;

    if( ( new_entry = malloc( sizeof( entry_t ) ) ) == NULL ) {
        return NULL;
    }

    if( ( new_entry->lexeme = strdup( lexeme ) ) == NULL ) {
        free(new_entry);
        return NULL;
    }

    new_entry->value = value;
    new_entry->successor = NULL;
    new_entry->parameter_list = NULL;
    new_entry->array_dimension = -1;
    new_entry->is_constant = 0;
    new_entry->num_params = 0;
    new_entry->data_type = data_type;

    return new_entry;
}

entry_t* search(entry_t** hash_table_ptr, char* lexeme)
{
    uint32_t idx = hash( lexeme );
    entry_t* myentry = hash_table_ptr[idx];

    while( myentry != NULL && strcmp( lexeme, myentry->lexeme ) != 0 )
    {
        myentry = myentry->successor;
    }

    return myentry; // NULL if not found, else pointer to entry
}

entry_t* search_recursive(char* lexeme)
{
    int idx = current_scope;
    entry_t* finder = NULL;

    while(idx != -1)
    {
        finder = search(symbol_table_list[idx].symbol_table, lexeme);

        if(finder != NULL)
            return finder;

        idx = symbol_table_list[idx].parent;
    }

    return NULL;
}

entry_t* insert( entry_t** hash_table_ptr, char* lexeme, int value, int data_type)
{
    entry_t* finder = search( hash_table_ptr, lexeme );
    if( finder != NULL)
    {
        if(finder->is_constant)
            return finder;
        return NULL;
    }

    uint32_t idx = hash( lexeme );
    entry_t* new_entry = create_entry( lexeme, value, data_type );

    if(new_entry == NULL)
    {
        printf("Insert failed. New entry could not be created.");
        exit(1);
    }

    if(hash_table_ptr[idx] == NULL)
    {
        hash_table_ptr[idx] = new_entry;
    }
    else
    {
        new_entry->successor = hash_table_ptr[idx];
        hash_table_ptr[idx] = new_entry;
    }
    return hash_table_ptr[idx];
}

// Helper function to convert token type to string for printing
const char* type_to_string(int type) {
    switch(type) {
        case INT: return "int";
        case FLOAT: return "float";
        default: return "unknown";
    }
}

// Called after a function call to check if param list match
int check_parameter_list(entry_t* entry, int* list, int m)
{
    int* parameter_list = entry->parameter_list;

    if(m != entry->num_params)
    {
        yyerror("Number of parameters and arguments do not match");
        return 0;
    }

    for(int i=0; i<m; i++)
    {
        if(list[i] != parameter_list[i]) {
            yyerror("Parameter and argument types do not match");
            return 0;
        }
    }

    return 1;
}

void fill_parameter_list(entry_t* entry, int* list, int n)
{
    entry->parameter_list = (int *)malloc(n*sizeof(int));
    for(int i=0; i<n; i++)
    {
        entry->parameter_list[i] = list[i];
    }
    entry->num_params = n;
}

void print_dashes(int n)
{
    printf("\n");
    for(int i=0; i< n; i++)
        printf("=");
    printf("\n");
}

void display_symbol_table(entry_t** hash_table_ptr)
{
    print_dashes(100);
    printf(" %-20s %-20s %-20s %-20s %-20s\n", "lexeme", "data-type", "array_dimension", "num_params", "param_list");
    print_dashes(100);

    for(int i=0; i < HASH_TABLE_SIZE; i++)
    {
        entry_t* traverser = hash_table_ptr[i];
        while(traverser != NULL)
        {
            printf(" %-20s %-20s %-20d %-20d", 
                traverser->lexeme, 
                type_to_string(traverser->data_type), 
                traverser->array_dimension, 
                traverser->num_params
            );

            for(int j=0; j < traverser->num_params; j++)
                printf(" %s", type_to_string(traverser->parameter_list[j]));

            printf("\n");

            traverser = traverser->successor;
        }
    }
    print_dashes(100);
}

void display_constant_table(entry_t** hash_table_ptr)
{
    print_dashes(25);
    printf(" %-10s %-10s \n", "lexeme", "data-type");
    print_dashes(25);

    for(int i=0; i < HASH_TABLE_SIZE; i++)
    {
        entry_t* traverser = hash_table_ptr[i];
        while(traverser != NULL)
        {
            printf(" %-10s %-10s \n", traverser->lexeme, type_to_string(traverser->data_type));
            traverser = traverser->successor;
        }
    }
    print_dashes(25);
}

void display_all()
{
    for(int i=0; i<=table_index; i++)
    {
        printf("Scope: %d\n", i);
        display_symbol_table(symbol_table_list[i].symbol_table);
        printf("\n\n");
    }
}
