# L’ultime workflow de statistiques

Workflow n8n complet de collecte et de synchronisation des loisirs : livres, livres audio, films, séries, jeux vidéo, jeux de société, DVD/Blu-ray et musique. Cet export conserve les 166 nœuds et les branches du workflow fourni, avec les informations personnelles anonymisées.

## Fichiers

- [Ultime.json](Workflow/Ultime.json) : workflow complet désactivé à l’import.
- [DataTables](DataTables/README.md) : huit CSV contenant uniquement les en-têtes des tables et leur documentation.
- [N8N.csv](GoogleSheets/N8N.csv) : en-têtes des colonnes utilisées par les sorties Google Sheets.
- [docker-compose.yml](docker-compose.yml) : configuration Docker dérivée de la configuration fournie.
- [download_music.sh](download_music.sh) : script portable de téléchargement audio utilisé par la branche musique.

## Parties du workflow

| Partie | Site ou service source | Entrée | Résultat |
|---|---|---|---|
| BD, comics, mangas | [Bubble BD](https://www.bubblebd.com/) | Bubblebd / Souhait1 | Collection, souhaits, PAL, pages, prix, poids, bulles lues et classements |
| Romans | [Gleeph](https://www.gleeph.com/) | Gleeph1 | Table Roman, prix, pages, genres, auteurs, éditeurs et périodes |
| Livres audio | [Audible France](https://www.audible.fr/), via le service personnalisé `audible-api` | Loop Over Items | Table Audible, possession, souhaits et durées |
| Films et séries | [Trakt](https://app.trakt.tv/) et son API | Loop Over Items5 et Loop Over Items6 | Tables Film/Serie, historiques Trakt et statistiques |
| Jeux vidéo | [Loadia](https://loadia.app/) | Edit Fields | Session Loadia, ludothèque, temps de jeu et autres statistiques |
| Jeux de société | [MyLudo](https://www.myludo.fr/) | Paramètres MyLudo | Fiches par lots, table, collection, souhaits et statistiques publiques |
| DVD et Blu-ray | [Blu-ray.com](https://www.blu-ray.com/) | Clear a data table4 | Table DVD, films/séries, supports et prix |
| Musique | YouTube et Google Drive | Playlist | Téléchargement MP3, envoi Drive et retrait des éléments traités de la playlist |

Les nœuds Sheets des différentes parties sont conservés. Les comptages spécifiques Batman, Spider-Man et Star Wars et leurs mappings Sheets ont été retirés. La branche musique utilise une sortie structurée du script pour retrouver le chemin final du MP3.

## API utilisées pour les films et séries

### API Trakt

Le site utilisateur est [app.trakt.tv](https://app.trakt.tv/). Les quatre nœuds HTTP interrogent l’API JSON à l’adresse `https://api.trakt.tv`, avec la version `2` dans les en-têtes.

| Nœud n8n | Requête GET, après l’URL de base | Utilisation dans le workflow |
|---|---|---|
| Trakt API - Get Stats | `/users/{username}/stats` | Statistiques globales du profil |
| Trakt API - Get Stats1 | `/users/{username}/watchlist?extended=full` | Films et séries de la liste à voir |
| Trakt API - Get Stats2 | `/users/{username}/history/movies?extended=full` | Historique des visionnages de films |
| Trakt API - Get Stats3 | `/users/{username}/history/episodes?extended=full` | Historique des épisodes vus, ensuite regroupés par série |

Remplacer `YOUR_TRAKT_USERNAME` dans les quatre URL par le nom d’utilisateur Trakt. Les calculs de durée, genres, pays et périodes sont ensuite effectués par les nœuds Code. Les identifiants IMDb, TMDB et TVDB sont des champs des réponses Trakt.

**Clé et authentification :** créer une application depuis votre compte Trakt, puis remplacer `YOUR_TRAKT_API_KEY` par son **Client ID** dans l’en-tête `trakt-api-key`. Les autres en-têtes de l’export sont `trakt-api-version: 2` et `Content-Type: application/json`.

Si l’accès au profil nécessite une autorisation OAuth, configurer les credentials correspondants dans n8n et l’en-tête `Authorization: Bearer <access_token>`. Le Client ID identifie l’application ; le jeton OAuth autorise l’accès au compte. L’export ne contient aucun jeton et n’inclut pas de parcours de connexion ou de renouvellement OAuth.

**Pagination et détails :** les nœuds de liste à voir et d’historique font avancer `page` avec `{{ $pageCount + 1 }}`. Le nœud des épisodes définit aussi `limit=100`. Le paramètre `extended=full` demande les informations détaillées exploitées par les calculs. Vérifier la récupération de toutes les pages lors de la première exécution, notamment sur une grande collection.

Documentation officielle : [API Trakt](https://docs.trakt.tv/), [en-têtes](https://docs.trakt.tv/docs/required-headers) et [authentification / création d’application](https://docs.trakt.tv/reference/auth).

### API de sortie

- **[Google Sheets API](https://developers.google.com/sheets/api)** : les huit nœuds Google Sheets ajoutent ou mettent à jour les lignes de statistiques dans l’onglet `N8N`. Sélectionner les credentials Google Sheets et un document auquel ce compte a accès.
- **[Telegram Bot API](https://core.telegram.org/bots/api#sendmessage)** : le nœud **Send a text message2** envoie la notification via `sendMessage`. Configurer les credentials du bot et l’identifiant du destinataire.

Les Data Tables sont stockées dans n8n. Le nœud commun **HTTP Request1** contrôle l’accessibilité de votre instance avant la collecte.

## Démarrage commun

Le début est conservé : **Schedule Trigger → Date & Time → Configuration Globale → Loop Over Items4 → HTTP Request1 → If5**. La branche d’échec passe par **Restauration Tunnel1 → Wait1**, puis revient dans la boucle. Le succès HTTP 200 ouvre les différentes branches.

Le planificateur reprend le vendredi à 17 h. Choisir l’horaire et le fuseau de votre installation.

## Configuration

1. Importer le workflow et le laisser désactivé pendant la configuration.
2. Dans **Configuration Globale**, renseigner les URL Bubble BD/Gleeph, les cookies privés et la playlist YouTube. Les cookies vides `[]` doivent être remplacés par vos propres tableaux JSON sérialisés lorsque le service en a besoin.
3. Remplacer l’adresse du contrôle **HTTP Request1**. Configurer les credentials SSH et adapter les commandes de restauration ngrok à votre installation.
4. Renseigner le nom d’utilisateur et la clé Trakt dans les nœuds API ; les credentials requis dépendent de l’accès au compte cible.
5. Renseigner les paramètres Loadia dans **Edit Fields**, le profil MyLudo dans **Paramètres MyLudo**, le cookie DVD dans **Edit Fields1** et `YOUR_BLURAY_USER_ID` dans les contextes/scripts DVD.
6. Fournir votre service Audible à l’adresse configurée dans **HTTP Request Audible API**. Il doit exposer `/audible/export` et renvoyer un tableau `books` compatible avec [Audible.csv](DataTables/Audible.csv).
7. Créer les huit tables et reconnecter chaque nœud Data Table à la bonne table. Les opérations de reconstruction peuvent supprimer les lignes existantes : réserver ces tables à la synchronisation.
8. Créer l’onglet Sheets **N8N** avec les colonnes fournies, sélectionner le document et les credentials sur chaque nœud Sheets.
9. Configurer Google Drive, YouTube, les alertes Discord, les destinataires Telegram et les credentials SSH.
10. Pour la musique, placer le dépôt dans `~/Ultime` sur l’hôte SSH, rendre le script exécutable et vérifier que son dossier `Musique` est le même que le montage Docker `/home/node/.n8n-files`. Adapter **Téléchargement Musique** si le chemin diffère.
11. Tester chaque branche, puis une exécution complète, avant d’activer le planificateur.

Le nœud **Éteindre Tunnel** est relié à la fin de la branche musique, comme dans la source. Dans ce workflow complet, les autres branches peuvent encore travailler : adapter ou désactiver cet arrêt si elles dépendent du même tunnel.

## Docker et dépendances

Copier `.env.example` vers `.env`, configurer les valeurs puis lancer `docker compose up -d` pour une nouvelle installation. Avec une instance existante, reprendre uniquement les réglages nécessaires. Le volume n8n est créé par défaut ; adapter la déclaration pour réutiliser un volume existant.

Pour installer le dépôt renommé dans le dossier `~/Ultime` attendu par le nœud **Téléchargement Musique** :

```bash
cd "$HOME"
git clone https://github.com/zpecetto/Ultime-Workflow-Stats.git Ultime
cd Ultime
```

Si le dossier `~/Ultime` existe déjà, conservez-le et mettez à jour son URL distante :

```bash
git -C "$HOME/Ultime" remote set-url origin https://github.com/zpecetto/Ultime-Workflow-Stats.git
```

Le compose reprend n8n, Browserless et Ollama. Les réglages de durée d’exécution et les limites mémoire viennent de la configuration fournie. Watchtower est disponible sous le profil optionnel `maintenance`.

Le serveur personnalisé `audible-api`, son Dockerfile et son authentification n’étaient pas joints aux fichiers. Le service est conservé sous le profil optionnel `audible` et attend votre dossier `./audible-api`. Ne pas activer ce profil sans fournir ce code ; utiliser votre service existant à la place. Le reste de la pile peut démarrer sans lui, mais la branche Audible en dépend.

Le téléchargement musical nécessite yt-dlp, Deno et ffmpeg sur l’hôte SSH. Le script accepte les variables `YTDLP`, `OUTPUT_DIR` et `COOKIE_FILE`. Le cookie YouTube éventuel reste un fichier privé hors du dépôt.

## Dépôts séparés

Les dépôts BiblioBot, AutoMusicBot, Trakt-Stats, Loadia-Stats, BluRay-Stats et MyLudo-Stats proposent les branches indépendantes. Choisir le workflow complet ou ces extractions pour une même collection, afin de ne pas reconstruire simultanément les mêmes tables.

Le workflow d’assistance Telegram/Ollama est distribué séparément dans Conseil-Ultime. Il n’est pas lancé par ce collecteur.

## Vérification

Les exports sont désactivés, sans credentials personnels, données épinglées ni états d’exécution. Les connexions, références, entrées Merge, JavaScript, expressions et CSV ont été vérifiés localement. Les statistiques de livres hors compteurs supprimés ont été comparées aux sorties de la source. Les chemins audio ont été vérifiés avec des simulations.

Aucun accès à vos comptes de collecte, téléchargement YouTube, envoi Drive ou Telegram ni exécution de production n’a été effectué pour préparer ce dépôt. Les sessions, quotas, changements de pages et services locaux sont à vérifier dans l’installation cible.
