# Projet ZZ2

Projet de seconde année à l'ISIMA.

## Objectif

Le but de ce projet est de créer un langage transpilé très simple. Ce langage
doit être statiquement typé et doit pouvoir être traduit en python.

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
concept de fonction aux débutants.

**NOTE:** Les notations peuvent être amenées à changer.
