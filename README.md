# Quéleco Sign (DocuSeal-Queleco)

Code source correspondant (AGPL-3.0, article 13) de l'instance DocuSeal utilisée par Quéleco pour la signature électronique de ses contrats.

- Base : [DocuSeal](https://github.com/docusealco/docuseal), édition libre, version 3.2.6, image `docuseal/docuseal:3.2.6` épinglée par son empreinte dans le `Dockerfile`. Aucun fichier de code de DocuSeal n'est modifié ; seule la vue `layouts/_head_tags` est remplacée pour l'habillage.
- Ajouts de Quéleco (dossier `queleco/`, voir `queleco/README.md`) :
  - une route, `POST /api/templates/pdf`, qui crée un modèle à partir d'un PDF à champs ;
  - l'habillage aux couleurs de Quéleco (`queleco/habillage/`) : feuille de style, logos, icônes et titre d'onglet.
- Licence : AGPL-3.0 (`LICENSE`), avec les conditions additionnelles de DocuSeal (`LICENSE_ADDITIONAL_TERMS`). La mention « Propulsé par DocuSeal » reste dans l'interface.

Construire : `docker build -t docuseal-queleco .`
