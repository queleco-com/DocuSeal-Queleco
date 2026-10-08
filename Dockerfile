# DocuSeal, édition libre (AGPLv3 + conditions 7(b)), plus une seule fonction Quéleco :
# POST /api/templates/pdf (queleco/README.md). L'empreinte fait foi ; l'étiquette ne sert
# qu'à la lecture. Changer de version, c'est changer les deux dans une PR revue (README.md).
FROM docuseal/docuseal:3.2.6@sha256:58c76f6d28561b7b8f0bb447941a7e2bac376300ea96871125f6c762e7e63385
COPY --chown=docuseal:docuseal queleco/queleco_templates_pdf_controller.rb /app/app/controllers/api/queleco_templates_pdf_controller.rb
COPY --chown=docuseal:docuseal queleco/queleco_routes.rb /app/config/initializers/queleco_routes.rb
