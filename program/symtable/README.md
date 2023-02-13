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

Cela implique que pour la recherche, il faut d'abord chercher dans le scope
courant puis, "remonter" dans les scopes accessibles.

## Scope

Les scope sont des chaine des caractères générées par les `ContextManager` et sont
de la forme suivant:

```
"/fichier/fonction/if1/else1/for11"
```

À noter que l'on est obligé de sauvegarder le numéro de statement, car sinon, 2
"if" qui se suivent correspondraient au même scope.

# New strategy

La stratégie précédente n'est pas adaptée, de ce fait, la table des symboles
sera un arbre où chaque noeud sera une sous table. Pour faire une recherche de
symboles, il faut faire une recherche dans la table courante, ou chercher dans
les tables supérieures jusqu'au scope global.
