# Modification Quéleco de DocuSeal

L'image de ce dépôt est l'image officielle de DocuSeal, édition libre, plus **une seule fonction** :
`POST /api/templates/pdf`, qui crée un modèle à partir d'un PDF avec la clé API.

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

`queleco/essai.py` (bibliothèque standard) crée un modèle depuis un PDF à un champ et vérifie un refus. Notre intégration continue le lance sur l'image construite. À refaire
à chaque changement de version de DocuSeal : la fonction appelle du code interne qui peut changer.

## Licence (AGPLv3 + 7(b))

- La mention « Propulsé par DocuSeal » reste visible : rien ici ne touche à l'interface.
- AGPLv3 §13 : une version modifiée offerte en ligne doit offrir son code source à ses utilisateurs.
  Avant tout service public de cette image, publier ce dossier `queleco/` et le `Dockerfile` (dépôt
  public ou lien), avec le tag officiel de DocuSeal utilisé. Lecture non validée par un avocat.
