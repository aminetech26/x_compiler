#include "quadruplets.h"

quad_list* global_quad_list = NULL;
int temp_var_counter = 0;

quad_list* init_quad_list() {
    quad_list* list = (quad_list*)malloc(sizeof(quad_list));
    list->capacity = 100;
    list->size = 0;
    list->quads = (quadruplet*)malloc(list->capacity * sizeof(quadruplet));
    return list;
}

void add_quad(quad_list* list, char* op, char* opr1, char* opr2, char* res) {
    if (list->size >= list->capacity) {
        list->capacity *= 2;
        list->quads = realloc(list->quads, list->capacity * sizeof(quadruplet));
    }
    
    strncpy(list->quads[list->size].op, op, 19);
    strncpy(list->quads[list->size].opr1, opr1, 19);
    strncpy(list->quads[list->size].opr2, opr2, 19);
    strncpy(list->quads[list->size].res, res, 19);
    
    list->size++;
}

void update_quad(quad_list* list, int index, char* op, char* opr1, char* opr2, char* res) {
    strncpy(list->quads[index].op, op, 19);
    strncpy(list->quads[index].opr1, opr1, 19);
    strncpy(list->quads[index].opr2, opr2, 19);
    strncpy(list->quads[index].res, res, 19);
}

char* new_temp() {
    char* temp = malloc(20);
    sprintf(temp, "t%d", temp_var_counter++);
    return temp;
}

void print_quads(quad_list* list) {
    printf("\n=== Quadruplets Generated ===\n");
    for (int i = 0; i < list->size; i++) {
        printf("%d: (%s, %s, %s, %s)\n", 
            i,
            list->quads[i].op,
            list->quads[i].opr1,
            list->quads[i].opr2,
            list->quads[i].res);
    }
}

void free_quad_list(quad_list* list) {
    free(list->quads);
    free(list);
}