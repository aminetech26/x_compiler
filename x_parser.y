%define parse.error verbose


%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"  // Include the symbol table header
#include "quadruplets.h"
extern int yylineno;
extern int yylex();
extern FILE* yyin;
void yyerror(const char *s);
const char* verifyTypesCompatibility(const char* type1, const char* type2);
char* getOP( char* op);

SymbolTableEntry* symbolTable;  // Global symbol table
int tableSize = 0;              // Size of the symbol table
int currentScope = 0;           // Current scope level

int sauv_else = 0;
int sauv_fin_else = 0;
int sauv_fin_if = 0;
int sauv_fin_while = 0;
int sauv_debut_while = 0;

char* id_cycle;     
char* to_cycle;      
char* step_cycle;    
int debut_block_cycle;
%}


/* Définition des tokens */
%token PROGRAM START FINISH VAR STRUCT CHECK CYCLE WHILE READ DISPLAY ELSE
%token ELSECHECK FROM TO BY
%token INT_TYPE FLOAT_TYPE BOOL_TYPE STR_TYPE
%token BOOL_TRUE BOOL_FALSE
%token PLUS MINUS MULTIPLY DIVIDE POWER MODULO AND OR NOT ASSIGN
%token LT GT LTE GTE EQ NEQ
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET COMMA PERIOD ARROW
%token ARITHMETIC LOGICAL_OP COMPARISON ARRAY_DECLARATION


/* Type des tokens qui retournent une valeur */
%union {
    int int_val;
    float float_val;
    char *string_val;
    struct {
        char* code;  // For temporary variable name
        char* type;  // For type checking
    } expr;
}


/* Définition des tokens avec types */
%token <int_val> INTEGER
%token <float_val> FLOAT
%token <string_val> STRING
%token <string_val> IDENTIFIER


/* Définition des types pour les non-terminaux */
%type <string_val> type
%type <string_val> field
%type <string_val> s_array_declaration
%type <string_val> array_declaration
%type <string_val> array_instance
//%type <string_val> variable
%type <string_val> variable_list
%type <string_val> struct_declaration
%type <expr> expression
%type <expr> variable


/* Définition des précédences et associativités */
%left OR
%left AND
%left EQ NEQ
%left LT GT LTE GTE
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%right POWER
%right NOT


%%


/* Point de départ de la grammaire */
program:
    PROGRAM IDENTIFIER PERIOD struct_section var_section main_section
    {
        printf("Programme reconnu : %s\n", $2);
        printSymbolTable(symbolTable, tableSize);
    }
    ;


/* Section des structures */
struct_section:
    /* vide */
    | STRUCT LBRACE struct_declarations RBRACE
    ;


struct_declarations:
    struct_declaration
    | struct_declarations struct_declaration
    ;


struct_declaration:
    IDENTIFIER ASSIGN LBRACE field_list RBRACE PERIOD
    {
        insertEntry(symbolTable, &tableSize, $1, "struct", "", yylineno, currentScope, 0, 0, 1, NULL);
        // Update each field in the field list to set the parentStruct
        SymbolTableEntry* entry;
        for (int i = 0; i < tableSize; i++) {
            if (symbolTable[i].scope == currentScope+1 && strcmp(symbolTable[i].parentStruct, "") == 0) {
                updateEntry(symbolTable, tableSize, symbolTable[i].name, currentScope+1, NULL, $1);
            }
        }
        $$ = $1;
    }
    ;


field_list:
    field
    | field_list COMMA field
    ;


field:
    type IDENTIFIER
    {
        insertEntry(symbolTable, &tableSize, $2, $1, "", yylineno, currentScope+1, 0, 0, 0, NULL);
        $$ = $2;
    }
    | s_array_declaration
    {
        $$ = $1;
    }
    ;


s_array_declaration:
    type LBRACKET INTEGER RBRACKET IDENTIFIER
    {
        insertEntry(symbolTable, &tableSize, $5, $1, "", yylineno, currentScope+1, 1, $3, 0, NULL);
        $$ = $5;
    }
    ;


/* Section des variables */
var_section:
    VAR LBRACE variable_declarations RBRACE
    ;


variable_declarations:
    variable_declaration
    | variable_declarations variable_declaration
    ;


