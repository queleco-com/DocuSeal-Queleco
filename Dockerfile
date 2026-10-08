# DocuSeal, édition libre (AGPLv3 + conditions 7(b)), plus deux ajouts Quéleco (queleco/README.md) :
# POST /api/templates/pdf et l'habillage aux couleurs de Quéleco. L'empreinte fait foi ; l'étiquette
# ne sert qu'à la lecture. Changer de version, c'est changer les deux dans une PR revue (README.md).
FROM docuseal/docuseal:3.2.6@sha256:58c76f6d28561b7b8f0bb447941a7e2bac376300ea96871125f6c762e7e63385
COPY --chown=docuseal:docuseal queleco/queleco_templates_pdf_controller.rb /app/app/controllers/api/queleco_templates_pdf_controller.rb
COPY --chown=docuseal:docuseal queleco/queleco_routes.rb /app/config/initializers/queleco_routes.rb
COPY --chown=docuseal:docuseal queleco/habillage/_head_tags.html.erb /app/app/views/layouts/_head_tags.html.erb
COPY --chown=docuseal:docuseal queleco/habillage/_meta.html.erb /app/app/views/shared/_meta.html.erb
COPY --chown=docuseal:docuseal queleco/habillage/queleco/theme.css queleco/habillage/queleco/lockup-clair.svg queleco/habillage/queleco/symbole.svg /app/public/queleco/
COPY --chown=docuseal:docuseal queleco/habillage/icones/favicon.ico queleco/habillage/icones/favicon.svg queleco/habillage/icones/favicon-16x16.png queleco/habillage/icones/favicon-32x32.png queleco/habillage/icones/favicon-96x96.png queleco/habillage/icones/apple-icon-180x180.png queleco/habillage/icones/apple-touch-icon.png queleco/habillage/icones/apple-touch-icon-precomposed.png queleco/habillage/icones/preview.png /app/public/
