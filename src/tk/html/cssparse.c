/* Driver template for the LEMON parser generator.
** The author disclaims copyright to this source code.
*/
/* First off, code is include which follows the "include" declaration
** in the input file. */
#include <stdio.h>
#line 48 "cssparse.lem"

#include "cssInt.h"
#include <string.h>
#include <ctype.h>
#line 14 "cssparse.c"
/* Next is all token values, in a form suitable for use by makeheaders.
** This section will be null unless lemon is run with the -m switch.
*/
/* 
** These constants (all generated automatically by the parser generator)
** specify the various kinds of tokens (terminals) that the parser
** understands. 
**
** Each symbol here is a terminal symbol in the grammar.
*/
/* Make sure the INTERFACE macro is defined.
*/
#ifndef INTERFACE
# define INTERFACE 1
#endif
/* The next thing included is series of defines which control
** various aspects of the generated parser.
**    YYCODETYPE         is the data type used for storing terminal
**                       and nonterminal numbers.  "unsigned char" is
**                       used if there are fewer than 250 terminals
**                       and nonterminals.  "int" is used otherwise.
**    YYNOCODE           is a number of type YYCODETYPE which corresponds
**                       to no legal terminal or nonterminal number.  This
**                       number is used to fill in empty slots of the hash 
**                       table.
**    YYFALLBACK         If defined, this indicates that one or more tokens
**                       have fall-back values which should be used if the
**                       original value of the token will not parse.
**    YYACTIONTYPE       is the data type used for storing terminal
**                       and nonterminal numbers.  "unsigned char" is
**                       used if there are fewer than 250 rules and
**                       states combined.  "int" is used otherwise.
**    tkhtmlCssParserTOKENTYPE     is the data type used for minor tokens given 
**                       directly to the parser from the tokenizer.
**    YYMINORTYPE        is the data type used for all minor tokens.
**                       This is typically a union of many types, one of
**                       which is tkhtmlCssParserTOKENTYPE.  The entry in the union
**                       for base tokens is called "yy0".
**    YYSTACKDEPTH       is the maximum depth of the parser's stack.
**    tkhtmlCssParserARG_SDECL     A static variable declaration for the %extra_argument
**    tkhtmlCssParserARG_PDECL     A parameter declaration for the %extra_argument
**    tkhtmlCssParserARG_STORE     Code to store %extra_argument into yypParser
**    tkhtmlCssParserARG_FETCH     Code to extract %extra_argument from yypParser
**    YYNSTATE           the combined number of states.
**    YYNRULE            the number of rules in the grammar
**    YYERRORSYMBOL      is the code number of the error symbol.  If not
**                       defined, then do no error processing.
*/
#define YYCODETYPE unsigned char
#define YYNOCODE 68
#define YYACTIONTYPE unsigned char
#define tkhtmlCssParserTOKENTYPE CssToken
typedef union {
  tkhtmlCssParserTOKENTYPE yy0;
  int yy62;
  int yy135;
} YYMINORTYPE;
#define YYSTACKDEPTH 100
#define tkhtmlCssParserARG_SDECL CssParse *pParse;
#define tkhtmlCssParserARG_PDECL ,CssParse *pParse
#define tkhtmlCssParserARG_FETCH CssParse *pParse = yypParser->pParse
#define tkhtmlCssParserARG_STORE yypParser->pParse = pParse
#define YYNSTATE 165
#define YYNRULE 85
#define YYERRORSYMBOL 30
#define YYERRSYMDT yy135
#define YY_NO_ACTION      (YYNSTATE+YYNRULE+2)
#define YY_ACCEPT_ACTION  (YYNSTATE+YYNRULE+1)
#define YY_ERROR_ACTION   (YYNSTATE+YYNRULE)

