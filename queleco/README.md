# Modification Quéleco de DocuSeal

L'image de ce dépôt est l'image officielle de DocuSeal, édition libre, plus **deux ajouts** :
`POST /api/templates/pdf`, qui crée un modèle à partir d'un PDF avec la clé API, et
[l'habillage](#habillage) aux couleurs de Quéleco.

Sans elle, chaque nouveau modèle (ou nouvelle version d'un contrat) devait être glissé à la main dans
l'interface : l'édition libre répond `404 This feature is available in Pro Edition`. Avec elle, le CRM
crée le modèle, règle rôles et champs (`PUT /api/templates/{id}`, déjà libre), envoie la demande
(`POST /api/submissions`) et récupère le PDF signé et le journal d'audit (`GET /api/submissions/{id}`),
sans aucun geste humain.

## La fonction

Corps JSON, au format de l'API Pro pour un PDF en base64 :

```json
{ "name": "Entente-cadre", "documents": [{ "name": "cadre.pdf", "file": "<base64>" }] }
```

- Elle reprend le chemin du téléversement de l'interface (`TemplatesUploadsController#create`) : les champs
  AcroForm du PDF deviennent les champs du modèle, attribués au premier rôle. Les rôles et les zones se
  règlent ensuite par `PUT /api/templates/{id}`, comme aujourd'hui.
- Mêmes droits que l'interface : la clé API d'un administrateur, `authorize!(:create, Template)`.
- Refusés (422) : un fichier qui n'est pas un PDF en base64 (donc toute URL : le serveur ne télécharge
  rien), plus de 20 Mo par PDF ou plus de 10 PDF, un PDF chiffré ou illisible. Le modèle va dans le
  dossier par défaut.
- Réponse : le modèle, au format de `GET /api/templates/{id}`.

Écrite par Quéleco à partir du code libre, sans code de l'édition Pro.

## Essai

`queleco/essai.py` (bibliothèque standard) crée un modèle depuis un PDF à un champ et vérifie un refus. La CI le lance sur l'image construite depuis ce dépôt (`api-pdf` dans `check.yml`). À refaire
à chaque changement de version de DocuSeal : la fonction appelle du code interne qui peut changer.

## Habillage

Les pages de DocuSeal (connexion, tableau de bord, éditeur, signature, document signé) prennent la charte
de Quéleco : celle de la refonte HIG de `queleco-b2b` (`docs/design/refonte-hig/themes.json`, thème
« ivoire-clair », logos de `frontend/webapp/public/brand`). Trois copies, aucune autre vue touchée :

- `habillage/_head_tags.html.erb` remplace `app/views/layouts/_head_tags.html.erb`, rendu par les trois
  mises en page HTML : titre d'onglet « Quéleco Sign » et lien vers la feuille de style ;
- `habillage/queleco/` va dans `/app/public/queleco/` : `theme.css`, le lockup et le symbole ;
- `habillage/icones/` remplace les icônes d'onglet de DocuSeal dans `/app/public/` (mêmes noms).

`theme.css` ne change que les variables de couleur de daisyUI, la police système, les coins et le logo :
aucune mise en page. Le logo garde ses proportions (846,6 × 172,7), jamais dans une boîte carrée.
Elle est chargée avant la feuille de DocuSeal : chaque règle commence par `html[data-theme]`.

À chaque changement de version de DocuSeal, comparer `_head_tags.html.erb` au fichier d'origine et
refaire les captures (connexion, éditeur, signature, document signé, mobile) : le logo repose sur les
liens `a[href="/"]` des partiels `shared/_title`, `submit_form/_docuseal_logo`, `start_form/_docuseal_logo`
et `shared/_logo`.

## Licence (AGPLv3 + 7(b))

- La mention « Propulsé par DocuSeal » reste visible : l'habillage ne touche ni `shared/_powered_by`, ni
  `shared/_attribution`, ni la mention des courriels. Il remplace le logo DocuSeal de l'en-tête par celui de
  Quéleco ; l'attribution demandée par 7(b) est cette mention. Lecture non validée par un avocat.
- AGPLv3 §13 : une version modifiée offerte en ligne doit offrir son code source à ses utilisateurs.
  Avant tout service public de cette image, publier ce dossier `queleco/` et le `Dockerfile` (dépôt
  public ou lien), avec le tag officiel de DocuSeal utilisé. Lecture non validée par un avocat.
