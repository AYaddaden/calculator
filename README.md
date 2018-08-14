# Part 1 & 2 of TP COMPIL

Evaluating and calculating expression's result

Program written on Ubuntu 17.10 using flex and bison

To compile:

```
bison -d compil.y

flex compil.l

gcc -o compil compil.tab.c lex.yy.c -lfl -lm
```
