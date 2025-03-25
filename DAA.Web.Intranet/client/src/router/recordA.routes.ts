import { RouteRecordRaw } from 'vue-router';
import { validate as isValidGuid } from 'uuid';
import { parseBoolean } from '@/helpers/boolean.helper';

const root = 'recordsA';

const routes : Array<RouteRecordRaw> = [
    {
        path: `/${root}`,
        name: 'RecordsA',
        component: () => import(/* webpackChunkName: "recordA" */ '../views/recordsA/Index.vue'),
        meta: {
          requiresAuth: true,
         }
    },
    {
        path: `/${root}/fund/display/:id?`,
        name: 'DisplayRecordAFund',
        component:() => import(/* webpackChunkName: "recordA" */ '../views/recordsA/funds/Display.vue'),
        props: route => ({
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)),
            externalIdentifier: route.query.externalIdentifier ? Number.parseInt(route.query.externalIdentifier.toString()) : undefined
        }),
        meta: {
            requiresAuth: true,
        }
    },
    {
        path: `/${root}/inventory/display/:id?`,
        name: 'DisplayRecordAInventory',
        component:() => import(/* webpackChunkName: "recordA" */ '../views/recordsA/inventories/Display.vue'),
        props: route => ({
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)),
            externalIdentifier: route.query.externalIdentifier ? Number.parseInt(route.query.externalIdentifier.toString()) : undefined
        }),
        meta: {
            requiresAuth: true,
        }
    },
];


export default routes;