# Flex et bison

flex
: identification des **lexèmes** (les mots) et leurs **unité lexicales**. Il
permet de retourner des **token** qui sont utilisés avec bison.

Bison
: validation grammaiticale (expr arithmetiques), ajouter de la sémantique,
  évaluer les expressions et afficher le résultat.


Les fichiers suivent la syntaxe suivante:

```
C and parser declaration
%%
Grammar rules and actions
%%
C subroutings
```

## Flex

[doc](https://ftp.gnu.org/old-gnu/Manuals/flex-2.5.4/html_mono/flex.html)

On peut definir des règles dans les déclarations du parser:

```
alpha [a-zA-Z]
digit [0-9]
int [+-]?{digit}+
identifier [a-z]({alpha}|{digit})*
```

Dans les règles, on suit toujours le même principe, on indique les caractères à
reconaitre puis on exécute du code:

```
for          { AFFICHE("L_for"); return Parser::token::FOR; }
{identifier} {
  AFFICHE("L_id");
  yylval->build<std::string>(yytext);
  return Parser::token::IDENTIFIER;
}
```

Ici on a accès à la variable `yylval` qui est un `Parser::semantic_type*` et qui
possède une méthode `build` qui nous permet de transmettre des valeurs à bison.
Ces valeurs sont accessible via les variables de bison: `$2`. La variable
`yytext` contient le text traité par flex. De plus, dans le code, on retourne
les **token**. Ces **token** sont définis dans le fichier de bison.

### Options: `%option ...`

- `c++`: indique qu'on travail avec du cpp et non du c
- `interactive`: utile quand on utlise `std::in`. Le scanner interactif regarde
  plus de caractères avant de générer un token (plus lent mais permet de lutter
  contre les ambiguitées)
- `noyywrap`: ne pas appeler `yywrap()` qui permet de parser plusieurs fichiers
- `noyylineno`: désactive l'enregistrement des lignes (`yylineno`)
- `nodefault`: pas de scanner par défaut (=> on doit tout implémenter)
- `outfile:"file.cpp"`: permet de definir le fichier de sortie

### yylex

La fonction appelée par défaut est `yylex`, cependant, pour pouvoir travailler
avec bison, nous devont fournir notre propre fonctions, pour ce faire on
utilise la macro `YY_DECL` (cf: **The generated scanner** dans la doc).

```
#define YY_DECL int interpreter::Scanner::lex(interpreter::Parser::semantic_type *yylval)
```

## Bison

**NOTE:** la structure du fichier bison est la même que pour flex.

### Définition des tokens

Les tokens sont définis en début de fichier avec la syntaxe suivante:

```
%token IF ELSE FOR WHILE FN INCLUDE IN
%token <long long>  INT
%token <double>     FLOAT
%token <char>       CHAR
%token <std::string> IDENTIFIER
```

A noter que l'on peut spécifier le type de l'élément, ce qui sera util pour
récupérer les valeurs retournées par le lexeur.

### Règles de syntaxes

Bison permet de construire le parser, qui va reconaitre des éléments de syntaxe
et non pas juste des mots clés. Par exemple, on peut définir une règel pour
reconnaitre une suite d'inclusion de fichiers:

```
includes: %empty
       | INCLUDE IDENTIFIER SEMI includes
       ;
```

Ici, on définie une règle `includes` qui décrit la syntaxe des includes. Selon
cette règle, une suite d'inclusions est soit vide, soit elle comporte une
inclusion, suivit d'une suite d'inclusion (`|` signifie "ou"). Il faut noter que
la syntaxe est "récursive", ce qui nous permet de définir une suite d'éléments.
Enfin, les mots en CAPITAL sont les tokens retournés par le lexer.

### Ajout de code et récupération des valeurs

On peut ajouter des blocks de codes qui seront exécutés au moment ou le parser
atteint l'élément qui précède le block. Dans l'exemple ci-dessous, le blocks
sera appelé une fois que bison aura parser le `;`. A noter que l'on peut accéder
au éléments retournés par flex, ici, `$2` fait référence au second élément de la
règle qui est `IDENTIFIER`. Le type de `IDENTIFIER` a été défini comme étant une
`std::string`. Le blocks de code nous permet donc de créer une nouvelle
inclusion et de récupérer le nom de la bibliothèque.

```
includes: %empty
       |
       INCLUDE IDENTIFIER SEMI
       {
         std::cout << "new include id: " << $2 << std::endl;
         pb.addInclude(std::make_shared<Include>($2));
       }
       includes
       ;
```

Comme dit plus haut, on peut définir des types pour les tokens, ce qui permet de
récupérer des valeurs:

```
value: INT {
       std::cout << "new int: " << $1 << std::endl;
       lastValue.i = $1;
       lastValueType = INT;
     } | FLOAT {
       std::cout << "new double: " << $1 << std::endl;
       lastValue.f = $1;
       lastValueType = FLT;
     } | CHAR {
       std::cout << "new char: " << $1 << std::endl;
       lastValue.c = $1;
       lastValueType = CHR;
     }
     ;
```

### Génération du code

Pour la génération du code, on a 2 options:
- utiliser des instruction très simple => sorte de bytecode
- créer un code objet où tous les éléments sont des objets

Choix de la représentation objet:
- plus simple à comprendre et à visualiser
- plus compliquer à générer: on peut générer du bytecode au fil de l'exécution
  du parser, en utilisant des `goto` pour sauter de blocks d'instructions en
  blocks d'instructions. Pour le code objet, les éléments à l'intérieurs des
  block doivent-être créés avant le block, et le block est détecté avant les
  instructions, il faut donc stoquer les instructions.
