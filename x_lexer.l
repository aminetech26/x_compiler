%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "symbol_table.h"
#include "x_parser.tab.h"
extern int yylineno;
%}

%option noyywrap

/* Definitions for various tokens */
DIGIT       	[0-9]
LETTER      	[a-zA-Z]
IDENTIFIER  	{LETTER}({LETTER}|{DIGIT})*
INTEGER     	{DIGIT}+
FLOAT       	{DIGIT}+"."{DIGIT}+
STRING      	\"[^\"\n]*\"
WHITESPACE  	[ \t]+
NEWLINE     	\n|(\r\n)

/* Keywords */
PROGRAM     	program
START       	start
FINISH      	finish
VAR         	var
STRUCT      	struct
CHECK       	check
CYCLE       	cycle
WHILE       	while
READ        	read
DISPLAY     	display
ELSE        	else
ELSECHECK   	"else check"
FROM        	from
TO          	to
BY          	by

/* Primitive Types */
INT_TYPE    	int
FLOAT_TYPE  	flt
BOOL_TYPE   	bool
STR_TYPE    	str

/* Boolean Values */
BOOL_TRUE   	true
BOOL_FALSE  	false

/* Operators */

PLUS        	"+"
MINUS       	"-"
MULTIPLY    	"*"
DIVIDE      	"/"
MODULO      	"%"
POWER       	"^"

AND         	and
OR          	or
NOT         	not

LT          	"<"
GT          	">"
LTE         	"<="
GTE         	">="
EQ          	"=="
NEQ         	"#"
ASSIGN      	"="

/* Punctuation */
LPAREN      	"("
RPAREN      	")"
LBRACE      	"{"
RBRACE      	"}"
LBRACKET    	"["
RBRACKET    	"]"
COMMA       	","
PERIOD      	"."
ARROW       	"->"

%%

{WHITESPACE}	{ /* Ignore whitespace */ }

"//".*      	{ /* Single-line comment */ }

"/*"[^*]*"*/"   { /* Multi-line comment */
	int i;
	for (i = 0; yytext[i]; i++) {
    	if (yytext[i] == '\n') yylineno++;
	}
}

{NEWLINE}   	{ yylineno++; }
{PROGRAM}   	{ printf("Keyword: PROGRAM at line %d\n", yylineno); return PROGRAM; }
{START}     	{ printf("Keyword: START at line %d\n", yylineno); return START; }
{FINISH}    	{ printf("Keyword: FINISH at line %d\n", yylineno); return FINISH; }
{VAR}       	{ printf("Keyword: VAR at line %d\n", yylineno); return VAR; }
{STRUCT}    	{ printf("Keyword: STRUCT at line %d\n", yylineno); return STRUCT; }
{CHECK}     	{ printf("Keyword: CHECK at line %d\n", yylineno); return CHECK; }
{ELSE}     	{ printf("Keyword: ELSE at line %d\n", yylineno); return ELSE; }
{CYCLE}     	{ printf("Keyword: CYCLE at line %d\n", yylineno); return CYCLE; }
{WHILE}     	{ printf("Keyword: WHILE at line %d\n", yylineno); return WHILE; }
{READ}      	{ printf("Keyword: READ at line %d\n", yylineno); return READ; }
{DISPLAY}   	{ printf("Keyword: DISPLAY at line %d\n", yylineno); return DISPLAY; }
{FROM}     	{ printf("Keyword: FROM at line %d\n", yylineno); return FROM; }
{TO}       	{ printf("Keyword: TO at line %d\n", yylineno); return TO; }
{BY}       	{ printf("Keyword: BY at line %d\n", yylineno); return BY; }

{INT_TYPE}  	{ printf("Type: INTEGER at line %d\n", yylineno); return INT_TYPE; }
{FLOAT_TYPE}	{ printf("Type: FLOAT at line %d\n", yylineno); return FLOAT_TYPE; }
{BOOL_TYPE} 	{ printf("Type: BOOLEAN at line %d\n", yylineno); return BOOL_TYPE; }
{STR_TYPE}  	{ printf("Type: STRING at line %d\n", yylineno); return STR_TYPE; }

