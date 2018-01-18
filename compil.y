%{
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

extern FILE *yyin;

struct node {
    double data;
    struct node* next;
};

struct linked_list {
    struct node* start;
    struct node* end;
};



typedef struct YYLTYPE
{
	int fl;
	int fc;
	int ll;
	int lc;
} YYLTYPE;

int isError = 0; //0: there is no error so print result; 1: there is an error so don't print
int isFile = 0; //0: we read from an stdin; 1: we read from a file specified in argument

double moyenne(struct linked_list* list);
double somme(struct linked_list* list);
double produit(struct linked_list* list);
double variance(struct linked_list* list);
double ecartType(struct linked_list* list);
int yyerror(char *err);
int yylex();
%}


%union{
	double value; //for operands
	char symbol; //for operators
	char* string; //for functions
	struct linked_list* list; //for function's arguments
}


%token <value>  NUMBER
%token <symbol> PLUS MINUS TIMES DIVIDE POWER
%token <symbol> LEFT RIGHT
%token <string> EXIT MOYENNE SOMME PRODUCT VARIANCE ECARTTYPE
%token <symbol> COMMA 
%token <symbol> END


%left PLUS MINUS
%left TIMES DIVIDE
%left MODUL
%left NEG
%right POWER

%type <value> Expression Input Function Name

%type <list> List

%start Input
%%

Input:	/*empty*/ { if (!isFile) printf("> ");}
      | Input Line
;

Line:
     END { if (!isFile) printf("> ");}
     | Expression END { if (!isError){
     						 printf("Resultat: %f\n", $1);

     					}	 
     					 isError = 0;
     					 if (!isFile) printf("> "); }
     | EXIT { exit(EXIT_SUCCESS);}
;

Expression:
     NUMBER { $$=$1; }
	| Expression PLUS Expression { $$=$1+$3; }
	| Expression PLUS error { yyerror("Opérande attendue\n"); yyerrok; isError = 1;}
	| Expression MINUS Expression { $$=$1-$3; }
	| Expression MINUS error { yyerror("Opérande attendue\n"); yyerrok; isError = 1;}
	| Expression TIMES Expression { $$=$1*$3; }
	| Expression TIMES error { yyerror("Opérande attendue\n"); yyerrok; isError = 1;}
	| Expression DIVIDE Expression { 
				if($3 == 0) 
				{
					yyerror("Erreur! Division par 0\n");
				}
				else $$=$1/$3; 
			}
	| Expression DIVIDE error {  yyerror("Opérande attendue\n"); yyerrok; isError = 1;}
	| MINUS Expression %prec NEG { $$=-$2; }
	| Expression POWER Expression { $$=pow($1,$3); }
	| Expression POWER error { yyerror("Opérande attendue\n"); yyerrok; isError = 1;}
	| LEFT Expression RIGHT { $$=$2; }
	| LEFT Expression error { yyerror("')' attendue\n"); yyerrok; isError = 1;}
	| Function { $$ = $1;	}

;

Function: Name LEFT List RIGHT{
			struct linked_list* list = $3;
			int numFunction = $1;
			if(list)
			{
				switch (numFunction)
				{
					case 1: //si c'est la moyenne
						$$ = moyenne(list);
						break;
					case 2: //si c'est la somme
						$$ = somme(list);
						break;
					case 3: //si c'est le produit
						$$ = produit(list);
						break;
					case 4: //si c'est la variance
						$$ = variance(list);
						break;
					case 5: //si c'est l'ecart type
						$$ = ecartType(list);
						break;
				}
			} 
			
		}
		| Name error List RIGHT { yyerror("'(' attendue\n"); yyerrok; isError =1;}
		| Name LEFT List error { yyerror("')' attendue\n"); yyerrok; isError =1;}

;

Name: MOYENNE { $$ = 1;}
	| SOMME { $$ = 2;}
	| PRODUCT { $$ = 3;}
	| VARIANCE { $$ = 4;}
	| ECARTTYPE { $$ = 5;}
;

List: List COMMA Expression {
		if(!isError){
			struct node* node = malloc(sizeof(struct node));
		    double val = $3; 
		    node->data = val;
		    node->next = NULL;
		    struct linked_list* list = $1;
		    list->end->next = node;
		    list->end = node;

		    $$ = list;
		}
        
	}
	| Expression {
		if(!isError){
			struct linked_list* list = malloc(sizeof(struct linked_list));
		 	struct node* node = malloc(sizeof(struct node));
			double val = $1;
			node->data = val;
			node->next = NULL;
			list->start = node;
			list->end = node;
			$$ = list;
		}
	    
	}
	| error COMMA Expression { yyerror("Argument attendu avant ','\n"); yyerrok; isError = 1;}
	| List COMMA error { yyerror("Argument attendu apres ','\n"); yyerrok; isError = 1;}
	
;

%%

int yyerror(char *err) {
  fprintf(stderr,"%s\n", err);
}


int main(int argc, char* argv[]) {
  if (argc>1){
  		yyin = fopen(argv[1],"r");
  		if (yyin != NULL)
  		{
  			isFile = 1;
  			yyparse();
  			fclose(yyin);
  			return 0;
  		}
  		else printf("Impossible d'ouvrir le fichier %s\n",argv[1]);

  }
  else 
  {
  	return yyparse();
  }
}



double somme(struct linked_list* list)
{
	
	struct node* node = list->start;
	double sumOfElements = 0;
	while (node != NULL)
	{
		sumOfElements += node->data;
		node = node->next;
	}
	return sumOfElements;
}

double moyenne(struct linked_list* list)
{
	
	int nbElements = 0;
	double sumOfElements = 0;
	struct node* node = list->start;
	while(node != NULL)
	{
		sumOfElements += node->data;
		nbElements += 1;
		node = node->next;
	}
	return (sumOfElements/nbElements);				
}

double produit(struct linked_list* list)
{
	
	struct node* node = list->start;
	double productOfElements = 1;
	while (node != NULL)
	{
		productOfElements *= node->data;
		node = node->next;
	}
	return productOfElements;	
}

double variance(struct linked_list* list)
{
	double esperance = moyenne(list);
	struct linked_list* listCarre = malloc(sizeof(struct linked_list));
 	struct node* node = malloc(sizeof(struct node));
	struct node* nodeParcours = list->start;
 	
 	listCarre->start = node;
	node->next = NULL;
	
	//obtenir une list avec des elements au carre
 	while (nodeParcours != NULL)
 	{
 		node->data = nodeParcours->data * nodeParcours->data;
 		listCarre->end = node;
 		node->next = malloc(sizeof(struct node));
 		node = node->next;
 		nodeParcours = nodeParcours->next;
 	}

 	listCarre->end->next = NULL;
	
	double momentOrdreDeux = moyenne(listCarre);
	// retourner l'ecart type E(X2)-(E(X))2
	return (momentOrdreDeux - esperance*esperance);


}

double ecartType(struct linked_list* list)
{
	
	double varianceList = variance(list);

	return (sqrt(varianceList));
}
