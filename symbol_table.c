#include "symbol_table.h"


SymbolTableEntry* allocSymbolTable() {
    SymbolTableEntry* newTable = malloc(MAX_SYMBOLS * sizeof(SymbolTableEntry));
    if (newTable == NULL) {
        fprintf(stderr, "Error: Symbol table allocation failed.\n");
        exit(EXIT_FAILURE);
    }
    memset(newTable, 0, MAX_SYMBOLS * sizeof(SymbolTableEntry)); // Initialize to zero
    return newTable;
}


SymbolTableEntry* insertEntry(
    SymbolTableEntry* symbolTable,
    int* tableSize,
    char* name,
    char* type,
    char* value,
    int line,
    int scope,
    int isArray,
    int arraySize,
    int isStruct,
    char* parentStruct
) {
    if (name == NULL || type == NULL || value == NULL) {
        fprintf(stderr, "Error: Invalid input parameters.\n");
        return NULL;
    }
    for (int i = 0; i < *tableSize; i++) {
        if (strcmp(symbolTable[i].name, name) == 0 && symbolTable[i].scope == scope) {
            fprintf(stderr, "Error: Symbol %s already exists in the same scope.\n", name);
            return &symbolTable[i];
        }
    }
    if (*tableSize >= MAX_SYMBOLS) {
        fprintf(stderr, "Error: Symbol table is full.\n");
        return NULL;
    }
    strncpy(symbolTable[*tableSize].name, name, MAX_NAME_LENGTH - 1);
    symbolTable[*tableSize].name[MAX_NAME_LENGTH - 1] = '\0';


    strncpy(symbolTable[*tableSize].type, type, MAX_TYPE_LENGTH - 1);
    symbolTable[*tableSize].type[MAX_TYPE_LENGTH - 1] = '\0';


    strncpy(symbolTable[*tableSize].value, value, MAX_VALUE_LENGTH - 1);
    symbolTable[*tableSize].value[MAX_VALUE_LENGTH - 1] = '\0';


    symbolTable[*tableSize].line = line;
    symbolTable[*tableSize].scope = scope;
    symbolTable[*tableSize].isArray = isArray;
    symbolTable[*tableSize].arraySize = isArray ? arraySize : 0;
    symbolTable[*tableSize].isStruct = isStruct;


    if (isStruct && parentStruct != NULL) {
        strncpy(symbolTable[*tableSize].parentStruct, parentStruct, MAX_NAME_LENGTH - 1);
        symbolTable[*tableSize].parentStruct[MAX_NAME_LENGTH - 1] = '\0';
    } else {
        symbolTable[*tableSize].parentStruct[0] = '\0';
    }


    (*tableSize)++;
    return &symbolTable[*tableSize - 1];
}


SymbolTableEntry* searchSymbol(SymbolTableEntry* symbolTable, int tableSize, char* name) {
    if (name == NULL) return NULL;
   
    for (int i = 0; i < tableSize; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return &symbolTable[i];
        }
    }
    return NULL;
}


void updateEntry(SymbolTableEntry* symbolTable, int tableSize, char* name, int scope, char* value, char* parentStruct) {
    for (int i = 0; i < tableSize; i++) {
        if (strcmp(symbolTable[i].name, name) == 0 && symbolTable[i].scope == scope) {
            if (value != NULL) {
                strncpy(symbolTable[i].value, value, MAX_VALUE_LENGTH - 1);
                symbolTable[i].value[MAX_VALUE_LENGTH - 1] = '\0';
            }
            if (parentStruct != NULL) {
                strncpy(symbolTable[i].parentStruct, parentStruct, MAX_NAME_LENGTH - 1);
                symbolTable[i].parentStruct[MAX_NAME_LENGTH - 1] = '\0';
            }
            return;
        }
    }
    fprintf(stderr, "Error: Symbol %s not found in scope %d.\n", name, scope);
}


void printSymbolTable(SymbolTableEntry* symbolTable, int tableSize) {
    printf("\n-----------------------------------------Symbol Table------------------------------------------------------------\n");
    printf("Name            | Type         | Value      | Line | Scope | isArray | ArraySize | isStruct | ParentStruct         |\n");
    printf("-------------------------------------------------------------------------------------------------------------------\n");


    for (int i = 0; i < tableSize; i++) {
        printf("%-15s | %-12s | %-10s | %-4d | %-5d | %-7d | %-9d | %-8d | %-20s |\n",
            symbolTable[i].name,
            symbolTable[i].type,
            symbolTable[i].value,
            symbolTable[i].line,
            symbolTable[i].scope,
            symbolTable[i].isArray,
            symbolTable[i].arraySize,
            symbolTable[i].isStruct,
            symbolTable[i].parentStruct);
    }
    printf("\n");
}


void freeSymbolTable(SymbolTableEntry* symbolTable) {
    if (symbolTable != NULL) {
        free(symbolTable);
    }
}