/* Next are that tables used to determine what action to take based on the
** current state and lookahead token.  These tables are used to implement
** functions that take a state number and lookahead value and return an
** action integer.  
**
** Suppose the action integer is N.  Then the action is determined as
** follows
**
**   0 <= N < YYNSTATE                  Shift N.  That is, push the lookahead
**                                      token onto the stack and goto state N.
**
**   YYNSTATE <= N < YYNSTATE+YYNRULE   Reduce by rule N-YYNSTATE.
**
**   N == YYNSTATE+YYNRULE              A syntax error has occurred.
**
**   N == YYNSTATE+YYNRULE+1            The parser accepts its input.
**
**   N == YYNSTATE+YYNRULE+2            No such action.  Denotes unused
**                                      slots in the yy_action[] table.
**
** The action table is constructed as a single large table named yy_action[].
** Given state S and lookahead X, the action is computed as
**
**      yy_action[ yy_shift_ofst[S] + X ]
**
** If the index value yy_shift_ofst[S]+X is out of range or if the value
** yy_lookahead[yy_shift_ofst[S]+X] is not equal to X or if yy_shift_ofst[S]
** is equal to YY_SHIFT_USE_DFLT, it means that the action is not in the table
** and that yy_default[S] should be used instead.  
**
** The formula above is for computing the action when the lookahead is
** a terminal symbol.  If the lookahead is a non-terminal (as occurs after
** a reduce action) then the yy_reduce_ofst[] array is used in place of
** the yy_shift_ofst[] array and YY_REDUCE_USE_DFLT is used in place of
** YY_SHIFT_USE_DFLT.
**
** The following are the tables generated in this section:
**
**  yy_action[]        A single table containing all actions.
**  yy_lookahead[]     A table containing the lookahead for each entry in
**                     yy_action.  Used to detect hash collisions.
**  yy_shift_ofst[]    For each state, the offset into yy_action for
**                     shifting terminals.
**  yy_reduce_ofst[]   For each state, the offset into yy_action for
**                     shifting non-terminals after a reduce.
**  yy_default[]       Default action for each state.
*/
static const YYACTIONTYPE yy_action[] = {
 /*     0 */   108,   10,  167,   25,  114,  167,  138,   16,  167,  167,
 /*    10 */   156,   26,  167,  167,  161,  110,  111,  112,  167,  167,
 /*    20 */   155,   34,   31,  167,   27,  157,  108,   11,  251,    1,
 /*    30 */    22,   51,   15,  150,   16,   31,  156,   26,  139,   16,
 /*    40 */   109,  110,  111,  112,   97,  163,  155,   34,   21,  104,
 /*    50 */    27,  157,  108,   21,   65,   49,   22,   66,   15,  150,
 /*    60 */    16,   68,  156,   26,   85,   86,   87,  104,   44,   38,
 /*    70 */    72,  104,  155,   34,  120,  104,   27,  157,  108,   18,
 /*    80 */    69,    9,   22,  103,   15,  150,   16,   70,  156,   26,
 /*    90 */   142,   28,   89,   91,   44,   62,  132,   71,  155,   34,
 /*   100 */   165,  104,   27,  157,   31,   74,   11,   49,   22,  159,
 /*   110 */    15,  150,   16,   18,  128,  101,  153,   17,   19,   49,
 /*   120 */    32,  151,    6,   66,  131,   95,  154,   14,  115,  152,
 /*   130 */    85,   86,   87,  153,  148,   19,   93,  153,  151,  144,
 /*   140 */    66,  131,  151,   40,   66,  145,  152,   85,   86,   87,
 /*   150 */   152,   85,   86,   87,  104,   41,  122,  158,   83,   46,
 /*   160 */    10,  104,   76,  133,   12,   83,   18,  128,   63,    2,
 /*   170 */    42,   78,   79,   18,  128,   80,  106,   61,  104,  123,
 /*   180 */    10,  129,   83,  160,   64,   82,   88,  134,  129,   84,
 /*   190 */    18,  128,   22,   45,   15,  150,   16,   47,   48,   90,
 /*   200 */   100,   67,  137,   92,   20,  129,    3,   22,   35,   15,
 /*   210 */   150,   16,   73,   39,   75,   13,  116,  117,   58,  118,
 /*   220 */   119,  130,    4,    8,   59,  135,  136,   94,   23,   54,
 /*   230 */    57,   24,  162,   98,   99,  164,  102,  105,   96,  107,
 /*   240 */    33,   77,  113,    5,   37,   36,  143,  121,  124,  125,
 /*   250 */    81,  126,  127,   43,  140,  141,   60,  154,   52,  149,
 /*   260 */     7,   53,   50,   29,   56,   55,  154,  154,  154,  146,
 /*   270 */   154,   30,  147,
};
static const YYCODETYPE yy_lookahead[] = {
 /*     0 */    30,    7,    7,   33,   10,   10,   63,   64,   13,    9,
 /*    10 */    40,   41,   17,   13,   44,   45,   46,   47,   18,   19,
 /*    20 */    50,   51,    4,   28,   54,   55,   30,    9,   31,   32,
 /*    30 */    60,   34,   62,   63,   64,    4,   40,   41,   63,   64,
 /*    40 */    44,   45,   46,   47,   38,   39,   50,   51,   37,   30,
 /*    50 */    54,   55,   30,   37,   34,   49,   60,   14,   62,   63,
 /*    60 */    64,   42,   40,   41,   21,   22,   23,   30,   46,   58,
 /*    70 */    48,   30,   50,   51,   58,   30,   54,   55,   30,   42,
 /*    80 */    43,   61,   60,   42,   62,   63,   64,   42,   40,   41,
 /*    90 */    24,   25,   26,   27,   46,   34,   48,   39,   50,   51,
 /*   100 */     0,   30,   54,   55,    4,   34,    9,   49,   60,   39,
 /*   110 */    62,   63,   64,   42,   43,    7,    7,    9,    9,   49,
 /*   120 */    11,   12,    9,   14,   15,   16,   13,   66,   57,   20,
 /*   130 */    21,   22,   23,    7,   12,    9,   14,    7,   12,    6,
 /*   140 */    14,   15,   12,    4,   14,   12,   20,   21,   22,   23,
 /*   150 */    20,   21,   22,   23,   30,   13,    6,   12,   34,    4,
 /*   160 */     7,   30,   12,   10,   37,   34,   42,   43,   18,   34,
 /*   170 */    28,   21,   22,   42,   43,   12,   30,   53,   30,   29,
 /*   180 */     7,   57,   34,   10,   53,   22,   65,   55,   57,   14,
 /*   190 */    42,   43,   60,   56,   62,   63,   64,   18,   19,   65,
 /*   200 */    34,   53,   55,   65,   34,   57,   34,   60,   34,   62,
 /*   210 */    63,   64,   52,   17,   34,   34,   59,   34,   34,   34,
 /*   220 */    34,   34,   34,   34,   34,   34,   34,   34,   34,    5,
 /*   230 */    35,   34,   34,   34,   34,   34,   10,   10,   36,   10,
 /*   240 */     9,   22,   10,    9,   14,   12,   24,   12,   12,   12,
 /*   250 */    22,   12,   12,   12,   12,   12,   12,   67,    8,   12,
 /*   260 */     9,    7,   13,   25,    7,    6,   67,   67,   67,   24,
 /*   270 */    67,   25,   24,
};
#define YY_SHIFT_USE_DFLT (-7)
#define YY_SHIFT_MAX 99
static const short yy_shift_ofst[] = {
 /*     0 */    31,  109,  109,  126,  126,   18,   18,   18,  130,  130,
 /*    10 */    18,   97,  145,  150,  150,   43,   43,   97,   97,   97,
 /*    20 */   145,  139,  155,  145,  150,  100,  108,  113,  133,  133,
 /*    30 */   133,   31,   31,   31,   31,  175,   31,   31,  196,   31,
 /*    40 */    31,   31,   31,   31,   31,   31,   31,   31,   31,   31,
 /*    50 */    31,  224,   31,   31,   31,   31,   31,   -7,   -5,    0,
 /*    60 */    66,   -6,  142,  163,  153,  179,  122,  173,  226,  227,
 /*    70 */   229,  231,  232,  234,  233,  230,  219,  235,  236,  237,
 /*    80 */   228,  239,  240,  233,  241,  242,  243,  244,  222,  238,
 /*    90 */   245,  246,  248,  247,  249,  251,  250,  254,  259,  257,
};
#define YY_REDUCE_USE_DFLT (-58)
#define YY_REDUCE_MAX 57
static const short yy_reduce_ofst[] = {
 /*     0 */    -3,  -30,   -4,   22,   48,  124,  131,  148,  132,  147,
 /*    10 */    71,   37,    6,   11,   16,  -57,  -25,   19,   41,   45,
 /*    20 */    58,   61,   20,   70,  127,  135,  146,  137,  121,  134,
 /*    30 */   138,  166,  170,  172,  174,  160,  180,  181,  157,  183,
 /*    40 */   184,  185,  186,  187,  188,  189,  190,  191,  192,  193,
 /*    50 */   194,  195,  197,  198,  199,  200,  201,  202,
};
static const YYACTIONTYPE yy_default[] = {
 /*     0 */   166,  250,  250,  250,  198,  166,  166,  166,  250,  250,
 /*    10 */   166,  250,  174,  250,  250,  220,  224,  250,  180,  250,
 /*    20 */   250,  166,  166,  250,  250,  166,  250,  250,  250,  250,
 /*    30 */   250,  166,  166,  166,  166,  195,  166,  166,  212,  166,
 /*    40 */   166,  166,  166,  166,  166,  166,  166,  166,  166,  166,
 /*    50 */   166,  170,  166,  166,  166,  166,  166,  172,  240,  217,
 /*    60 */   250,  250,  236,  250,  250,  213,  250,  250,  250,  250,
 /*    70 */   250,  250,  250,  250,  208,  250,  241,  250,  250,  250,
 /*    80 */   247,  250,  250,  250,  250,  250,  250,  250,  250,  250,
 /*    90 */   250,  250,  250,  250,  191,  250,  168,  250,  250,  250,
 /*   100 */   167,  175,  176,  181,  183,  182,  178,  177,  179,  185,
 /*   110 */   186,  187,  188,  189,  193,  207,  209,  211,  238,  239,
 /*   120 */   237,  246,  242,  243,  244,  245,  249,  248,  210,  206,
 /*   130 */   194,  196,  199,  200,  204,  215,  216,  214,  218,  225,
 /*   140 */   226,  227,  228,  229,  234,  235,  230,  231,  232,  233,
 /*   150 */   219,  221,  222,  223,  205,  201,  202,  203,  190,  192,
 /*   160 */   197,  184,  171,  173,  169,
};
#define YY_SZ_ACTTAB (sizeof(yy_action)/sizeof(yy_action[0]))

