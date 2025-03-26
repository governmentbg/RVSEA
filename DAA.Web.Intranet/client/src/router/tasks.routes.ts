import { RouteRecordRaw } from 'vue-router'

const root = 'tasks';

const routes : Array<RouteRecordRaw> = [
    {
        path: `/${root}/my`,
        name: 'MyTasks',
        component: () => import(/* webpackChunkName: "tasks" */ '../views/tasks/IndexMyTasks.vue'),
        meta: { 
          requiresAuth: true,
         }
    },
    {
        path: `/${root}/assignedByMe`,
        name: 'TasksAssignedByMe',
        component: () => import(/* webpackChunkName: "tasks" */ '../views/tasks/IndexAssignedByMe.vue'),
        meta: { 
          requiresAuth: true,
         }
    },
    {
        path: `/${root}/display/:id`,
        name: 'DisplayTask',
        component: () => import(/* webpackChunkName: "tasks" */ '../views/tasks/Display.vue'),
        props: route => ({ id: Number.parseInt(route.params.id.toString()) }),
        meta: {
            requiresAuth: true,
        }
    },
];


export default routes;