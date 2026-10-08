# Quéleco Sign (DocuSeal-Queleco)

Code source correspondant (AGPL-3.0, article 13) de l'instance DocuSeal utilisée par Quéleco pour la signature électronique de ses contrats.

- Base : [DocuSeal](https://github.com/docusealco/docuseal), édition libre, version 3.2.6, image `docuseal/docuseal:3.2.6` épinglée par son empreinte dans le `Dockerfile`. Le code de DocuSeal n'est pas modifié.
- Ajout de Quéleco : une seule route, `POST /api/templates/pdf`, qui crée un modèle à partir d'un PDF à champs (dossier `queleco/`, voir `queleco/README.md`).
- Licence : AGPL-3.0 (`LICENSE`), avec les conditions additionnelles de DocuSeal (`LICENSE_ADDITIONAL_TERMS`). La mention de DocuSeal reste dans l'interface.

Construire : `docker build -t docuseal-queleco .`
