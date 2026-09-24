# Tables n8n

Les CSV contiennent uniquement les en-têtes d’origine, sans aucune ligne de collection. Créez les tables dans votre projet n8n, puis sélectionnez-les dans tous les nœuds Data Table concernés.

L’import CSV permet de reprendre les noms des colonnes. Sans données, vérifiez les types ci-dessous ; si votre version refuse un CSV vide, créez ces colonnes manuellement. Les colonnes système de n8n (`id`, `createdAt`, `updatedAt`) ne sont pas à ajouter aux modèles.

## Audible

| Colonne | Type |
|---|---|
| `id_unique` | string |
| `titre` | string |
| `auteur` | string |
| `duree_brute` | string |
| `statut` | string |
| `genre` | string |

## BD

| Colonne | Type |
|---|---|
| `id_unique` | string |
| `titre` | string |
| `categorie` | string |
| `albums_possedes` | number |
| `albums_lus` | number |
| `statut` | string |
| `albums_non_possedes_lu` | number |
| `albums_manquants` | number |
| `nb_dedicace` | string |

## DVD

| Colonne | Type |
|---|---|
| `Titre` | string |
| `Genre` | string |
| `Statut` | string |
| `Categorie` | string |
| `Prix` | string |

## Film

| Colonne | Type |
|---|---|
| `movie_uuid` | string |
| `movie_name` | string |
| `runtime_minutes` | number |
| `Statut` | string |

## Jeux de société

| Colonne | Type |
|---|---|
| `Nom` | string |
| `statuts` | string |
| `genre` | string |
| `categorie` | string |
| `prix` | string |
| `annee_sortie` | string |

## Jeux vidéo

| Colonne | Type |
|---|---|
| `titre` | string |
| `statut` | string |
| `marques` | string |
| `dans_ludotheque` | string |
| `liste_souhait` | string |
| `coup_de_coeur` | string |
| `complete_100_pourcent` | string |
| `note` | string |

## Roman

| Colonne | Type |
|---|---|
| `id_unique` | string |
| `titre` | string |
| `auteur` | string |
| `genre` | string |
| `statut` | string |
| `nb_pages` | string |
| `Prix` | string |
| `editeur` | string |
| `annee_sortie` | number |

## Serie

| Colonne | Type |
|---|---|
| `series_uuid` | string |
| `series_name` | string |
| `episodes_seen_count` | number |
| `last_episode_title` | string |
| `episodes_remaining_count` | number |
| `Statut` | string |

Documentation : [Data tables n8n](https://docs.n8n.io/data/data-tables/).
