# Table des symboles

La table des symboles est composée d'une table de hashage qui pour chaque nom
contient une liste de symboles correspondants. Pour avoir les informations sur
un symboles, il faut le chercher dans la liste. Cela implique qu'il faut traquer
les scopes.

## Cas complex

```
fn ma_fonction(int a) { // ma_fonction/a (a.Kind => FUN_PARAM)
  int a; // ma_fonction/a (a.Kind => LOCAL_VAR)

  if (eql(a, 4)) {
    int a; // ma_fonction/if/a (a.Kind => LOCAL_VAR)
  }
}
```

Cela implique que pour la recher, il faut d'abord chercher dans le scope
courant puis, "remonter" dans les scopes accessibles.