/* The next table maps tokens into fallback tokens.  If a construct
** like the following:
** 
**      %fallback ID X Y Z.
**
** appears in the grammer, then ID becomes a fallback token for X, Y,
** and Z.  Whenever one of the tokens X, Y, or Z is input to the parser
** but it does not parse, the type of the token is changed to ID and
** the parse is retried before an error is thrown.
*/
#ifdef YYFALLBACK
static const YYCODETYPE yyFallback[] = {
};
#endif /* YYFALLBACK */

/* The following structure represents a single element of the
** parser's stack.  Information stored includes:
**
**   +  The state number for the parser at this level of the stack.
**
**   +  The value of the token stored at this level of the stack.
**      (In other words, the "major" token.)
**
**   +  The semantic value stored at this level of the stack.  This is
**      the information used by the action routines in the grammar.
**      It is sometimes called the "minor" token.
*/
struct yyStackEntry {
  int stateno;       /* The state-number */
  int major;         /* The major token value.  This is the code
                     ** number for the token at this stack level */
  YYMINORTYPE minor; /* The user-supplied minor token value.  This
                     ** is the value of the token  */
};
typedef struct yyStackEntry yyStackEntry;

/* The state of the parser is completely contained in an instance of
** the following structure */
struct yyParser {
  int yyidx;                    /* Index of top element in stack */
  int yyerrcnt;                 /* Shifts left before out of the error */
  tkhtmlCssParserARG_SDECL                /* A place to hold %extra_argument */
  yyStackEntry yystack[YYSTACKDEPTH];  /* The parser's stack */
};
typedef struct yyParser yyParser;

#ifndef NDEBUG
#include <stdio.h>
static FILE *yyTraceFILE = 0;
static char *yyTracePrompt = 0;
#endif /* NDEBUG */

#ifndef NDEBUG
/* 
** Turn parser tracing on by giving a stream to which to write the trace
** and a prompt to preface each trace message.  Tracing is turned off
** by making either argument NULL 
**
** Inputs:
** <ul>
** <li> A FILE* to which trace output should be written.
**      If NULL, then tracing is turned off.
** <li> A prefix string written at the beginning of every
**      line of trace output.  If NULL, then tracing is
**      turned off.
** </ul>
**
** Outputs:
** None.
*/
void tkhtmlCssParserTrace(FILE *TraceFILE, char *zTracePrompt){
  yyTraceFILE = TraceFILE;
  yyTracePrompt = zTracePrompt;
  if( yyTraceFILE==0 ) yyTracePrompt = 0;
  else if( yyTracePrompt==0 ) yyTraceFILE = 0;
}
#endif /* NDEBUG */

#ifndef NDEBUG
/* For tracing shifts, the names of all terminals and nonterminals
** are required.  The following table supplies these names */
static const char *const yyTokenName[] = { 
  "$",             "RRP",           "UNKNOWN_SYM",   "INVALID_AT_SYM",
  "SPACE",         "CHARSET_SYM",   "STRING",        "SEMICOLON",   
  "IMPORT_SYM",    "LP",            "RP",            "MEDIA_SYM",   
  "IDENT",         "COMMA",         "COLON",         "PAGE_SYM",    
  "FONT_SYM",      "IMPORTANT_SYM",  "PLUS",          "GT",          
  "STAR",          "HASH",          "DOT",           "LSP",         
  "RSP",           "EQUALS",        "TILDE",         "PIPE",        
  "SLASH",         "FUNCTION",      "error",         "stylesheet",  
  "ss_header",     "ss_body",       "ws",            "charset_opt", 
  "imports_opt",   "term",          "medium_list_opt",  "medium_list", 
  "toplevel_syntaxerror",  "toplevel_trash",  "declaration_trash",  "declaration_syntaxerror",
  "ss_body_item",  "media",         "ruleset",       "font_face",   
  "ruleset_list",  "medium_list_item",  "page",          "page_sym",    
  "pseudo_opt",    "declaration_list",  "selector_list",  "selector",    
  "comma",         "declaration",   "expr",          "prio",        
  "simple_selector",  "combinator",    "tag",           "simple_selector_tail",
  "simple_selector_tail_component",  "string",        "operator",    
};
#endif /* NDEBUG */

