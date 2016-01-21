%{
#include <cstdio>
#include <cstdlib>
#include <cassert>
#include <vector>
#include <utility>
#include <string>
#include <list>
#include <limits>

#include "common/Global.h"
#include "egraph/Egraph.h"
#include "sorts/SStore.h"
#include "api/OpenSMTContext.h"

using std::vector;
using std::unordered_map;
using std::string;
using std::list;
using std::stod;
using std::numeric_limits;

extern int invlineno;
extern int invlex();

// ===========
// The result
// ===========
OpenSMTContext * inv_ctx;
double inv_prec;
double inv_epsilon; 
unordered_map<Enode*, Enode*> inv_plant;
Enode * inv_barrier;
Enode * inv_barrierD;
unordered_map<string, Enode*> inv_var_map;

vector< string > * createNumeralList  ( const char * );
vector< string > * pushNumeralList    ( vector< string > *, const char * );
void               destroyNumeralList ( vector< string > * );

list< Snode * > * createSortList  ( Snode * );
list< Snode * > * pushSortList    ( list< Snode * > *, Snode * );
void              destroySortList ( list< Snode * > * );

void inverror( const char * s )
{
  printf( "At line %d: %s\n", invlineno, s );
  exit( 1 );
}

void inv_init_parser() {
    inv_ctx = new OpenSMTContext();
    inv_ctx->SetLogic(QF_NRA);
    inv_prec = 0.0;
    inv_epsilon = 0.001;
}

void inv_cleanup_parser() {
    delete inv_ctx;
}

/* Overallocation to prevent stack overflow */
#define YYMAXDEPTH 1024 * 1024
%}

%union
{
    char  *                  str;
    Enode *                  enode;
    double                   fp;
}

%error-verbose

%token TK_VAR TK_COST TK_PREC TK_CTR TK_PLANT TK_CONTROL TK_LYF TK_DEV TK_PARAM TK_BARRIER TK_BARRIERD TK_EPSILON
%token TK_COMMA TK_COLON TK_SEMICOLON TK_PLUS TK_MINUS TK_TIMES TK_DIV TK_EQ TK_NEQ TK_LEQ TK_GEQ
%token TK_LT TK_GT TK_SIN TK_COS TK_TAN TK_EXP TK_LOG TK_ABS TK_ASIN TK_ACOS TK_ATAN TK_SINH TK_COSH TK_TANH TK_MIN
%token TK_MAX TK_ATAN2 TK_MATAN TK_SQRT TK_SAFESQRT TK_POW
%token TK_LC TK_RC TK_LP TK_RP TK_LB TK_RB TK_OR TK_AND
%token TK_NUM TK_STR TK_ID

%type   <str>           TK_NUM TK_ID TK_STR
%type   <enode>         exp var_decl plant_decl barrier_decl barrierD_decl
%type   <fp>            numeral

%left TK_AND TK_OR
%nonassoc TK_EQ TK_NEQ TK_LT TK_LEQ TK_GT TK_GEQ
%left TK_PLUS TK_MINUS
%left TK_TIMES TK_DIV
%nonassoc UMINUS
%right TK_POW

%start script

%%

script:         opt_epsilon_decl_sec
                opt_prec_decl_sec
		var_decl_sec
                plant_decl_sec
                barrier_decl_sec
                opt_barrierD_decl_sec
        ;

numeral:        TK_NUM {
                    $$ = stod($1, nullptr);
                    free($1);
        }
        |       TK_MINUS TK_NUM {
                    $$ = -stod($2, nullptr);
                    free($2);
        }
        ;

opt_prec_decl_sec:
                /* nothing */
        |       prec_decl_sec
        ;

prec_decl_sec:  TK_PREC TK_COLON numeral TK_SEMICOLON {
                    inv_prec = $3;
        }
        ;

opt_epsilon_decl_sec:
	|	epsilon_decl_sec
	;

epsilon_decl_sec: TK_EPSILON TK_COLON numeral TK_SEMICOLON {
		inv_epsilon = $3;
	}

// =============================
// Variable Declaration Section
// =============================

var_decl:       TK_LB numeral TK_COMMA numeral TK_RB TK_ID TK_SEMICOLON {
                    double const lb = $2;
                    double const ub = $4;
                    inv_ctx->DeclareFun($6, inv_ctx->mkSortReal());
                    Enode * e = inv_ctx->mkVar($6, true);
                    e->setDomainLowerBound(lb);
                    e->setDomainUpperBound(ub);
                    inv_var_map.emplace($6, e);
                    free($6);
        }
        |       numeral TK_ID TK_SEMICOLON {
                    double const c = $1;
                    inv_ctx->DeclareFun($2, inv_ctx->mkSortReal());
                    Enode * e = inv_ctx->mkVar($2, true);
                    e->setDomainLowerBound(c);
                    e->setDomainUpperBound(c);
                    e->setValueLowerBound(c);
                    e->setValueUpperBound(c);
                    inv_var_map.emplace($2, e);
                    free($2);
        }
        ;

