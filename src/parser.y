%{
  #include <bits/stdc++.h>
  #include "ASTDeclaration.h"
  #include <iostream>;
  extern "C" int yylex();
  extern "C" int yyparse();
  extern "C" FILE *yyin;
  extern "C" int errors;
  extern union Node yylval;
  void yyerror (char const *s);
  NStatements *root = nullptr;
  int errors = 0;
%}

%start program
%token <val> IDENTIFIER STRING
%token <num> NUMBER
%token WHILE GOT IF ELSE
%token PRINT READ RETURN
%token FOR PRINTLN
%token SC COMMA COLON
%token OP CP OSB CSB ORB CRB
%token <val> AND OR NOT INT
%token <val> ADD SUB MUL DIV MOD
%token <val> GT LT LE GE
%token <val> EQ NOTEQUALS
%token <val> EQUALS

%left EQUALS NOTEQUALS
%left AND OR
%left LT GT
%left LE GE
%left ADD SUB
%left MUL DIV MOD
%nonassoc NOT

%type <statements> program
%type <statements> program_stmts
%type <functionDeclaration> func_decl
%type <variableDeclarations> func_decl_args
%type <expressions> func_call_args
%type <functionCall> func_call
%type <variableDeclaration> var_decl
%type <val> type
%type <statements> stmts
%type <identifier> ident
%type <expression> expr
%type <assignmentStmt> assign_stmt
%type <forStmt> for_stmt
%type <ifElseStmt> if_stmt
%type <whileStmt> while_stmt
%type <printStmt> print_stmt
%type <readStmt> read_stmt
%type <returnStmt> return_stmt
%type <block> block

%%
program         : program_stmts { $$ = $1; root = $$; }
	            ;

program_stmts   : /*blank*/ { $$ = new NStatements(); }
                | program_stmts func_decl { $$->push_back($2); }
                | program_stmts var_decl SC { $$->push_back($2); }
                ;

func_decl		: type IDENTIFIER ORB func_decl_args CRB block { $$ = new NFunctionDeclaration($2, $4, $6);}
				;

func_decl_args	: /*blank*/ { $$ = new NVariableDeclarations(); }
				| func_decl_args var_decl { $$->push_back($2); }
				| func_decl_args COMMA var_decl { $$->push_back($3); }
  				;

var_decl        : type IDENTIFIER { $$ = new NVariableDeclaration($1, $2, 0); }
		   	    | type IDENTIFIER OSB NUMBER CSB { $$ = new NVariableDeclaration($1, $2, $4); }
		   		;

type            : INT {}
                ;

stmts           : /*blank*/ { $$ = new NStatements(); }
                | stmts block { $$->push_back($2); }
                | stmts if_stmt { $$->push_back($2); }
                | stmts for_stmt { $$->push_back($2); }
                | stmts while_stmt { $$->push_back($2); }
                | stmts var_decl SC { $$->push_back($2); }
                | stmts return_stmt { $$->push_back($2); }
              	| stmts read_stmt SC { $$->push_back($2); }
              	| stmts print_stmt SC { $$->push_back($2); }
              	| stmts assign_stmt SC { $$->push_back($2); }
                ;

assign_stmt     : ident EQ expr { $$ = new NAssignmentStmt($1, $3);	}
		        ;

expr            : expr SUB expr { $$ = new NExpression($1, string($2), $3);	}
                | expr ADD expr { $$ = new NExpression($1, string($2), $3);	}
                | expr MUL expr	{ $$ = new NExpression($1, string($2), $3);	}
                | expr DIV expr { $$ = new NExpression($1, string($2), $3);	}
                | expr MOD expr { $$ = new NExpression($1, string($2), $3);	}
                | expr LT expr { $$ = new NExpression($1, string($2), $3); }
                | expr GT expr { $$ = new NExpression($1, string($2), $3); }
                | expr LE expr { $$ = new NExpression($1, string($2), $3); }
                | expr GE expr { $$ = new NExpression($1, string($2), $3); }
                | expr EQUALS expr { $$ = new NExpression($1, string($2), $3); }
                | expr NOTEQUALS expr { $$ = new NExpression($1, string($2), $3); }
                | expr AND expr { $$ = new NExpression($1, string($2), $3); }
                | expr OR expr { $$ = new NExpression($1, string($2), $3); }
                | ident { $$ = new NExpression($1); }
                | func_call { $$ = new NExpression($1); }
                ;

func_call       : ident ORB func_call_args CRB { $$ = new NFunctionCall($1, $3); }
                ;

func_call_args  : /*blank*/ { $$ = new NExpressions(); }
                | func_call_args expr { $$->push_back($2); }
                | func_call_args COMMA expr { $$->push_back($3); }
                ;
                
ident           : IDENTIFIER { $$ = new NIdentifier(string($1)); }
                | IDENTIFIER OSB expr CSB { $$ = new NIdentifier(string($1), $3);	}
                | NUMBER { $$ = new NIdentifier($1); }
                ;

for_stmt        : FOR ident EQ expr COLON expr block
                    { $$ = new NForStmt($2, $4, $6, $7); }
		        | FOR ident EQ expr COLON expr COLON expr block
		            { $$ = new NForStmt($2, $4, $6, $8, $9); }
		        ;

if_stmt         : IF expr block { $$ = new NIfElseStmt($2, $3); }
		        | IF expr block ELSE block { $$ = new NIfElseStmt($2, $3, $5); }
		        ;

while_stmt      : WHILE expr block { $$ = new NWhileStmt($2, $3);	}
			    ;


block           : OP stmts CP { $$ = new NBlock($2); }
		        ;

print_stmt      : PRINT STRING { string str($2); str = str.substr(1, str.length()-2);
                        $$ = new NPrintStmt(str, nullptr); }
            	| PRINT expr { $$ = new NPrintStmt("%d",$2); }
            	| PRINTLN STRING { string str($2); str = str.substr(1, str.length()-2);
            	        $$ = new NPrintStmt(str + "\n", nullptr); }
            	| PRINTLN expr { $$ = new NPrintStmt("%d\n", $2); }
            	;

read_stmt       : READ ident { $$ = new NReadStmt($2); }
		        ;

return_stmt     : RETURN expr SC { $$ = new NReturnStmt($2); }

%%

void yyerror (char const *s)
{
    errors++;
	  printf("Error: %s\n", s);
}

int main(int argc, char *argv[])
{
    if (argc == 1 ) {
		    fprintf(stderr, "Correct usage: xlang filename\n");
		    exit(1);
    }

  	if (argc > 2) {
  		  fprintf(stderr, "Passing more arguments than necessary.\n");
  		  fprintf(stderr, "Correct usage: xlang filename\n");
  	}

  	yyin = fopen(argv[1], "r");

  	if (yyin == NULL){
  		  printf("Can't open the given file!\n");
  		  exit(-1);
  	}

  	do {
  		  yyparse();
  	} while (!feof(yyin));

  	if (root) {
  		generateCode(root);
  	}

  	return 0;
}