variable_declaration:
    type variable_list PERIOD
    {
        char* varName = strtok($2, ",");
        int isstruct = 0;
        if (strcmp($1,"int") != 0 && strcmp($1,"float") != 0 & strcmp($1,"bool") != 0 && strcmp($1,"str") != 0) {
            isstruct = 1;
        }
        while (varName != NULL) {
            SymbolTableEntry* entry = insertEntry(symbolTable, &tableSize, varName, $1, "", yylineno, currentScope, 0, 0, isstruct, NULL);
            if (entry == NULL) {
                yyerror("Failed to insert variable into symbol table");
            }
            varName = strtok(NULL, ",");
        }
    }
    | array_declaration
    ;




variable_list:
    IDENTIFIER
    {
        $$ = strdup($1);
    }
    | variable_list COMMA IDENTIFIER
    {
        char* temp = malloc(strlen($1) + strlen($3) + 2);
        sprintf(temp, "%s,%s", $1, $3);
        $$ = temp;
    }
    ;




array_declaration:
    type LBRACKET INTEGER RBRACKET array_instance PERIOD
    {
        char* varName = strtok($5, ",");
        while (varName != NULL) {
            SymbolTableEntry* entry = insertEntry(symbolTable, &tableSize, varName, $1, "", yylineno, currentScope, 1, $3, 0, NULL);
            if (entry == NULL) {
                yyerror("Failed to insert array into symbol table");
            }
            varName = strtok(NULL, ",");
        }
        $$ = $5;
    }
    ;




array_instance:
    IDENTIFIER COMMA array_instance
    {
        char* temp = malloc(strlen($1) + strlen($3) + 2);
        sprintf(temp, "%s,%s", $1, $3);
        $$ = temp;
    }
    | IDENTIFIER
    {
        $$ = strdup($1);
    }
    ;




type:
    INT_TYPE { $$ = "int"; }
    | FLOAT_TYPE { $$ = "float"; }
    | BOOL_TYPE { $$ = "bool"; }
    | STR_TYPE { $$ = "str"; }
    | IDENTIFIER { $$ = $1; }
    ;


/* Section principale */
main_section:
    START statements FINISH
    ;


block:
    LBRACE statements RBRACE
    ;


statements:
    /* vide */
    | statements statement
    ;


statement:
    assignment_statement
    | conditional_statement
    | cycle_statement
    | while_statement
    | io_statement
    ;


assignment_statement:
    variable ASSIGN expression PERIOD
    {
        // Type checking
        SymbolTableEntry* entry = searchSymbol(symbolTable, tableSize, $1.code);
        if(entry == NULL) {
            yyerror("Error semantique : Undefined variable");
        
        } else if (strcmp(entry->type, $3.type) != 0) {
            yyerror("Error semantique : Type mismatch in assignment");
        } else {
            // Generate code
            add_quad(global_quad_list, "=", $3.code, "", $1.code);
        }
    }
    ;

variable:
   
    IDENTIFIER LBRACKET expression RBRACKET
    {
        //Routine semantique : verification du table 
        SymbolTableEntry* entry = searchSymbol(symbolTable, tableSize, $1);
        if(entry == NULL) {
            yyerror("Error semantique : Undefined table");
        } else if (entry->isArray == 0) {
            yyerror("Error semantique : Variable is not a table");
        } else if (strcmp($3.type, "int") != 0) {
            yyerror("Error semantique : Index of table must be an integer");
        } else {
            //add quadruple
            $$.code = $<string_val>1  ;
        }
    }
    | IDENTIFIER ARROW IDENTIFIER
    {
        SymbolTableEntry* entry = searchSymbol(symbolTable, tableSize, $1);
        if (entry == NULL) {
            yyerror("Undefined variable");
        } else {
            // Check if the field name exists in the symbol table with the mentioned type as its parent struct
            SymbolTableEntry* fieldEntry = searchSymbol(symbolTable, tableSize, $3);
            if (fieldEntry == NULL || strcmp(fieldEntry->parentStruct, entry->type) != 0) {
                yyerror("Field does not exist in the specified struct type");
            } else {
                $$.code = $3;
                $$.type = fieldEntry->type;
            
                // Generate code
                
            }
        }
    }
    | IDENTIFIER
    {
        SymbolTableEntry* entry = searchSymbol(symbolTable, tableSize, $1);
        if(entry == NULL) {
            yyerror("Undefined variable");
            YYERROR;
        }
        $$.code = strdup($1);
        $$.type = strdup(entry->type);
    }
    ;

