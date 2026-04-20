# Custom Features

This file tracks all custom features added to this Chatwoot fork.
Use it as reference when merging upstream updates.

---

## Kanban Board

**Added:** 2026-04-21
**Updated:** 2026-04-21 (enhancements)
**Route:** `/app/accounts/:accountId/kanban`

### Features
- Multiple pipelines per account
- Drag-and-drop cards between columns
- Click card ID or open-link button to navigate directly to the conversation
- Card shows: contact name, assignee, inbox, status, priority color bar, timer
- Priority picker on each card (none/low/medium/high/urgent) — calls Chatwoot API directly
- Column SLA timer: green → yellow (50%) → red (100%) with configurable minutes per column
- `entered_column_at` resets every time a card moves, so timer is always "time in current column"
- Pipeline flag `auto_add_conversations`: every new conversation is automatically added to the entry column
- Column flag `is_entry_point`: marks which column receives auto-added conversations
- Column field `webhook_url`: fires a POST to this URL whenever a card is moved into the column (N8N integration)

### Webhook payload (sent on card move)
```json
{
  "event": "kanban_card_moved",
  "pipeline": { "id": 1, "name": "Vendas" },
  "column": { "id": 2, "name": "Em Andamento" },
  "conversation": { "id": 10, "display_id": 15, "status": "open", "inbox_id": 1 },
  "card": { "id": 5, "notes": "..." },
  "timestamp": "2026-04-21T00:00:00Z"
}
```

### Files added (do not delete)

**Backend:**
- `db/migrate/20260421000001_create_kanban_pipelines.rb`
- `db/migrate/20260421000002_create_kanban_columns.rb`
- `db/migrate/20260421000003_create_kanban_cards.rb`
- `db/migrate/20260421000004_add_kanban_enhancements.rb`
- `db/migrate/20260421000005_add_kanban_sla_and_timer.rb`
- `app/models/kanban_pipeline.rb`
- `app/models/kanban_column.rb`
- `app/models/kanban_card.rb`
- `app/controllers/api/v1/accounts/kanban_pipelines_controller.rb`
- `app/controllers/api/v1/accounts/kanban_columns_controller.rb`
- `app/controllers/api/v1/accounts/kanban_cards_controller.rb`
- `app/policies/kanban_pipeline_policy.rb`
- `app/policies/kanban_column_policy.rb`
- `app/policies/kanban_card_policy.rb`
- `app/listeners/kanban_listener.rb`
- `app/jobs/kanban_webhook_job.rb`

**Frontend:**
- `app/javascript/dashboard/api/kanban.js`
- `app/javascript/dashboard/store/modules/kanban.js`
- `app/javascript/dashboard/routes/dashboard/kanban/kanban.routes.js`
- `app/javascript/dashboard/routes/dashboard/kanban/KanbanIndex.vue`
- `app/javascript/dashboard/routes/dashboard/kanban/KanbanBoard.vue`
- `app/javascript/dashboard/routes/dashboard/kanban/components/KanbanColumn.vue`
- `app/javascript/dashboard/routes/dashboard/kanban/components/KanbanCard.vue`
- `app/javascript/dashboard/routes/dashboard/kanban/components/KanbanPipelineForm.vue`
- `app/javascript/dashboard/routes/dashboard/kanban/components/KanbanColumnForm.vue`
- `app/javascript/dashboard/routes/dashboard/kanban/components/KanbanCardForm.vue`
- `app/javascript/dashboard/i18n/locale/en/kanban.json`
- `app/javascript/dashboard/i18n/locale/pt_BR/kanban.json`

**Files modified (watch for conflicts on upstream merge):**
- `config/routes.rb` — added `kanban_pipelines` nested routes
- `app/models/account.rb` — added `has_many :kanban_pipelines/columns/cards`
- `app/dispatchers/async_dispatcher.rb` — registered `KanbanListener`
- `app/javascript/dashboard/routes/dashboard/dashboard.routes.js` — added `kanbanRoutes`
- `app/javascript/dashboard/store/index.js` — registered `kanban` store module
- `app/javascript/dashboard/i18n/locale/en/index.js` — added kanban import
- `app/javascript/dashboard/i18n/locale/pt_BR/index.js` — added kanban import
- `app/javascript/dashboard/components-next/sidebar/Sidebar.vue` — added Kanban menu item

### After deploying / after upstream merge
```bash
bundle exec rails db:migrate
bundle exec rake assets:precompile   # production only
```

### API endpoints
```
GET    /api/v1/accounts/:id/kanban_pipelines
POST   /api/v1/accounts/:id/kanban_pipelines
GET    /api/v1/accounts/:id/kanban_pipelines/:pid
PATCH  /api/v1/accounts/:id/kanban_pipelines/:pid
DELETE /api/v1/accounts/:id/kanban_pipelines/:pid

GET    /api/v1/accounts/:id/kanban_pipelines/:pid/kanban_columns
POST   /api/v1/accounts/:id/kanban_pipelines/:pid/kanban_columns
PATCH  /api/v1/accounts/:id/kanban_pipelines/:pid/kanban_columns/:cid
DELETE /api/v1/accounts/:id/kanban_pipelines/:pid/kanban_columns/:cid

GET    /api/v1/accounts/:id/kanban_pipelines/:pid/kanban_cards
POST   /api/v1/accounts/:id/kanban_pipelines/:pid/kanban_cards
PATCH  /api/v1/accounts/:id/kanban_pipelines/:pid/kanban_cards/:kid
DELETE /api/v1/accounts/:id/kanban_pipelines/:pid/kanban_cards/:kid
```

### N8N Integration
1. Create a column (e.g. "Qualificado")
2. Set the Webhook URL to your N8N webhook trigger URL
3. When any card is dragged into that column, N8N receives the payload above
4. Use the `conversation.id` in N8N to call back the Chatwoot API and take actions