{BOOL_TRUE} 	{
	printf("Boolean: TRUE at line %d\n", yylineno);
	return BOOL_TRUE;
}

{BOOL_FALSE}	{
	printf("Boolean: FALSE at line %d\n", yylineno);
	return BOOL_FALSE;
}

{INTEGER}   	{
	printf("Integer Literal: %s at line %d\n", yytext, yylineno);
	yylval.int_val = atoi(yytext); // Passer la valeur à Bison
	return INTEGER;
}

{FLOAT}     	{
	printf("Float Literal: %s at line %d\n", yytext, yylineno);
	yylval.float_val = atof(yytext); // Passer la valeur à Bison
	return FLOAT;
}

{STRING}    	{
	printf("String Literal: %s at line %d\n", yytext, yylineno);
	yylval.string_val = strdup(yytext); // Passer la valeur à Bison
	return STRING;
}

{IDENTIFIER}	{
	printf("Identifier: %s at line %d\n", yytext, yylineno);
	yylval.string_val = strdup(yytext); // Passer la valeur à Bison
	return IDENTIFIER;
}


{PLUS}      	{ printf("Arithmetic Operator: PLUS at line %d\n", yylineno); return PLUS; }
{MINUS}     	{ printf("Arithmetic Operator: MINUS at line %d\n", yylineno); return MINUS; }
{MULTIPLY}  	{ printf("Arithmetic Operator: MULTIPLY at line %d\n", yylineno); return MULTIPLY; }
{DIVIDE}    	{ printf("Arithmetic Operator: DIVIDE at line %d\n", yylineno); return DIVIDE; }
{POWER}     	{ printf("Arithmetic Operator: POWER at line %d\n", yylineno); return POWER; }
{MODULO}    	{ printf("Arithmetic Operator: MODULO at line %d\n", yylineno); return MODULO; }

{AND}       	{ printf("Logical Operator: AND at line %d\n", yylineno); return AND; }
{OR}        	{ printf("Logical Operator: OR at line %d\n", yylineno); return OR; }
{NOT}       	{ printf("Logical Operator: NOT at line %d\n", yylineno); return NOT; }

{LT}        	{ printf("Comparison Operator: LT at line %d\n", yylineno); return LT; }
{GT}        	{ printf("Comparison Operator: GT at line %d\n", yylineno); return GT; }
{LTE}       	{ printf("Comparison Operator: LTE at line %d\n", yylineno); return LTE; }
{GTE}       	{ printf("Comparison Operator: GTE at line %d\n", yylineno); return GTE; }
{EQ}        	{ printf("Comparison Operator: EQ at line %d\n", yylineno); return EQ; }
{NEQ}       	{ printf("Comparison Operator: NEQ at line %d\n", yylineno); return NEQ; }

{ASSIGN}    	{ printf("Assignment Operator at line %d\n", yylineno); return ASSIGN; }
{LPAREN}    	{ printf("Left Parenthesis at line %d\n", yylineno); return LPAREN; }
{RPAREN}    	{ printf("Right Parenthesis at line %d\n", yylineno); return RPAREN; }
{LBRACE}    	{ printf("Left Brace at line %d\n", yylineno); return LBRACE; }
{RBRACE}    	{ printf("Right Brace at line %d\n", yylineno); return RBRACE; }
{LBRACKET}  	{ printf("Left Bracket at line %d\n", yylineno); return LBRACKET; }
{RBRACKET}  	{ printf("Right Bracket at line %d\n", yylineno); return RBRACKET; }
{COMMA}     	{ printf("Comma at line %d\n", yylineno); return COMMA; }
{PERIOD}    	{ printf("Period at line %d\n", yylineno); return PERIOD; }
{ARROW}     	{ printf("Arrow at line %d\n", yylineno); return ARROW; }

.           	{ printf("Unexpected character: %s at line %d\n", yytext, yylineno); return yytext[0]; }

%%





