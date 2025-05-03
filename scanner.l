/* Definition section */
%{
   #include <stdio.h>
   #include <stdlib.h>
   #include <string.h>

   #define YY_NO_UNPUT
   #define YY_NO_INPUT
   #define print_token(token) \
       printf("%-8s \t %s\n", strcmp(token, "NEWLINE")? yytext: "", token)

   int line_num = 0;
   int comment_num = 0;
   int last_comment_line = 0;
   
%}

%x COMMENT
%x STRING_LIT
/* Define regular expression label */
letter [a-zA-Z_]
digit [0-9]
func fn\ {letter}
ident {letter}({letter}|{digit})*


/* Rules section */
%%
"+"         { print_token("ADD"); }
"-"         { print_token("SUB"); }
"*"         { print_token("MUL"); }
"/"         { print_token("QUO"); }
"%"         { print_token("REM"); }
">"         { print_token("GTR"); }
"<"         { print_token("LSS"); }
">="        { print_token("GEQ"); }
"<="        { print_token("LEQ"); }
"=="        { print_token("EQL"); }
"!="        { print_token("NEQ"); }
"="         { print_token("ASSIGN"); }
"+="        { print_token("ADD_ASSIGN"); }
"-="        { print_token("SUB_ASSIGN"); }
"*="        { print_token("MUL_ASSIGN"); }
"/="        { print_token("QUO_ASSIGN"); }
"%="        { print_token("REM_ASSIGN"); }
"&"         { print_token("BAND"); }
"|"         { print_token("BOR"); }
"~"         { print_token("BNOT"); }
">>"        { print_token("RSHIFT"); }
"&&"        { print_token("LAND"); }
"||"        { print_token("LOR"); }
"!"         { print_token("NOT"); }
"("         { print_token("LPAREN"); }
")"         { print_token("RPAREN"); }
"["         { print_token("LBRACK"); }
"]"         { print_token("RBRACK"); }
"{"         { print_token("LBRACE"); }
"}"         { print_token("RBRACE"); }
","         { print_token("COMMA"); }
";"         { print_token("SEMICOLON"); }
":"         { print_token("COLON"); }
"->"        { print_token("ARROW"); }
"<<"        { print_token("LSHIFT"); }
".."        { print_token("DOTDOT"); }
\"          { print_token("QUOTA");BEGIN(STRING_LIT); yytext[0] = '\0';  }
<STRING_LIT>([^\\\"\n]|\\.)+    { yymore(); }
<STRING_LIT>\" {
    BEGIN(INITIAL);
    if (yyleng > 1) {  
        yytext[yyleng - 1] = '\0';  
        print_token("STRING_LIT");
    }
    yytext[0] = '\"';
    yytext[1] = '\0';
    print_token("QUOTA");
    BEGIN(INITIAL);
}



"println"        { print_token("PRINTLN"); }
"let"        { print_token("LET"); }
"i32"        { print_token("INT"); }
"f32"        { print_token("FLOAT"); }
"true"       { print_token("TRUE"); }
"false"      { print_token("FALSE"); }
"print"      { print_token("PRINT"); }
"bool"       { print_token("BOOL"); }
"mut"       { print_token("MUT"); }
"as"       { print_token("AS"); }
"if"       { print_token("IF"); }
"else"       { print_token("ELSE"); }
"while"       { print_token("WHILE"); }
"return"       { print_token("RETURN"); }
"loop"       { print_token("LOOP"); }
"break"       { print_token("BREAK"); }
"for"       { print_token("FOR"); }
"in"       { print_token("IN"); }

\n          { line_num++; print_token("NEWLINE"); }
{func}      { yyless(3); print_token("FUNC");  }
{ident}     { print_token("IDENT");}
{digit}+    { print_token("INT_LIT"); }
{digit}+\.{digit}+ { print_token("FLOAT_LIT"); }
[ \t\r]+    {;}
.           {;}

"//".*      { print_token("COMMENT");comment_num++; }

"/*"        {   BEGIN(COMMENT);
                 if (line_num != last_comment_line) {
                        comment_num++;
                        last_comment_line = line_num;}
                yymore();}
<COMMENT>(.|\r?) {yymore();}
<COMMENT>\n {   yymore();
                line_num++; 
                if (line_num != last_comment_line) {
                    comment_num++;
                    last_comment_line = line_num;
                }}
<COMMENT>"*/" {
    
    BEGIN(INITIAL);
    print_token("MUTI_LINE_COMMENT");
    }
 


<<EOF>>     { line_num++; yyterminate(); }



%%

/*  C Code section */
int yywrap(void)
{
   return 1;
}

int main(int argc, char *argv[])
{
   if (argc == 2) {
       yyin = fopen(argv[1], "r");
   } else {
       yyin = stdin;
   }
   yylex();
   printf("\nFinish scanning,\n");
   printf("total line: %d\n", line_num);
   printf("comment line: %d\n", comment_num);
   fclose(yyin);
   return 0;
}
