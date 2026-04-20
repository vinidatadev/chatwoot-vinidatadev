# Custom Features

This file tracks all custom features added to this Chatwoot fork.
Use it as reference when merging upstream updates.

---

## Kanban Board

**Added:** 2026-04-21  
**Route:** `/app/accounts/:accountId/kanban`

### What it does
A Kanban board to organize conversations into pipelines and columns with drag-and-drop support.

### Files added (do not delete)

**Backend:**
- `db/migrate/20260421000001_create_kanban_pipelines.rb`
- `db/migrate/20260421000002_create_kanban_columns.rb`
- `db/migrate/20260421000003_create_kanban_cards.rb`
- `app/models/kanban_pipeline.rb`
- `app/models/kanban_column.rb`
- `app/models/kanban_card.rb`
- `app/controllers/api/v1/accounts/kanban_pipelines_controller.rb`
- `app/controllers/api/v1/accounts/kanban_columns_controller.rb`
- `app/controllers/api/v1/accounts/kanban_cards_controller.rb`
- `app/policies/kanban_pipeline_policy.rb`
- `app/policies/kanban_column_policy.rb`
- `app/policies/kanban_card_policy.rb`

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