/*
conditional_statement:
    CHECK LPAREN expression RPAREN block
    {
        
    }
    | CHECK LPAREN expression RPAREN block ELSE block
    | CHECK LPAREN expression RPAREN block ELSE conditional_statement
    ;
*/

conditional_statement:
    if_else_stmt
    | if_stmt
;

if_stmt:
    DEBUT_IF_ELSE block
    {
        char saut_if[20];
        sprintf(saut_if, "%d", global_quad_list->size);
        strcpy(global_quad_list->quads[sauv_fin_if].opr1 , saut_if);
    }
    ;
/*
DEBUT_IF:
    CHECK LPAREN expression RPAREN
    {
        sauv_fin_if = global_quad_list->size-1;
    }
    ;*/


if_else_stmt:
    DEBUT_INST_IF_ELSE ELSE block 
    {
        char next_saut[20];
        sprintf(next_saut, "%d", global_quad_list->size);
        strcpy(global_quad_list->quads[sauv_fin_else].opr1 , next_saut);
    }
    ;

DEBUT_INST_IF_ELSE:
    DEBUT_IF_ELSE block
    {
        add_quad(global_quad_list,"BR","","","");
        char temp[20];
        sprintf(temp, "%d", global_quad_list->size);
        strcpy(global_quad_list->quads[sauv_else].opr1 , temp);
        sauv_fin_else = global_quad_list->size-1;
    }

;

DEBUT_IF_ELSE:
    CHECK LPAREN expression RPAREN
    {
        sauv_else = global_quad_list->size-1;
        sauv_fin_if = global_quad_list->size-1;
    }
;
/*
cycle_statement:
    CYCLE LPAREN IDENTIFIER FROM expression TO expression BY expression RPAREN block
    ;
*/
//-----------------------------------------------------------
cycle_statement:
    DEBUT_CYCLE block
    {
        // Quadruplet d'incrémentation
        char* temp = new_temp();
        add_quad(global_quad_list, "+", id_cycle, step_cycle, temp);
        add_quad(global_quad_list, "=", temp, "", id_cycle);
        
        // Quadruplet de comparaison et saut
        add_quad(global_quad_list, "BLE", "", id_cycle, to_cycle);
        
        // Mettre à jour l'adresse de saut vers le début du block
        int pos_saut = global_quad_list->size - 1;
        char dest_saut[20];
        sprintf(dest_saut, "%d", debut_block_cycle);
        strcpy(global_quad_list->quads[pos_saut].opr1, dest_saut);
    }
    ;

DEBUT_CYCLE:
    CYCLE LPAREN IDENTIFIER FROM expression TO expression BY expression RPAREN
    {
        SymbolTableEntry* entry = searchSymbol(symbolTable, tableSize, $3);
        // Vérification sémantique

        if (entry == NULL){
            yyerror("Error semantique : Iterator variable not declared");
             YYERROR;
        }
        
        if((strcmp(entry->type, "int") != 0) && (strcmp(entry->type, "flt") != 0)) {
            yyerror("Error semantique : Iterator variable must be integer or float");
            YYERROR;
        }
        
        if(((strcmp($5.type, "int") != 0) && (strcmp($5.type, "flt") != 0)) || ((strcmp($7.type, "int") != 0) && (strcmp($7.type, "flt") != 0)) || ((strcmp($9.type, "int") != 0) && (strcmp($9.type, "flt") != 0)) ) {
            yyerror("Error semantique : FROM, TO and BY expressions must be integers");
            YYERROR;
        }

        // Sauvegarder les informations nécessaires dans des variables globales
        id_cycle = strdup($3);
        to_cycle = strdup($7.code);
        step_cycle = strdup($9.code);
        
        // Quadruplet d'affectation initiale
        add_quad(global_quad_list, "=", $5.code, "", $3);
        
        // Sauvegarder la position du début du block
        debut_block_cycle = global_quad_list->size;
    }
    
    ;
//----------------------------------------------------------

while_statement:
    WHILE LPAREN expression RPAREN block
    ;


io_statement:
    READ LPAREN variable RPAREN PERIOD
    {
        add_quad(global_quad_list,"read", $3.code, "", "");
    }
    | DISPLAY LPAREN expression RPAREN PERIOD
    {
        add_quad(global_quad_list,"display", $3.code, "", "");
    }
    ;