#ifndef NDEBUG
/* For tracing reduce actions, the names of all rules are required.
*/
static const char *const yyRuleName[] = {
 /*   0 */ "stylesheet ::= ss_header ss_body",
 /*   1 */ "ws ::=",
 /*   2 */ "ws ::= SPACE ws",
 /*   3 */ "ss_header ::= ws charset_opt imports_opt",
 /*   4 */ "charset_opt ::= CHARSET_SYM ws STRING ws SEMICOLON ws",
 /*   5 */ "charset_opt ::=",
 /*   6 */ "imports_opt ::= imports_opt IMPORT_SYM ws term medium_list_opt SEMICOLON ws",
 /*   7 */ "imports_opt ::=",
 /*   8 */ "medium_list_opt ::= medium_list",
 /*   9 */ "medium_list_opt ::=",
 /*  10 */ "toplevel_syntaxerror ::= toplevel_trash SEMICOLON",
 /*  11 */ "toplevel_syntaxerror ::= toplevel_trash LP declaration_trash RP",
 /*  12 */ "toplevel_syntaxerror ::= LP declaration_trash RP",
 /*  13 */ "toplevel_trash ::= toplevel_trash error",
 /*  14 */ "toplevel_trash ::= error",
 /*  15 */ "declaration_syntaxerror ::= declaration_trash",
 /*  16 */ "declaration_syntaxerror ::= declaration_trash declaration_trash",
 /*  17 */ "declaration_trash ::= LP declaration_syntaxerror RP",
 /*  18 */ "declaration_trash ::= error",
 /*  19 */ "ss_body ::= ss_body_item",
 /*  20 */ "ss_body ::= ss_body ws ss_body_item",
 /*  21 */ "ss_body_item ::= media",
 /*  22 */ "ss_body_item ::= ruleset",
 /*  23 */ "ss_body_item ::= font_face",
 /*  24 */ "media ::= MEDIA_SYM ws medium_list LP ws ruleset_list RP",
 /*  25 */ "medium_list_item ::= IDENT",
 /*  26 */ "medium_list ::= medium_list_item ws",
 /*  27 */ "medium_list ::= medium_list_item ws COMMA ws medium_list",
 /*  28 */ "page ::= page_sym ws pseudo_opt LP declaration_list RP",
 /*  29 */ "pseudo_opt ::= COLON IDENT ws",
 /*  30 */ "pseudo_opt ::=",
 /*  31 */ "page_sym ::= PAGE_SYM",
 /*  32 */ "font_face ::= FONT_SYM LP declaration_list RP",
 /*  33 */ "ruleset_list ::= ruleset ws",
 /*  34 */ "ruleset_list ::= ruleset ws ruleset_list",
 /*  35 */ "ruleset ::= selector_list LP declaration_list RP",
 /*  36 */ "ruleset ::= page",
 /*  37 */ "ruleset ::= toplevel_syntaxerror",
 /*  38 */ "selector_list ::= selector",
 /*  39 */ "selector_list ::= selector_list comma ws selector",
 /*  40 */ "comma ::= COMMA",
 /*  41 */ "declaration_list ::= declaration",
 /*  42 */ "declaration_list ::= declaration_list SEMICOLON declaration",
 /*  43 */ "declaration_list ::= declaration_list SEMICOLON ws",
 /*  44 */ "declaration ::= ws IDENT ws COLON ws expr prio",
 /*  45 */ "declaration ::= declaration_syntaxerror",
 /*  46 */ "prio ::= IMPORTANT_SYM ws",
 /*  47 */ "prio ::=",
 /*  48 */ "selector ::= simple_selector ws",
 /*  49 */ "selector ::= simple_selector combinator selector",
 /*  50 */ "combinator ::= ws PLUS ws",
 /*  51 */ "combinator ::= ws GT ws",
 /*  52 */ "combinator ::= SPACE ws",
 /*  53 */ "simple_selector ::= tag simple_selector_tail",
 /*  54 */ "simple_selector ::= simple_selector_tail",
 /*  55 */ "simple_selector ::= tag",
 /*  56 */ "tag ::= IDENT",
 /*  57 */ "tag ::= STAR",
 /*  58 */ "tag ::= SEMICOLON",
 /*  59 */ "simple_selector_tail ::= simple_selector_tail_component",
 /*  60 */ "simple_selector_tail ::= simple_selector_tail_component simple_selector_tail",
 /*  61 */ "simple_selector_tail_component ::= HASH IDENT",
 /*  62 */ "simple_selector_tail_component ::= DOT IDENT",
 /*  63 */ "simple_selector_tail_component ::= LSP IDENT RSP",
 /*  64 */ "simple_selector_tail_component ::= LSP IDENT EQUALS string RSP",
 /*  65 */ "simple_selector_tail_component ::= LSP IDENT TILDE EQUALS string RSP",
 /*  66 */ "simple_selector_tail_component ::= LSP IDENT PIPE EQUALS string RSP",
 /*  67 */ "simple_selector_tail_component ::= COLON IDENT",
 /*  68 */ "simple_selector_tail_component ::= COLON COLON IDENT",
 /*  69 */ "string ::= STRING",
 /*  70 */ "string ::= IDENT",
 /*  71 */ "expr ::= term ws",
 /*  72 */ "expr ::= term operator expr",
 /*  73 */ "operator ::= ws COMMA ws",
 /*  74 */ "operator ::= ws SLASH ws",
 /*  75 */ "operator ::= SPACE ws",
 /*  76 */ "term ::= IDENT",
 /*  77 */ "term ::= STRING",
 /*  78 */ "term ::= FUNCTION",
 /*  79 */ "term ::= HASH IDENT",
 /*  80 */ "term ::= DOT IDENT",
 /*  81 */ "term ::= IDENT DOT IDENT",
 /*  82 */ "term ::= PLUS IDENT",
 /*  83 */ "term ::= PLUS DOT IDENT",
 /*  84 */ "term ::= PLUS IDENT DOT IDENT",
};
#endif /* NDEBUG */

/*
** This function returns the symbolic name associated with a token
** value.
*/
const char *tkhtmlCssParserTokenName(int tokenType){
#ifndef NDEBUG
  if( tokenType>0 && tokenType<(sizeof(yyTokenName)/sizeof(yyTokenName[0])) ){
    return yyTokenName[tokenType];
  }else{
    return "Unknown";
  }
#else
  return "";
#endif
}

/* 
** This function allocates a new parser.
** The only argument is a pointer to a function which works like
** malloc.
**
** Inputs:
** A pointer to the function used to allocate memory.
**
** Outputs:
** A pointer to a parser.  This pointer is used in subsequent calls
** to tkhtmlCssParser and tkhtmlCssParserFree.
*/
void *tkhtmlCssParserAlloc(void *(*mallocProc)(size_t)){
  yyParser *pParser;
  pParser = (yyParser*)(*mallocProc)( (size_t)sizeof(yyParser) );
  if( pParser ){
    pParser->yyidx = -1;
  }
  return pParser;
}

/* The following function deletes the value associated with a
** symbol.  The symbol can be either a terminal or nonterminal.
** "yymajor" is the symbol code, and "yypminor" is a pointer to
** the value.
*/
static void yy_destructor(YYCODETYPE yymajor, YYMINORTYPE *yypminor){
  switch( yymajor ){
    /* Here is inserted the actions which take place when a
    ** terminal or non-terminal is destroyed.  This can happen
    ** when the symbol is popped from the stack during a
    ** reduce or during error processing or when a parser is 
    ** being destroyed before it is finished parsing.
    **
    ** Note: during a reduce, the only symbols destroyed are those
    ** which appear on the RHS of the rule, but which are not used
    ** inside the C code.
    */
    default:  break;   /* If no destructor action specified: do nothing */
  }
}

