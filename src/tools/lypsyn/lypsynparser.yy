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

extern int lypsynlineno;
extern int lypsynlex();

// ===========
// The result
// ===========
OpenSMTContext * lypsyn_ctx;
double lypsyn_prec; 
unordered_map<Enode*,Enode*> lypsyn_plant;
unordered_map<Enode*,Enode*> lypsyn_control;
Enode * lypsyn_lyf;
unordered_map<string, Enode*> lypsyn_var_map;
unordered_map<string, Enode*> lypsyn_param_map;

vector< string > * createNumeralList  ( const char * );
vector< string > * pushNumeralList    ( vector< string > *, const char * );
void               destroyNumeralList ( vector< string > * );

list< Snode * > * createSortList  ( Snode * );
list< Snode * > * pushSortList    ( list< Snode * > *, Snode * );
void              destroySortList ( list< Snode * > * );

void lypsynerror( const char * s )
{
  printf( "At line %d: %s\n", lypsynlineno, s );
  exit( 1 );
}

void lypsyn_init_parser() {
    lypsyn_ctx = new OpenSMTContext();
    lypsyn_ctx->SetLogic(QF_NRA);
    lypsyn_prec = 0.0;
}

void lypsyn_cleanup_parser() {
    delete lypsyn_ctx;
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

%token TK_VAR TK_COST TK_PREC TK_CTR TK_PLANT TK_CONTROL TK_LYF TK_DEV TK_PARAM
%token TK_COMMA TK_COLON TK_SEMICOLON TK_PLUS TK_MINUS TK_TIMES TK_DIV TK_EQ TK_NEQ TK_LEQ TK_GEQ
%token TK_LT TK_GT TK_SIN TK_COS TK_TAN TK_EXP TK_LOG TK_ABS TK_ASIN TK_ACOS TK_ATAN TK_SINH TK_COSH TK_TANH TK_MIN
%token TK_MAX TK_ATAN2 TK_MATAN TK_SQRT TK_SAFESQRT TK_POW
%token TK_LC TK_RC TK_LP TK_RP TK_LB TK_RB TK_OR TK_AND
%token TK_NUM TK_STR TK_ID

%type   <str>           TK_NUM TK_ID TK_STR
%type   <enode>         exp var_decl param_decl plant_decl control_decl lyf_decl
%type   <fp>            numeral

%left TK_AND TK_OR
%nonassoc TK_EQ TK_NEQ TK_LT TK_LEQ TK_GT TK_GEQ
%left TK_PLUS TK_MINUS
%left TK_TIMES TK_DIV
%nonassoc UMINUS
%right TK_POW

%start script

%%

script:         opt_prec_decl_sec
                var_decl_sec
		param_decl_sec
                plant_decl_sec
                control_decl_sec
                lyf_decl_sec
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

prec_decl_sec:  TK_PREC TK_COLON numeral {
                    lypsyn_prec = $3;
        }
        ;

// =============================
// Variable Declaration Section
// =============================

var_decl:       TK_LB numeral TK_COMMA numeral TK_RB TK_ID TK_SEMICOLON {
                    double const lb = $2;
                    double const ub = $4;
                    lypsyn_ctx->DeclareFun($6, lypsyn_ctx->mkSortReal());
                    Enode * e = lypsyn_ctx->mkVar($6, true);
                    e->setDomainLowerBound(lb);
                    e->setDomainUpperBound(ub);
                    lypsyn_var_map.emplace($6, e);
                    free($6);
        }
        |       numeral TK_ID TK_SEMICOLON {
                    double const c = $1;
                    lypsyn_ctx->DeclareFun($2, lypsyn_ctx->mkSortReal());
                    Enode * e = lypsyn_ctx->mkVar($2, true);
                    e->setDomainLowerBound(c);
                    e->setDomainUpperBound(c);
                    e->setValueLowerBound(c);
                    e->setValueUpperBound(c);
                    lypsyn_var_map.emplace($2, e);
                    free($2);
        }
        ;

var_decl_list:  var_decl
        |       var_decl var_decl_list
        ;

var_decl_sec:   TK_VAR TK_COLON var_decl_list
        ;

// =============================
// Parameters
// =============================

param_decl:       TK_LB numeral TK_COMMA numeral TK_RB TK_ID TK_SEMICOLON {
                    double const lb = $2;
                    double const ub = $4;
                    lypsyn_ctx->DeclareFun($6, lypsyn_ctx->mkSortReal());
                    Enode * e = lypsyn_ctx->mkVar($6, true);
                    e->setDomainLowerBound(lb);
                    e->setDomainUpperBound(ub);
                    lypsyn_param_map.emplace($6, e);
                    free($6);
        }
        |       numeral TK_ID TK_SEMICOLON {
                    double const c = $1;
                    lypsyn_ctx->DeclareFun($2, lypsyn_ctx->mkSortReal());
                    Enode * e = lypsyn_ctx->mkVar($2, true);
                    e->setDomainLowerBound(c);
                    e->setDomainUpperBound(c);
                    e->setValueLowerBound(c);
                    e->setValueUpperBound(c);
                    lypsyn_param_map.emplace($2, e);
                    free($2);
        }
        ;

param_decl_list:  param_decl
        |       param_decl param_decl_list
        ;

param_decl_sec:   TK_PARAM TK_COLON param_decl_list
        ;

// =============================
// Plant
// =============================

plant_decl:       TK_DEV TK_LB TK_ID TK_RB TK_EQ exp TK_SEMICOLON {
		Enode * var = lypsyn_ctx->mkVar($3, true);
		Enode * flow = $6;
		lypsyn_plant.emplace(var,flow);
        }
        ;

plant_decl_list:   plant_decl 
        |       plant_decl plant_decl_list 
        ;

plant_decl_sec:
                TK_PLANT TK_COLON plant_decl_list
        ;

// =============================
// Control
// =============================

control_decl:	TK_ID TK_EQ exp TK_SEMICOLON {
		Enode * var = lypsyn_ctx->mkVar($1, true);
		Enode * control = $3;
		lypsyn_control.emplace(var,control);
        }
        ;

control_decl_list:   control_decl 
        |       control_decl control_decl_list 
        ;

control_decl_sec:
                TK_CONTROL TK_COLON control_decl_list
        ;


// =============================
// Lyapunov Function
// =============================
lyf_decl:	exp TK_SEMICOLON {
		lypsyn_lyf = $1;
        }
        ;

lyf_decl_sec:	TK_LYF TK_COLON lyf_decl
	;

// =============================
// Expression
// =============================
exp:            TK_NUM          { $$ = lypsyn_ctx->mkNum($1); free($1); }
        |       TK_ID           { $$ = lypsyn_ctx->mkVar($1); free($1); }
        |       TK_LP exp TK_RP { $$ = $2; }
        |       TK_MINUS exp %prec UMINUS { $$ = lypsyn_ctx->mkUminus(lypsyn_ctx->mkCons($2)); }
        |       exp TK_PLUS exp {
            $$ = lypsyn_ctx->mkPlus(lypsyn_ctx->mkCons($1, lypsyn_ctx->mkCons($3)));
            if ($$ == nullptr) {
                yyerror("Parse Error: +");
            }
        }
        |       exp TK_MINUS exp {
            $$ = lypsyn_ctx->mkMinus(lypsyn_ctx->mkCons($1, lypsyn_ctx->mkCons($3)));
            if ($$ == nullptr) {
                yyerror("Parse Error: -");
            }
        }
        |       exp TK_TIMES exp {
            $$ = lypsyn_ctx->mkTimes(lypsyn_ctx->mkCons($1, lypsyn_ctx->mkCons($3)));
            if ($$ == nullptr) {
                yyerror("Parse Error: *");
            }
        }
        |       exp TK_DIV exp {
            $$ = lypsyn_ctx->mkDiv(lypsyn_ctx->mkCons($1, lypsyn_ctx->mkCons($3)));
            if ($$ == nullptr) {
                yyerror("Parse Error: /");
            }
        }
        |       exp TK_POW exp {
            $$ = lypsyn_ctx->mkPow(lypsyn_ctx->mkCons($1, lypsyn_ctx->mkCons($3)));
            if ($$ == nullptr) {
                yyerror("Parse Error: ^(pow)");
            }
        }
        |       TK_ABS TK_LP exp TK_RP {
            $$ = lypsyn_ctx->mkAbs(lypsyn_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: abs");
            }
        }
        |       TK_LOG TK_LP exp TK_RP {
            $$ = lypsyn_ctx->mkLog(lypsyn_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: log");
            }
        }
        |       TK_EXP TK_LP exp TK_RP {
            $$ = lypsyn_ctx->mkExp(lypsyn_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: exp");
            }
        }
        |       TK_SQRT TK_LP exp TK_RP {
            $$ = lypsyn_ctx->mkSqrt(lypsyn_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: sqrt");
            }
        }
        |       TK_SIN TK_LP exp TK_RP {
            $$ = lypsyn_ctx->mkSin(lypsyn_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: sin");
            }
                }
        |       TK_COS TK_LP exp TK_RP {
            $$ = lypsyn_ctx->mkCos(lypsyn_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: cos");
            }
        }
        |       TK_TAN TK_LP exp TK_RP {
            $$ = lypsyn_ctx->mkTan(lypsyn_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: tan");
            }
        }
        |       TK_SINH TK_LP exp TK_RP {
            $$ = lypsyn_ctx->mkSinh(lypsyn_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: sinh");
            }
        }
        |       TK_COSH TK_LP exp TK_RP {
            $$ = lypsyn_ctx->mkCosh(lypsyn_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: cosh");
            }
        }
        |       TK_TANH TK_LP exp TK_RP {
            $$ = lypsyn_ctx->mkTanh(lypsyn_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: tanh");
            }
        }
        |       TK_ASIN TK_LP exp TK_RP {
            $$ = lypsyn_ctx->mkAsin(lypsyn_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: asin");
            }
        }
        |       TK_ACOS TK_LP exp TK_RP {
            $$ = lypsyn_ctx->mkAcos(lypsyn_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: acos");
            }
        }
        |       TK_ATAN TK_LP exp TK_RP {
            $$ = lypsyn_ctx->mkAtan(lypsyn_ctx->mkCons($3));
            if ($$ == nullptr) {
                yyerror("Parse Error: atan");
            }
        }
        |       TK_ATAN2 TK_LP exp ',' exp TK_RP {
            $$ = lypsyn_ctx->mkAtan2(lypsyn_ctx->mkCons($3, lypsyn_ctx->mkCons($5)));
            if ($$ == nullptr) {
                yyerror("Parse Error: atan2");
            }
        }
;

