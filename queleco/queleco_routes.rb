# frozen_string_literal: true

# Quéleco : route de Api::QuelecoTemplatesPdfController (voir ce fichier et queleco/README.md).
Rails.application.routes.prepend do
  post '/api/templates/pdf', to: 'api/queleco_templates_pdf#create', defaults: { format: :json }
end
