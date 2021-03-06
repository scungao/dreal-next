%{

#include <cstdio>
#include <cstdlib>
/* Keep the following headers in their original order */
#include "egraph/Egraph.h"
#include "invparser.hh"

#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-register"
#pragma clang diagnostic ignored "-Wnull-conversion"
#pragma clang diagnostic ignored "-Wunneeded-internal-declaration"
#endif
%}

%x start_comment
%option noyywrap
%option yylineno
%option nounput

%%

[ \t\n\r]                    { }
"#".*                        { }
"var"                        { return TK_VAR; }
"cost"                       { return TK_COST; }
"delta"                       { return TK_PREC; }
"ctr"                        { return TK_CTR; }
"plant"                      { return TK_PLANT; }
"param"			     { return TK_PARAM; }
"control"                    { return TK_CONTROL; }
"lyf"			     { return TK_LYF; }
"barrier"		     { return TK_BARRIER; }
"barrierD"		     { return TK_BARRIERD; }
"epsilon"		     { return TK_EPSILON; }
"d/dt"			     { return TK_DEV; }

","                          { return TK_COMMA; }
":"                          { return TK_COLON; }
";"                          { return TK_SEMICOLON; }
"+"                          { return TK_PLUS; }
"-"                          { return TK_MINUS; }
"*"                          { return TK_TIMES; }
"/"                          { return TK_DIV; }
"="                          { return TK_EQ; }
"!="                         { return TK_NEQ; }
"<="                         { return TK_LEQ; }
">="                         { return TK_GEQ; }
"<"                          { return TK_LT; }
">"                          { return TK_GT; }
"("                          { return TK_LP; }
")"                          { return TK_RP; }
"{"                          { return TK_LC; }
"}"                          { return TK_RC; }
"["                          { return TK_LB; }
"]"                          { return TK_RB; }
"||"                         { return TK_OR; }
"&&"                         { return TK_AND; }
"sin"                        { return TK_SIN; }
"cos"                        { return TK_COS; }
"tan"                        { return TK_TAN; }
"exp"                        { return TK_EXP; }
"log"                        { return TK_LOG; }
"abs"                        { return TK_ABS; }
"asin"|"arcsin"              { return TK_ASIN; }
"acos"|"arccos"              { return TK_ACOS; }
"atan"|"arctan"              { return TK_ATAN; }
"sinh"                       { return TK_SINH; }
"cosh"                       { return TK_COSH; }
"tanh"                       { return TK_TANH; }
"min"                        { return TK_MIN; }
"max"                        { return TK_MAX; }
"atan2"|"arctan2"            { return TK_ATAN2; }
"matan"|"marctan"            { return TK_MATAN; }
"sqrt"                       { return TK_SQRT; }
"safesqrt"                   { return TK_SAFESQRT; }
"^"|"pow"                    { return TK_POW; }

((([0-9]+)|([0-9]*\.?[0-9]+))([eE][-+]?[0-9]+)?)   { invlval.str = strdup(yytext); return TK_NUM; }
((([0-9]+)|([0-9]+\.)))                            { invlval.str = strdup(yytext); return TK_NUM; }
[a-zA-Z]([a-zA-Z0-9_])*                            { invlval.str = strdup(yytext); return TK_ID; }

\".*\"          { invlval.str = strdup( yytext ); return TK_STR; }
.               { printf( "Syntax error at line %d near %s\n", yylineno, yytext ); exit( 1 ); }

%%

#ifdef __clang__
#pragma clang diagnostic pop
#endif
