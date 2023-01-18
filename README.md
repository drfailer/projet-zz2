# Projet ZZ2

Projet de seconde année à l'ISIMA.

## Objectif

Le but est de créer un interpréteur et un IDE pour un langage très basique. Le
but est de pouvoir faire découvrir la programmation à des élèves de lycée et de
collèges.

## Syntaxe

```
fn add3(int a, int b, int c) -> int {
  return add(a, add(b, c));
}

fn main() {
  print("1 + 2 + 3 = {}\n");
  print(add3(1, 2, 3));
}
```

Il n'y a pas d'opérateurs, il faudra utiliser des fonctions à la place. Le but
de ce choix est de limiter les notations pour simplifier la compréhension du
concept de fonction au débutant.

**NOTE:** Les notations peuvent être amenées à changer.

## Features

- [ ] fonctions
- [ ] tableaux
- [ ] types:
  - int
  - flt
  - chr
