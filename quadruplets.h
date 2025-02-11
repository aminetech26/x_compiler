#ifndef QUAD_H
#define QUAD_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct quadruplet {
    char op[20];    // Opérateur
    char opr1[20];  // Premier opérande 
    char opr2[20];  // Deuxième opérande
    char res[20];   // Résultat
} quadruplet;

typedef struct quad_list {
    quadruplet* quads;
    int size;
    int capacity;
} quad_list;

// Global quad list
extern quad_list* global_quad_list;
extern int temp_var_counter;

// Function declarations
quad_list* init_quad_list();
void add_quad(quad_list* list, char* op, char* opr1, char* opr2, char* res);
void update_quad(quad_list* list, int index, char* op, char* opr1, char* opr2, char* res);
char* new_temp();
void print_quads(quad_list* list);
void free_quad_list(quad_list* list);

#endif