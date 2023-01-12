# Dernier phase parser

## Funcall

Pour les `funcall`, on est obligé d'utiliser une pile de pile pour stocker les
paramètres des différentes fonctions.

## Opération arithmetiques

Conflit d'opération avec les `funcall` ce qui oblige à répéter la grammaire des
`param` 2 fois:
- une fois pour les `funcall` => on empile dans la piles des `funcall`
- une seconde fois pour les opérandes
