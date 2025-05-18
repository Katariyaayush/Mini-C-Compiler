readme

flex lexer.l
bison -d -b parser parser.y
gcc parser.tab.c lex.yy.c -o myparser -lfl
./myparser < test.c
