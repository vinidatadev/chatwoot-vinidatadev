class KanbanWebhookJob < ApplicationJob
  queue_as :default

  def perform(url, payload)
    HTTParty.post(
      url,
      body: payload.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'X-Chatwoot-Kanban-Event' => payload[:event]
      },
      timeout: 10
    )
  rescue StandardError => e
    Rails.logger.error "KanbanWebhookJob failed for #{url}: #{e.message}"
  end
end