/*
** Pop the parser's stack once.
**
** If there is a destructor routine associated with the token which
** is popped from the stack, then call it.
**
** Return the major token number for the symbol popped.
*/
static int yy_pop_parser_stack(yyParser *pParser){
  YYCODETYPE yymajor;
  yyStackEntry *yytos = &pParser->yystack[pParser->yyidx];

  if( pParser->yyidx<0 ) return 0;
#ifndef NDEBUG
  if( yyTraceFILE && pParser->yyidx>=0 ){
    fprintf(yyTraceFILE,"%sPopping %s\n",
      yyTracePrompt,
      yyTokenName[yytos->major]);
  }
#endif
  yymajor = yytos->major;
  yy_destructor( yymajor, &yytos->minor);
  pParser->yyidx--;
  return yymajor;
}

/* 
** Deallocate and destroy a parser.  Destructors are all called for
** all stack elements before shutting the parser down.
**
** Inputs:
** <ul>
** <li>  A pointer to the parser.  This should be a pointer
**       obtained from tkhtmlCssParserAlloc.
** <li>  A pointer to a function used to reclaim memory obtained
**       from malloc.
** </ul>
*/
void tkhtmlCssParserFree(
  void *p,                    /* The parser to be deleted */
  void (*freeProc)(void*)     /* Function used to reclaim memory */
){
  yyParser *pParser = (yyParser*)p;
  if( pParser==0 ) return;
  while( pParser->yyidx>=0 ) yy_pop_parser_stack(pParser);
  (*freeProc)((void*)pParser);
}

/*
** Find the appropriate action for a parser given the terminal
** look-ahead token iLookAhead.
**
** If the look-ahead token is YYNOCODE, then check to see if the action is
** independent of the look-ahead.  If it is, return the action, otherwise
** return YY_NO_ACTION.
*/
static int yy_find_shift_action(
  yyParser *pParser,        /* The parser */
  int iLookAhead            /* The look-ahead token */
){
  int i;
  int stateno = pParser->yystack[pParser->yyidx].stateno;
 
  if( stateno>YY_SHIFT_MAX || (i = yy_shift_ofst[stateno])==YY_SHIFT_USE_DFLT ){
    return yy_default[stateno];
  }
  if( iLookAhead==YYNOCODE ){
    return YY_NO_ACTION;
  }
  i += iLookAhead;
  if( i<0 || i>=YY_SZ_ACTTAB || yy_lookahead[i]!=iLookAhead ){
#ifdef YYFALLBACK
    int iFallback;            /* Fallback token */
    if( iLookAhead<sizeof(yyFallback)/sizeof(yyFallback[0])
           && (iFallback = yyFallback[iLookAhead])!=0 ){
#ifndef NDEBUG
      if( yyTraceFILE ){
        fprintf(yyTraceFILE, "%sFALLBACK %s => %s\n",
           yyTracePrompt, yyTokenName[iLookAhead], yyTokenName[iFallback]);
      }
#endif
      return yy_find_shift_action(pParser, iFallback);
    }
#endif
    return yy_default[stateno];
  }else{
    return yy_action[i];
  }
}

/*
** Find the appropriate action for a parser given the non-terminal
** look-ahead token iLookAhead.
**
** If the look-ahead token is YYNOCODE, then check to see if the action is
** independent of the look-ahead.  If it is, return the action, otherwise
** return YY_NO_ACTION.
*/
static int yy_find_reduce_action(
  int stateno,              /* Current state number */
  int iLookAhead            /* The look-ahead token */
){
  int i;
  /* int stateno = pParser->yystack[pParser->yyidx].stateno; */
 
  if( stateno>YY_REDUCE_MAX ||
      (i = yy_reduce_ofst[stateno])==YY_REDUCE_USE_DFLT ){
    return yy_default[stateno];
  }
  if( iLookAhead==YYNOCODE ){
    return YY_NO_ACTION;
  }
  i += iLookAhead;
  if( i<0 || i>=YY_SZ_ACTTAB || yy_lookahead[i]!=iLookAhead ){
    return yy_default[stateno];
  }else{
    return yy_action[i];
  }
}

/*
** Perform a shift action.
*/
static void yy_shift(
  yyParser *yypParser,          /* The parser to be shifted */
  int yyNewState,               /* The new state to shift in */
  int yyMajor,                  /* The major token to shift in */
  YYMINORTYPE *yypMinor         /* Pointer ot the minor token to shift in */
){
  yyStackEntry *yytos;
  yypParser->yyidx++;
  if( yypParser->yyidx>=YYSTACKDEPTH ){
     tkhtmlCssParserARG_FETCH;
     yypParser->yyidx--;
#ifndef NDEBUG
     if( yyTraceFILE ){
       fprintf(yyTraceFILE,"%sStack Overflow!\n",yyTracePrompt);
     }
#endif
     while( yypParser->yyidx>=0 ) yy_pop_parser_stack(yypParser);
     /* Here code is inserted which will execute if the parser
     ** stack every overflows */
     tkhtmlCssParserARG_STORE; /* Suppress warning about unused %extra_argument var */
     return;
  }
  yytos = &yypParser->yystack[yypParser->yyidx];
  yytos->stateno = yyNewState;
  yytos->major = yyMajor;
  yytos->minor = *yypMinor;
#ifndef NDEBUG
  if( yyTraceFILE && yypParser->yyidx>0 ){
    int i;
    fprintf(yyTraceFILE,"%sShift %d\n",yyTracePrompt,yyNewState);
    fprintf(yyTraceFILE,"%sStack:",yyTracePrompt);
    for(i=1; i<=yypParser->yyidx; i++)
      fprintf(yyTraceFILE," %s",yyTokenName[yypParser->yystack[i].major]);
    fprintf(yyTraceFILE,"\n");
  }
#endif
}

