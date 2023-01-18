# Dernier phase parser

# main_cpp.l

Fichier qui contient le code qui permet de générer le **lexeur** avec flex. Le
but du lexer est de récupérer les symboles dans le text et pour chacun de ces
symboles, il doit retourner le **token** correspondant. Les token doivent-être
définis dans `main_cpp.y` au préalable.

A noter que l'on peut utiliser la variable `yylval` pour transmettre des
éléments au parser.

# main_cpp.y

Fichier qui contient le code qui permet de générer le **parseur** avec bison. Il
contient toutes les règles syntaxiques qui définissent la grammaire du langage.
Chaque règle va contenir des block de code qui seront exécuter au moment où le
praseur la reconnait, ce code permet de créer des objet qui formeront l'ABS
(Abstract Syntaxic Tree) du programme.

# AST

Ce répertoir contient tout ce qui touche à l'abre syntaxique, soit, le programme
qui contient des **fonctions** et des **includes** qui sont des éléments de
l'arbre. Il contient aussi le **ProgrammeBuilder** qui permet de construire le
programme. Enfin, on peut aussi trouver les definitions de tous les éléments de
l'arbre syntaxique.
