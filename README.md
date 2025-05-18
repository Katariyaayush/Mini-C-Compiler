Compile & Run : flex lexer.l
                bison -d parser.y
                gcc lex.yy.c parser.tab.c -o parser -lfl
                ./parser < test.c
