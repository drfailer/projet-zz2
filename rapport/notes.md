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

TODO
