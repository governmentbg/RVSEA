import { RouteRecordRaw } from 'vue-router'

const root = 'settings/tasksTemplates';

const routes : Array<RouteRecordRaw> = [
    {
        path: `/${root}`,
        name: 'TasksTemplates',
        component: () => import(/* webpackChunkName: "users" */ '../views/settings/TasksTemplates.vue'),
        meta: { 
          requiresAuth: true,
         }
    }
];


export default routes;