var_decl_list:  var_decl
        |       var_decl var_decl_list
        ;

var_decl_sec:   TK_VAR TK_COLON var_decl_list
        ;

// =============================
// Plant
// =============================

plant_decl:       TK_DEV TK_LB TK_ID TK_RB TK_EQ exp TK_SEMICOLON {
		Enode * var = inv_ctx->mkVar($3, true);
		Enode * flow = $6;
		inv_plant.emplace(var,flow);
        }
        ;

plant_decl_list:   plant_decl 
        |       plant_decl plant_decl_list 
        ;

plant_decl_sec:
                TK_PLANT TK_COLON plant_decl_list
        ;

// =============================
// Barrier Function
// =============================
barrier_decl:	exp TK_SEMICOLON {
		inv_barrier = $1;
        }
        ;

barrier_decl_sec:	TK_BARRIER TK_COLON barrier_decl
	;


// =============================
// Barrier Derivative
// =============================
barrierD_decl:	exp TK_SEMICOLON {
		inv_barrierD = $1;
        }
        ;

opt_barrierD_decl_sec:
	|	TK_BARRIERD TK_COLON barrierD_decl
	;


// =============================
// Expression
// =============================
exp:            TK_NUM          { $$ = inv_ctx->mkNum($1); free($1); }
        |       TK_ID           { $$ = inv_ctx->mkVar($1); free($1); }
        |       TK_LP exp TK_RP { $$ = $2; }
        |       TK_MINUS exp %prec UMINUS { $$ = inv_ctx->mkUminus(inv_ctx->mkCons($2)); }
        |       exp TK_PLUS exp {
            $$ = inv_ctx->mkPlus(inv_ctx->mkCons($1, inv_ctx->mkCons($3)));
            if ($$ == nullptr) {
                yyerror("Parse Error: +");
            }
        }
        |       exp TK_MINUS exp {
            $$ = inv_ctx->mkMinus(inv_ctx->mkCons($1, inv_ctx->mkCons($3)));
            if ($$ == nullptr) {
                yyerror("Parse Error: -");
            }
        }
        |       exp TK_TIMES exp {
            $$ = inv_ctx->mkTimes(inv_ctx->mkCons($1, inv_ctx->mkCons($3)));
            if ($$ == nullptr) {
                yyerror("Parse Error: *");
            }
        }
        |       exp TK_DIV exp {
            $$ = inv_ctx->mkDiv(inv_ctx->mkCons($1, inv_ctx->mkCons($3)));
            if ($$ == nullptr) {
                yyerror("Parse Error: /");
            }
        }
        |       exp TK_POW exp {
            $$ = inv_ctx->mkPow(inv_ctx->mkCons($1, inv_ctx->mkCons($3)));
            if ($$ == nullptr) {
                yyerror("Parse Error: ^(pow)");
            }
        }
        |       TK_ABS TK_LP exp TK_RP {
            $$ = inv_ctx->mkAbs(inv_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: abs");
            }
        }
        |       TK_LOG TK_LP exp TK_RP {
            $$ = inv_ctx->mkLog(inv_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: log");
            }
        }
        |       TK_EXP TK_LP exp TK_RP {
            $$ = inv_ctx->mkExp(inv_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: exp");
            }
        }
        |       TK_SQRT TK_LP exp TK_RP {
            $$ = inv_ctx->mkSqrt(inv_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: sqrt");
            }
        }
        |       TK_SIN TK_LP exp TK_RP {
            $$ = inv_ctx->mkSin(inv_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: sin");
            }
                }
        |       TK_COS TK_LP exp TK_RP {
            $$ = inv_ctx->mkCos(inv_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: cos");
            }
        }
        |       TK_TAN TK_LP exp TK_RP {
            $$ = inv_ctx->mkTan(inv_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: tan");
            }
        }
        |       TK_SINH TK_LP exp TK_RP {
            $$ = inv_ctx->mkSinh(inv_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: sinh");
            }
        }
        |       TK_COSH TK_LP exp TK_RP {
            $$ = inv_ctx->mkCosh(inv_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: cosh");
            }
        }
        |       TK_TANH TK_LP exp TK_RP {
            $$ = inv_ctx->mkTanh(inv_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: tanh");
            }
        }
        |       TK_ASIN TK_LP exp TK_RP {
            $$ = inv_ctx->mkAsin(inv_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: asin");
            }
        }
        |       TK_ACOS TK_LP exp TK_RP {
            $$ = inv_ctx->mkAcos(inv_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: acos");
            }
        }
        |       TK_ATAN TK_LP exp TK_RP {
            $$ = inv_ctx->mkAtan(inv_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: atan");
            }
        }
        |       TK_ATAN2 TK_LP exp ',' exp TK_RP {
            $$ = inv_ctx->mkAtan2(inv_ctx->mkCons($3, inv_ctx->mkCons($5)));
            if ($$ == nullptr) {
                yyerror("Parse Error: atan2");
            }
        }
;

