import { parseBoolean } from '@/helpers/boolean.helper';
import { RouteRecordRaw } from 'vue-router';
import { validate as isValidGuid } from 'uuid';

const routes: Array<RouteRecordRaw> = [
    {
        path: '/reports',
        name: 'Reports',
        props: (route) => ({
            componentName: route.params.componentName,
        }),
        component: () => import('@/views/reports/Reports.vue'),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: '/reports/:componentName/:id?',
        name: 'BaseReport',
        props: (route) => ({
            componentName: route.params.componentName,
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)),
            externalIdentifier: route.query.externalIdentifier
                ? Number.parseInt(route.query.externalIdentifier.toString())
                : undefined,
        }),
        component: () => import('@/views/reports/Base.vue'),
        meta: {
            requiresAuth: true,
        },
    },
];

export default routes;
