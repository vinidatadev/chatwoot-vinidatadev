class KanbanListener < BaseListener
  # When a new conversation is created, auto-add to pipelines that have auto_add_conversations enabled
  def conversation_created(event)
    conversation, account = extract_conversation_and_account(event)
    return unless account

    pipelines = account.kanban_pipelines.where(auto_add_conversations: true)
    pipelines.each do |pipeline|
      entry_col = pipeline.entry_column
      next unless entry_col

      # Avoid duplicates
      next if pipeline.kanban_cards.exists?(conversation_id: conversation.id)

      pipeline.kanban_cards.create!(
        account: account,
        kanban_column: entry_col,
        conversation: conversation,
        position: entry_col.kanban_cards.count
      )
    end
  end

  # When a card moves to a new column, fire the column's webhook_url if set
  def kanban_card_moved(event)
    card = event.data[:card]
    column = event.data[:column]
    return unless column&.webhook_url.present?

    KanbanWebhookJob.perform_later(column.webhook_url, build_payload(card, column))
  end

  private

  def build_payload(card, column)
    {
      event: 'kanban_card_moved',
      pipeline: { id: card.kanban_pipeline_id, name: card.kanban_pipeline.name },
      column: { id: column.id, name: column.name },
      conversation: {
        id: card.conversation_id,
        display_id: card.conversation.display_id,
        status: card.conversation.status,
        inbox_id: card.conversation.inbox_id
      },
      card: { id: card.id, notes: card.notes },
      timestamp: Time.zone.now.iso8601
    }
  end
end