/* The following table contains information about every rule that
** is used during the reduce.
*/
static const struct {
  YYCODETYPE lhs;         /* Symbol on the left-hand side of the rule */
  unsigned char nrhs;     /* Number of right-hand side symbols in the rule */
} yyRuleInfo[] = {
  { 31, 2 },
  { 34, 0 },
  { 34, 2 },
  { 32, 3 },
  { 35, 6 },
  { 35, 0 },
  { 36, 7 },
  { 36, 0 },
  { 38, 1 },
  { 38, 0 },
  { 40, 2 },
  { 40, 4 },
  { 40, 3 },
  { 41, 2 },
  { 41, 1 },
  { 43, 1 },
  { 43, 2 },
  { 42, 3 },
  { 42, 1 },
  { 33, 1 },
  { 33, 3 },
  { 44, 1 },
  { 44, 1 },
  { 44, 1 },
  { 45, 7 },
  { 49, 1 },
  { 39, 2 },
  { 39, 5 },
  { 50, 6 },
  { 52, 3 },
  { 52, 0 },
  { 51, 1 },
  { 47, 4 },
  { 48, 2 },
  { 48, 3 },
  { 46, 4 },
  { 46, 1 },
  { 46, 1 },
  { 54, 1 },
  { 54, 4 },
  { 56, 1 },
  { 53, 1 },
  { 53, 3 },
  { 53, 3 },
  { 57, 7 },
  { 57, 1 },
  { 59, 2 },
  { 59, 0 },
  { 55, 2 },
  { 55, 3 },
  { 61, 3 },
  { 61, 3 },
  { 61, 2 },
  { 60, 2 },
  { 60, 1 },
  { 60, 1 },
  { 62, 1 },
  { 62, 1 },
  { 62, 1 },
  { 63, 1 },
  { 63, 2 },
  { 64, 2 },
  { 64, 2 },
  { 64, 3 },
  { 64, 5 },
  { 64, 6 },
  { 64, 6 },
  { 64, 2 },
  { 64, 3 },
  { 65, 1 },
  { 65, 1 },
  { 58, 2 },
  { 58, 3 },
  { 66, 3 },
  { 66, 3 },
  { 66, 2 },
  { 37, 1 },
  { 37, 1 },
  { 37, 1 },
  { 37, 2 },
  { 37, 2 },
  { 37, 3 },
  { 37, 2 },
  { 37, 3 },
  { 37, 4 },
};

static void yy_accept(yyParser*);  /* Forward Declaration */

