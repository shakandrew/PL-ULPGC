%{
#include "ASTDeclaration.h"
#include "parser.hpp"
#include <bits/stdc++.h>

#define YY_DECL extern "C" int yylex()

extern union Node yylval;
using namespace std;
%}

%%
"int"					{ yylval.val = strdup(yytext); return INT; }
"print"	    			{ return PRINT; }
"println"               { return PRINTLN; }
"read"  				{ return READ; }
"for"					{ return FOR; }
"if"					{ return IF; }
"else"					{ return ELSE; }
"while"					{ return WHILE; }
"return"                { return RETURN; }
[0-9][0-9]*				{ yylval.num = atoi(yytext); return NUMBER; }
[a-zA-Z][a-zA-Z0-9]* 	{ yylval.val = strdup(yytext); return IDENTIFIER; }
";"						{ return SC; }
":"                     { return COLON; }
","						{ return COMMA; }
"+"						{ yylval.val = strdup(yytext); return ADD; }
"-"						{ yylval.val = strdup(yytext); return SUB; }
"*"						{ yylval.val = strdup(yytext); return MUL; }
"&&"					{ yylval.val = strdup(yytext); return AND;}	
"||"					{ yylval.val = strdup(yytext); return OR;}
"!="					{ yylval.val = strdup(yytext); return NOTEQUALS;}
"!"						{ yylval.val = strdup(yytext); return NOT; }
"/"						{ yylval.val = strdup(yytext); return DIV; }
"%"						{ yylval.val = strdup(yytext); return MOD; }
"{"						{ return OP; }
"}"						{ return CP; }
"["						{ return OSB; }
"]"						{ return CSB; }
"("                     { return ORB; }
")"                     { return CRB; }
"=="					{ yylval.val = strdup(yytext); return EQUALS; }
"="						{ return EQ; }
">"						{ yylval.val = strdup(yytext); return GT; }
"<"						{ yylval.val = strdup(yytext); return LT; }
">="					{ yylval.val = strdup(yytext); return GE; }
"<="					{ yylval.val = strdup(yytext); return LE; }
\"(\\n|\\t|\\'|\\\\|\\\"|[^\\"'])*\"	{ yylval.val = strdup(yytext); return STRING; }
([ \t]|[ \n])			{ /* Do nothing */ }
.						;
%%