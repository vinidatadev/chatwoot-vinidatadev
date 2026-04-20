import { frontendURL } from '../../../helper/URLHelper';

const KanbanIndex = () => import('./KanbanIndex.vue');

export const routes = [
  {
    path: frontendURL('accounts/:accountId/kanban'),
    name: 'kanban_index',
    meta: {
      permissions: ['administrator', 'agent'],
    },
    component: KanbanIndex,
  },
];