/*
** Perform a reduce action and the shift that must immediately
** follow the reduce.
*/
static void yy_reduce(
  yyParser *yypParser,         /* The parser */
  int yyruleno                 /* Number of the rule by which to reduce */
){
  int yygoto;                     /* The next state */
  int yyact;                      /* The next action */
  YYMINORTYPE yygotominor;        /* The LHS of the rule reduced */
  yyStackEntry *yymsp;            /* The top of the parser's stack */
  int yysize;                     /* Amount to pop the stack */
  tkhtmlCssParserARG_FETCH;
  yymsp = &yypParser->yystack[yypParser->yyidx];
#ifndef NDEBUG
  if( yyTraceFILE && yyruleno>=0 
        && yyruleno<sizeof(yyRuleName)/sizeof(yyRuleName[0]) ){
    fprintf(yyTraceFILE, "%sReduce [%s].\n", yyTracePrompt,
      yyRuleName[yyruleno]);
  }
#endif /* NDEBUG */

#ifndef NDEBUG
  /* Silence complaints from purify about yygotominor being uninitialized
  ** in some cases when it is copied into the stack after the following
  ** switch.  yygotominor is uninitialized when a rule reduces that does
  ** not set the value of its left-hand side nonterminal.  Leaving the
  ** value of the nonterminal uninitialized is utterly harmless as long
  ** as the value is never used.  So really the only thing this code
  ** accomplishes is to quieten purify.  
  */
  memset(&yygotominor, 0, sizeof(yygotominor));
#endif

  switch( yyruleno ){
  /* Beginning here are the reduction cases.  A typical example
  ** follows:
  **   case 0:
  **  #line <lineno> <grammarfile>
  **     { ... }           // User supplied code
  **  #line <lineno> <thisfile>
  **     break;
  */
      case 3:
#line 83 "cssparse.lem"
{
  pParse->isBody = 1;
}
#line 795 "cssparse.c"
        break;
      case 6:
#line 91 "cssparse.lem"
{
    HtmlCssImport(pParse, &yymsp[-3].minor.yy0);
}
#line 802 "cssparse.c"
        break;
      case 24:
#line 129 "cssparse.lem"
{
    pParse->isIgnore = 0;
}
#line 809 "cssparse.c"
        break;
      case 25:
#line 136 "cssparse.lem"
{
    if (
        (yymsp[0].minor.yy0.n == 3 && 0 == strnicmp(yymsp[0].minor.yy0.z, "all", 3)) ||
        (yymsp[0].minor.yy0.n == 6 && 0 == strnicmp(yymsp[0].minor.yy0.z, "screen", 6))
    ) {
        yygotominor.yy62 = 0;
    } else {
        yygotominor.yy62 = 1;
    }
}
#line 823 "cssparse.c"
        break;
      case 26:
#line 147 "cssparse.lem"
{
    yygotominor.yy62 = yymsp[-1].minor.yy62;
    pParse->isIgnore = yygotominor.yy62;
}
#line 831 "cssparse.c"
        break;
      case 27:
#line 152 "cssparse.lem"
{
    yygotominor.yy62 = (yymsp[-4].minor.yy62 && yymsp[0].minor.yy62) ? 1 : 0;
    pParse->isIgnore = yygotominor.yy62;
}
#line 839 "cssparse.c"
        break;
      case 28:
#line 160 "cssparse.lem"
{
  pParse->isIgnore = 0;
}
#line 846 "cssparse.c"
        break;
      case 31:
#line 167 "cssparse.lem"
{
  pParse->isIgnore = 1;
}
#line 853 "cssparse.c"
        break;
      case 35:
#line 182 "cssparse.lem"
{
    HtmlCssRule(pParse, 1);
}
#line 860 "cssparse.c"
        break;
      case 37:
#line 186 "cssparse.lem"
{
    HtmlCssRule(pParse, 0);
}
#line 867 "cssparse.c"
        break;
      case 40:
#line 192 "cssparse.lem"
{
    HtmlCssSelectorComma(pParse);
}
#line 874 "cssparse.c"
        break;
      case 44:
#line 200 "cssparse.lem"
{
    HtmlCssDeclaration(pParse, &yymsp[-5].minor.yy0, &yymsp[-1].minor.yy0, yymsp[0].minor.yy62);
}
#line 881 "cssparse.c"
        break;
      case 46:
#line 206 "cssparse.lem"
{yygotominor.yy62 = (pParse->pStyleId) ? 1 : 0;}
#line 886 "cssparse.c"
        break;
      case 47:
#line 207 "cssparse.lem"
{yygotominor.yy62 = 0;}
#line 891 "cssparse.c"
        break;
      case 50:
#line 227 "cssparse.lem"
{
    HtmlCssSelector(pParse, CSS_SELECTORCHAIN_ADJACENT, 0, 0);
}
#line 898 "cssparse.c"
        break;
      case 51:
#line 230 "cssparse.lem"
{
    HtmlCssSelector(pParse, CSS_SELECTORCHAIN_CHILD, 0, 0);
}
#line 905 "cssparse.c"
        break;
      case 52:
#line 233 "cssparse.lem"
{
    HtmlCssSelector(pParse, CSS_SELECTORCHAIN_DESCENDANT, 0, 0);
}
#line 912 "cssparse.c"
        break;
      case 56:
      case 58:
#line 241 "cssparse.lem"
{ HtmlCssSelector(pParse, CSS_SELECTOR_TYPE, 0, &yymsp[0].minor.yy0); }
#line 918 "cssparse.c"
        break;
      case 57:
#line 242 "cssparse.lem"
{ HtmlCssSelector(pParse, CSS_SELECTOR_UNIVERSAL, 0, 0); }
#line 923 "cssparse.c"
        break;
      case 61:
#line 248 "cssparse.lem"
{
    HtmlCssSelector(pParse, CSS_SELECTOR_ID, 0, &yymsp[0].minor.yy0);
}
#line 930 "cssparse.c"
        break;
      case 62:
#line 251 "cssparse.lem"
{
    /* A CSS class selector may not begin with a digit. Presumably this is
     * because they expect to use this syntax for something else in a
     * future version. For now, just insert a "never-match" condition into
     * the rule to prevent it from having any affect. A bit lazy, this.
     */
    if (yymsp[0].minor.yy0.n > 0 && !isdigit((int)(*yymsp[0].minor.yy0.z))) {
        HtmlCssSelector(pParse, CSS_SELECTOR_CLASS, 0, &yymsp[0].minor.yy0);
    } else {
        HtmlCssSelector(pParse, CSS_SELECTOR_NEVERMATCH, 0, 0);
    }
}
#line 946 "cssparse.c"
        break;
      case 63:
#line 263 "cssparse.lem"
{
    HtmlCssSelector(pParse, CSS_SELECTOR_ATTR, &yymsp[-1].minor.yy0, 0);
}
#line 953 "cssparse.c"
        break;
      case 64:
#line 266 "cssparse.lem"
{
    HtmlCssSelector(pParse, CSS_SELECTOR_ATTRVALUE, &yymsp[-3].minor.yy0, &yymsp[-1].minor.yy0);
}
#line 960 "cssparse.c"
        break;
      case 65:
#line 269 "cssparse.lem"
{
    HtmlCssSelector(pParse, CSS_SELECTOR_ATTRLISTVALUE, &yymsp[-4].minor.yy0, &yymsp[-1].minor.yy0);
}
#line 967 "cssparse.c"
        break;
      case 66:
#line 272 "cssparse.lem"
{
    HtmlCssSelector(pParse, CSS_SELECTOR_ATTRHYPHEN, &yymsp[-4].minor.yy0, &yymsp[-1].minor.yy0);
}
#line 974 "cssparse.c"
        break;
      case 67:
#line 276 "cssparse.lem"
{
    HtmlCssSelector(pParse, HtmlCssPseudo(&yymsp[0].minor.yy0, 1), 0, 0);
}
#line 981 "cssparse.c"
        break;
      case 68:
#line 279 "cssparse.lem"
{
    HtmlCssSelector(pParse, HtmlCssPseudo(&yymsp[0].minor.yy0, 2), 0, 0);
}
#line 988 "cssparse.c"
        break;
      case 69:
      case 70:
#line 283 "cssparse.lem"
{yygotominor.yy0 = yymsp[0].minor.yy0;}
#line 994 "cssparse.c"
        break;
      case 71:
#line 292 "cssparse.lem"
{ yygotominor.yy0 = yymsp[-1].minor.yy0; }
#line 999 "cssparse.c"
        break;
      case 72:
      case 81:
      case 83:
#line 293 "cssparse.lem"
{ yygotominor.yy0.z = yymsp[-2].minor.yy0.z; yygotominor.yy0.n = (yymsp[0].minor.yy0.z+yymsp[0].minor.yy0.n - yymsp[-2].minor.yy0.z); }
#line 1006 "cssparse.c"
        break;
      case 76:
      case 77:
      case 78:
#line 299 "cssparse.lem"
{ yygotominor.yy0 = yymsp[0].minor.yy0; }
#line 1013 "cssparse.c"
        break;
      case 79:
      case 80:
      case 82:
#line 302 "cssparse.lem"
{ yygotominor.yy0.z = yymsp[-1].minor.yy0.z; yygotominor.yy0.n = (yymsp[0].minor.yy0.z+yymsp[0].minor.yy0.n - yymsp[-1].minor.yy0.z); }
#line 1020 "cssparse.c"
        break;
      case 84:
#line 308 "cssparse.lem"
{ yygotominor.yy0.z = yymsp[-3].minor.yy0.z; yygotominor.yy0.n = (yymsp[0].minor.yy0.z+yymsp[0].minor.yy0.n - yymsp[-3].minor.yy0.z); }
#line 1025 "cssparse.c"
        break;
  };
  yygoto = yyRuleInfo[yyruleno].lhs;
  yysize = yyRuleInfo[yyruleno].nrhs;
  yypParser->yyidx -= yysize;
  yyact = yy_find_reduce_action(yymsp[-yysize].stateno,yygoto);
  if( yyact < YYNSTATE ){
#ifdef NDEBUG
    /* If we are not debugging and the reduce action popped at least
    ** one element off the stack, then we can push the new element back
    ** onto the stack here, and skip the stack overflow test in yy_shift().
    ** That gives a significant speed improvement. */
    if( yysize ){
      yypParser->yyidx++;
      yymsp -= yysize-1;
      yymsp->stateno = yyact;
      yymsp->major = yygoto;
      yymsp->minor = yygotominor;
    }else
#endif
    {
      yy_shift(yypParser,yyact,yygoto,&yygotominor);
    }
  }else if( yyact == YYNSTATE + YYNRULE + 1 ){
    yy_accept(yypParser);
  }
}

/*
** The following code executes when the parse fails
*/
static void yy_parse_failed(
  yyParser *yypParser           /* The parser */
){
  tkhtmlCssParserARG_FETCH;
#ifndef NDEBUG
  if( yyTraceFILE ){
    fprintf(yyTraceFILE,"%sFail!\n",yyTracePrompt);
  }
#endif
  while( yypParser->yyidx>=0 ) yy_pop_parser_stack(yypParser);
  /* Here code is inserted which will be executed whenever the
  ** parser fails */
  tkhtmlCssParserARG_STORE; /* Suppress warning about unused %extra_argument variable */
}

