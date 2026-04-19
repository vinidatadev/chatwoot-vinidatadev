class EnableAllPremiumFeatures < ActiveRecord::Migration[7.1]
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

  def up
    # Ativa features para todas as contas existentes
    Account.find_each do |account|
      account.enable_features!(*PREMIUM_FEATURES)
    rescue StandardError => e
      Rails.logger.warn "EnableAllPremiumFeatures: skipping account #{account.id}: #{e.message}"
    end

    # Atualiza defaults para novas contas
    config = InstallationConfig.find_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')
    return unless config

    updated = config.value.map do |feature|
      PREMIUM_FEATURES.include?(feature['name']) ? feature.merge('enabled' => true) : feature
    end
    config.update!(value: updated)
  end

  def down
    # irreversível intencionalmente
  end
end
