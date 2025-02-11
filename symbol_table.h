#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMBOLS 1000
#define MAX_NAME_LENGTH 50
#define MAX_TYPE_LENGTH 20
#define MAX_VALUE_LENGTH 100

typedef struct {
	char name[MAX_NAME_LENGTH];
	char type[MAX_TYPE_LENGTH];
	char value[MAX_VALUE_LENGTH];
	int line;
	int scope;
	int isArray;
	int arraySize;
	int isStruct;
	char parentStruct[MAX_NAME_LENGTH];
} SymbolTableEntry;

SymbolTableEntry* allocSymbolTable();
SymbolTableEntry* insertEntry(SymbolTableEntry* symbolTable,int* tableSize,char* name,
	char* type,char* value,int line,int scope,int isArray,int arraySize,int isStruct,
	char* parentStruct
);
SymbolTableEntry* searchSymbol(SymbolTableEntry* symbolTable, int tableSize, char* name);
void updateEntry(SymbolTableEntry* symbolTable, int tableSize, char* name, int scope,
	 char* value, char* parentStruct);
void printSymbolTable(SymbolTableEntry* symbolTable, int tableSize);
void freeSymbolTable(SymbolTableEntry* symbolTable);

#endif // SYMBOL_TABLE_H

