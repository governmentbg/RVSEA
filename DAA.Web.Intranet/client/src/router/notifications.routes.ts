import { RouteRecordRaw } from 'vue-router'

const root = 'notifications';

const routes: Array<RouteRecordRaw> = [
    {
        path: `/${root}`,
        name: 'UserNotifications',
        component: () => import(/* webpackChunkName: "notifications" */ '../views/notifications/Index.vue'),
        meta: {
            requiresAuth: true,
        }
    },
];


export default routes;