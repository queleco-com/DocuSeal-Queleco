# frozen_string_literal: true

# Quéleco : le portail affiche la page de signature dans son propre cadre (iframe), sans
# envoyer le client vers une autre adresse. Rails envoie « X-Frame-Options: SAMEORIGIN »
# sur toutes les pages, ce qui l'interdit. Ce garde-fou le lève pour une seule famille de
# pages, celles qu'un signataire ouvre par son lien (GET /s/<slug> et /s/<slug>/completed),
# et seulement pour les origines du portail (CSP frame-ancestors). Toutes les autres pages
# (connexion, administration, API) gardent SAMEORIGIN.
#
# QUELECO_CADRE_ORIGINES : origines permises, séparées par des espaces. Une valeur qui n'est
# pas une origine https:// exacte est ignorée. Vide ou absente : rien ne change.
module QuelecoCadre
  ORIGINE = %r{\Ahttps://[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+(:\d{1,5})?\z}
  CHEMIN = %r{\A/s/[A-Za-z0-9_-]+(/completed)?/?\z}

  def self.origines(valeur = ENV.fetch('QUELECO_CADRE_ORIGINES', 'https://portail.queleco.com'))
    valeur.to_s.split.select { |origine| ORIGINE.match?(origine) }.uniq.freeze
  end

  class Middleware
    def initialize(app, origines = QuelecoCadre.origines)
      @app = app
      @ancetres = origines.empty? ? nil : "frame-ancestors 'self' #{origines.join(' ')}"
    end

    def call(env)
      status, headers, body = @app.call(env)
      if @ancetres && %w[GET HEAD].include?(env['REQUEST_METHOD']) && CHEMIN.match?(env['PATH_INFO'].to_s)
        headers.keys.each { |cle| headers.delete(cle) if cle.casecmp?('x-frame-options') }
        cle_csp = headers.keys.find { |cle| cle.casecmp?('content-security-policy') }
        csp = cle_csp && headers.delete(cle_csp).to_s.strip
        headers['content-security-policy'] = csp.to_s.empty? ? @ancetres : "#{csp.chomp(';')}; #{@ancetres}"
      end
      [status, headers, body]
    end
  end
end

Rails.application.config.middleware.insert_before 0, QuelecoCadre::Middleware
