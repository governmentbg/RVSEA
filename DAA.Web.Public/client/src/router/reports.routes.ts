import { RouteRecordRaw } from 'vue-router';

const routes: Array<RouteRecordRaw> = [
    {
        path: '/reports',
        name: 'Reports',
        component: () => import('@/views/reports/Reports.vue'),
    },
    {
        path: '/reports/:componentName',
        name: 'BaseReport',
        props: (route) => ({
            componentName: route.params.componentName,
        }),
        component: () => import('@/views/reports/Base.vue'),
    },
];

export default routes;
