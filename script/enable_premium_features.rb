# Script para ativar todas as features premium/enterprise em todas as contas
# Uso: bundle exec rails runner script/enable_premium_features.rb

PREMIUM_FEATURES = %w[
  sla
  channel_voice
  captain_integration
  captain_integration_v2
  custom_roles
  audit_logs
  disable_branding
  csat_review_notes
  conversation_required_attributes
  advanced_assignment
  saml
  custom_tools
  linear_integration
  notion_integration
  report_rollup
  whatsapp_campaign
  quoted_email_reply
  email_continuity_on_api_channel
  ip_lookup
  custom_reply_email
  custom_reply_domain
].freeze

puts "==> Ativando features premium para todas as contas..."

Account.find_each do |account|
  account.enable_features!(*PREMIUM_FEATURES)
  puts "  [OK] Account ##{account.id} - #{account.name}"
rescue StandardError => e
  puts "  [ERRO] Account ##{account.id}: #{e.message}"
end

puts "\n==> Atualizando ACCOUNT_LEVEL_FEATURE_DEFAULTS para novas contas..."

config = InstallationConfig.find_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')

if config
  updated_features = config.value.map do |feature|
    if PREMIUM_FEATURES.include?(feature['name'])
      feature.merge('enabled' => true)
    else
      feature
    end
  end
  config.update!(value: updated_features)
  puts "  [OK] ACCOUNT_LEVEL_FEATURE_DEFAULTS atualizado"
else
  puts "  [AVISO] ACCOUNT_LEVEL_FEATURE_DEFAULTS não encontrado, rode 'rails db:seed' primeiro"
end

puts "\n==> Concluído. Features ativadas:"
PREMIUM_FEATURES.each { |f| puts "  - #{f}" }