expression:
    INTEGER { 
        char temp[20];
        sprintf(temp, "%d", $1);
        $$.code = strdup(temp);
        $$.type = "int";
     }
    | FLOAT { 
        char temp[20];
        sprintf(temp, "%f", $1);
        $$.code = strdup(temp);
        $$.type = "flt";
    }
    | STRING { 
        $$.code = strdup($1);
        $$.type = "str";
    }
    | BOOL_TRUE { 
        $$.code = strdup("true");
        $$.type = "bool";
    }
    | BOOL_FALSE { 
        $$.code = strdup("false");
        $$.type = "bool";
    }
    | variable
        {
            $$ = $1;
        }


    | expression PLUS expression { 
        const char* resultType = verifyTypesCompatibility($1.type, $3.type);
        if (resultType == NULL) {
            yyerror("Type mismatch in PLUS operation");
        } else {
            char* temp = new_temp();
            add_quad(global_quad_list, "+", $1.code, $3.code, temp);
            $$.code = temp;
            $$.type = strdup(resultType);
        }
    }
    | expression MINUS expression {
        const char* resultType = verifyTypesCompatibility($1.type, $3.type);
        if (resultType == NULL) {
            yyerror("Type mismatch in MINUS operation");
        } else {
            char* temp = new_temp();
            add_quad(global_quad_list, "-", $1.code, $3.code, temp);
            $$.code = temp;
            $$.type = strdup(resultType);
        }
     }
    | expression MULTIPLY expression { 
        const char* resultType = verifyTypesCompatibility($1.type, $3.type);
        if (resultType == NULL) {
            yyerror("Type mismatch in MULTIPLY operation");
        } else {
            char* temp = new_temp();
            add_quad(global_quad_list, "*", $1.code, $3.code, temp);
            $$.code = temp;
            $$.type = strdup(resultType);
        }
     }
    | expression DIVIDE expression { 
        const char* resultType = verifyTypesCompatibility($1.type, $3.type);
        if (resultType == NULL) {
            yyerror("Type mismatch in DIVIDE operation");
        } else {
            char* temp = new_temp();
            add_quad(global_quad_list, "/", $1.code, $3.code, temp);
            $$.code = temp;
            $$.type = strdup(resultType);
        }
     }
    | expression POWER expression { 
        const char* resultType = verifyTypesCompatibility($1.type, $3.type);
        if (resultType == NULL) {
            yyerror("Type mismatch in POWER operation");
        } else {
            char* temp = new_temp();
            add_quad(global_quad_list, "^", $1.code, $3.code, temp);
            $$.code = temp;
            $$.type = strdup(resultType);
        }
    }
    | expression MODULO expression { 
        if (strcmp($1.type, "int") != 0 || strcmp($3.type, "int") != 0) {
            yyerror("MODULO operation requires integer operands");
        } else {
            char* temp = new_temp();
            add_quad(global_quad_list, "%", $1.code, $3.code, temp);
            $$.code = temp;
            $$.type = strdup("int");
        }
     }
    | expression AND expression { 
        const char* resultType = verifyTypesCompatibility($1.type, $3.type);
        if (resultType == NULL) {
            yyerror("Type mismatch in AND operation");
        } else {
            char* temp = new_temp();
            $$.code = temp;
            $$.type = strdup(resultType);
        }
     }
    | expression OR expression {
        const char* resultType = verifyTypesCompatibility($1.type, $3.type);
        if (resultType == NULL) {
            yyerror("Type mismatch in OR operation");
        } else {
            char* temp = new_temp();
            $$.code = temp;
            $$.type = strdup(resultType);
        }
    }
    ;
    | NOT expression {
        if (strcmp($2.type, "bool") != 0) {
            yyerror("Type mismatch in NOT operation");
        } else {
            char* temp = new_temp();
            $$.code = temp;
            $$.type = strdup("bool");
        }
    }
    ;
    | expression LT expression {
        const char* resultType = verifyTypesCompatibility($1.type, $3.type);
        if (resultType == NULL) {
            yyerror("Type mismatch in LT operation");
        } else {
            char* temp = new_temp();
            $$.code = temp;
            $$.type = strdup("bool");
            add_quad(global_quad_list,getOP("LT"),"", $1.code, $3.code);
        }
     }
    | expression GT expression { 
        const char* resultType = verifyTypesCompatibility($1.type, $3.type);
        if (resultType == NULL) {
            yyerror("Type mismatch in GT operation");
        } else {
            char* temp = new_temp();
            $$.code = temp;
            $$.type = strdup("bool");
            add_quad(global_quad_list,getOP("GT"),"", $1.code, $3.code);
        }
     }
    | expression LTE expression {
        const char* resultType = verifyTypesCompatibility($1.type, $3.type);
        if (resultType == NULL) {
            yyerror("Type mismatch in LTE operation");
        } else {
            char* temp = new_temp();
            $$.code = temp;
            $$.type = strdup("bool");
            add_quad(global_quad_list,getOP("LTE"),"", $1.code, $3.code);
        }
     }
    | expression GTE expression {
        const char* resultType = verifyTypesCompatibility($1.type, $3.type);
        if (resultType == NULL) {
            yyerror("Type mismatch in GTE operation");
        } else {
            char* temp = new_temp();
            $$.code = temp;
            $$.type = strdup("bool");
            add_quad(global_quad_list,getOP("GTE"),"", $1.code, $3.code);
        }
     }
    | expression EQ expression {
        const char* resultType = verifyTypesCompatibility($1.type, $3.type);
         if (resultType == NULL) {
             yyerror("Type mismatch in EQ operation");
         } else {
             char* temp = new_temp();
             $$.code = temp;
             $$.type = strdup("bool");
             add_quad(global_quad_list,getOP("EQ"),"", $1.code, $3.code);
         }
     }
    | expression NEQ expression {
        const char* resultType = verifyTypesCompatibility($1.type, $3.type);
         if (resultType == NULL) {
             yyerror("Type mismatch in NEQ operation");
         } else {
             char* temp = new_temp();
             $$.code = temp;
             $$.type = strdup("bool");
             add_quad(global_quad_list,getOP("NEQ"),"", $1.code, $3.code);
         }
    }
    | LPAREN expression RPAREN {  }
    | MINUS INTEGER { 
        $$.type = strdup("int");
        char buf[32];
        sprintf(buf, "-%d", $<int_val>2);
        $$.code = strdup(buf);
     }
    | MINUS FLOAT { 
        $$.type = strdup("flt");
        char buf[32];
        sprintf(buf, "-%f", $<float_val>2);
        $$.code = strdup(buf);
     }
    ;
