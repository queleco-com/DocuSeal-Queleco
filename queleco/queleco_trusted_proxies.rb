# frozen_string_literal: true

# Quéleco, bouclier Cloudflare (revue Ray 2026-11-05, note 3) : quand Cloudflare est devant
# sign.queleco.com, la piste d'audit (request.remote_ip) doit garder l'adresse du signataire,
# pas celle d'une machine Cloudflare. On ajoute aux proxys de confiance de Rails (réseaux privés,
# dont l'edge Railway) les plages publiées par Cloudflare (https://www.cloudflare.com/ips-v4 et
# /ips-v6, lues le 2026-11-05). Rails lit X-Forwarded-For de droite à gauche et s'arrête à la
# première adresse non fiable : une adresse forgée par le navigateur, à gauche, est ignorée.
# Sans Cloudflare, rien ne change.
require 'ipaddr'

QUELECO_CLOUDFLARE_RANGES = %w[
  173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18
  108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17
  162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22
  2400:cb00::/32 2606:4700::/32 2803:f800::/32 2405:b500::/32 2405:8100::/32
  2a06:98c0::/29 2c0f:f248::/32
].map { |range| IPAddr.new(range) }.freeze

Rails.application.config.action_dispatch.trusted_proxies =
  ActionDispatch::RemoteIp::TRUSTED_PROXIES + QUELECO_CLOUDFLARE_RANGES