/*
** The following code executes when a syntax error first occurs.
*/
static void yy_syntax_error(
  yyParser *yypParser,           /* The parser */
  int yymajor,                   /* The major type of the error token */
  YYMINORTYPE yyminor            /* The minor type of the error token */
){
  tkhtmlCssParserARG_FETCH;
#define TOKEN (yyminor.yy0)
#line 66 "cssparse.lem"

    pParse->pStyle->nSyntaxErr++;
    pParse->isIgnore = 0;
    /* HtmlCssRule(pParse, 0); */
#line 1088 "cssparse.c"
  tkhtmlCssParserARG_STORE; /* Suppress warning about unused %extra_argument variable */
}

/*
** The following is executed when the parser accepts
*/
static void yy_accept(
  yyParser *yypParser           /* The parser */
){
  tkhtmlCssParserARG_FETCH;
#ifndef NDEBUG
  if( yyTraceFILE ){
    fprintf(yyTraceFILE,"%sAccept!\n",yyTracePrompt);
  }
#endif
  while( yypParser->yyidx>=0 ) yy_pop_parser_stack(yypParser);
  /* Here code is inserted which will be executed whenever the
  ** parser accepts */
  tkhtmlCssParserARG_STORE; /* Suppress warning about unused %extra_argument variable */
}

/* The main parser program.
** The first argument is a pointer to a structure obtained from
** "tkhtmlCssParserAlloc" which describes the current state of the parser.
** The second argument is the major token number.  The third is
** the minor token.  The fourth optional argument is whatever the
** user wants (and specified in the grammar) and is available for
** use by the action routines.
**
** Inputs:
** <ul>
** <li> A pointer to the parser (an opaque structure.)
** <li> The major token number.
** <li> The minor token number.
** <li> An option argument of a grammar-specified type.
** </ul>
**
** Outputs:
** None.
*/
void tkhtmlCssParser(
  void *yyp,                   /* The parser */
  int yymajor,                 /* The major token code number */
  tkhtmlCssParserTOKENTYPE yyminor       /* The value for the token */
  tkhtmlCssParserARG_PDECL               /* Optional %extra_argument parameter */
){
  YYMINORTYPE yyminorunion;
  int yyact;            /* The parser action. */
  int yyendofinput;     /* True if we are at the end of input */
  int yyerrorhit = 0;   /* True if yymajor has invoked an error */
  yyParser *yypParser;  /* The parser */

  /* (re)initialize the parser, if necessary */
  yypParser = (yyParser*)yyp;
  if( yypParser->yyidx<0 ){
    /* if( yymajor==0 ) return; // not sure why this was here... */
    yypParser->yyidx = 0;
    yypParser->yyerrcnt = -1;
    yypParser->yystack[0].stateno = 0;
    yypParser->yystack[0].major = 0;
  }
  yyminorunion.yy0 = yyminor;
  yyendofinput = (yymajor==0);
  tkhtmlCssParserARG_STORE;

#ifndef NDEBUG
  if( yyTraceFILE ){
    fprintf(yyTraceFILE,"%sInput %s\n",yyTracePrompt,yyTokenName[yymajor]);
  }
#endif

  do{
    yyact = yy_find_shift_action(yypParser,yymajor);
    if( yyact<YYNSTATE ){
      yy_shift(yypParser,yyact,yymajor,&yyminorunion);
      yypParser->yyerrcnt--;
      if( yyendofinput && yypParser->yyidx>=0 ){
        yymajor = 0;
      }else{
        yymajor = YYNOCODE;
      }
    }else if( yyact < YYNSTATE + YYNRULE ){
      yy_reduce(yypParser,yyact-YYNSTATE);
    }else if( yyact == YY_ERROR_ACTION ){
      int yymx;
#ifndef NDEBUG
      if( yyTraceFILE ){
        fprintf(yyTraceFILE,"%sSyntax Error!\n",yyTracePrompt);
      }
#endif
#ifdef YYERRORSYMBOL
      /* A syntax error has occurred.
      ** The response to an error depends upon whether or not the
      ** grammar defines an error token "ERROR".  
      **
      ** This is what we do if the grammar does define ERROR:
      **
      **  * Call the %syntax_error function.
      **
      **  * Begin popping the stack until we enter a state where
      **    it is legal to shift the error symbol, then shift
      **    the error symbol.
      **
      **  * Set the error count to three.
      **
      **  * Begin accepting and shifting new tokens.  No new error
      **    processing will occur until three tokens have been
      **    shifted successfully.
      **
      */
      if( yypParser->yyerrcnt<0 ){
        yy_syntax_error(yypParser,yymajor,yyminorunion);
      }
      yymx = yypParser->yystack[yypParser->yyidx].major;
      if( yymx==YYERRORSYMBOL || yyerrorhit ){
#ifndef NDEBUG
        if( yyTraceFILE ){
          fprintf(yyTraceFILE,"%sDiscard input token %s\n",
             yyTracePrompt,yyTokenName[yymajor]);
        }
#endif
        yy_destructor(yymajor,&yyminorunion);
        yymajor = YYNOCODE;
      }else{
         while(
          yypParser->yyidx >= 0 &&
          yymx != YYERRORSYMBOL &&
          (yyact = yy_find_reduce_action(
                        yypParser->yystack[yypParser->yyidx].stateno,
                        YYERRORSYMBOL)) >= YYNSTATE
        ){
          yy_pop_parser_stack(yypParser);
        }
        if( yypParser->yyidx < 0 || yymajor==0 ){
          yy_destructor(yymajor,&yyminorunion);
          yy_parse_failed(yypParser);
          yymajor = YYNOCODE;
        }else if( yymx!=YYERRORSYMBOL ){
          YYMINORTYPE u2;
          u2.YYERRSYMDT = 0;
          yy_shift(yypParser,yyact,YYERRORSYMBOL,&u2);
        }
      }
      yypParser->yyerrcnt = 3;
      yyerrorhit = 1;
#else  /* YYERRORSYMBOL is not defined */
      /* This is what we do if the grammar does not define ERROR:
      **
      **  * Report an error message, and throw away the input token.
      **
      **  * If the input token is $, then fail the parse.
      **
      ** As before, subsequent error messages are suppressed until
      ** three input tokens have been successfully shifted.
      */
      if( yypParser->yyerrcnt<=0 ){
        yy_syntax_error(yypParser,yymajor,yyminorunion);
      }
      yypParser->yyerrcnt = 3;
      yy_destructor(yymajor,&yyminorunion);
      if( yyendofinput ){
        yy_parse_failed(yypParser);
      }
      yymajor = YYNOCODE;
#endif
    }else{
      yy_accept(yypParser);
      yymajor = YYNOCODE;
    }
  }while( yymajor!=YYNOCODE && yypParser->yyidx>=0 );
  return;
}