%%


// Fonction pour vérifier la compatibilité des types
const char* verifyTypesCompatibility(const char* type1, const char* type2) {
    if (strcmp(type1, type2) == 0) {
        return type1;
    }

    if ((strcmp(type1, "int") == 0 && strcmp(type2, "flt") == 0) ||
        (strcmp(type1, "flt") == 0 && strcmp(type2, "int") == 0)) {
        return "flt";
    }

    //fprintf(stderr, "Type mismatch: %s and %s are not compatible\n", type1, type2);
    return NULL;
}

char* getOP(char* op){
    if (strcmp(op,"LTE")==0) {
        return "BG";
    } else if (strcmp(op,"GTE")==0) {
        return "BL";
    } else if (strcmp(op,"LT")==0) {
        return "BGE";
    } else if (strcmp(op,"GT")==0) {
        return "BLE";
    } else if (strcmp(op,"EQ")==0) {
        return "BNE";
    } else if (strcmp(op,"NE")==0) {
        return "BEQ";
    } else {
        return "BR";
    }
}


void yyerror(const char *s) {
    fprintf(stderr, "Erreur syntaxique à la ligne %d : %s\n", yylineno, s);
}


int main(int argc, char *argv[]) {
    if (argc <= 1) {
        fprintf(stderr, "Usage: %s fichier_source\n", argv[0]);
        return 1;
    }


    printf("Tentative d'ouverture du fichier : %s\n", argv[1]);
    FILE *input = fopen(argv[1], "r");
    if (!input) {
        fprintf(stderr, "Erreur : Impossible d'ouvrir le fichier %s\n", argv[1]);
        return 1;
    }
    yyin = input;


    symbolTable = allocSymbolTable();
    if(!symbolTable) {
        fprintf(stderr, "Failed to allocate symbol table\n");
        return 1;
    }
    
    global_quad_list = init_quad_list();
    if(!global_quad_list) {
        fprintf(stderr, "Failed to initialize quadruplet list\n");
        freeSymbolTable(symbolTable);
        return 1;
    }


    printf("Démarrage de l'analyse syntaxique...\n");
    int result = yyparse();
   
    printf("Analyse syntaxique terminée avec le code : %d\n", result);
    fclose(input);

    print_quads(global_quad_list);
    free_quad_list(global_quad_list);


    freeSymbolTable(symbolTable);
    return result;
}



