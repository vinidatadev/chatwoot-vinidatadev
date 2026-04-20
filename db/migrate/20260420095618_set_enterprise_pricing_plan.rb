class SetEnterprisePricingPlan < ActiveRecord::Migration[7.1]
  def up
    # Define o plano como enterprise para liberar todas as funcionalidades
    # incluindo DASHBOARD_SCRIPTS e outras configs internas no Super Admin
    config = InstallationConfig.find_or_initialize_by(name: 'INSTALLATION_PRICING_PLAN')
    config.value = 'enterprise'
    config.locked = false
    config.save!

    # Garante que a quantidade também está definida
    qty = InstallationConfig.find_or_initialize_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY')
    qty.value = 1000
    qty.locked = false
    qty.save!
  end

  def down
    InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN')&.update!(value: 'community')
    InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY')&.update!(value: 0)
  end
end
