import { RouteRecordRaw } from 'vue-router';
import { validate as isValidGuid } from 'uuid';
import { parseBoolean } from '@/helpers/boolean.helper';

const root = 'inventories';

const routes: Array<RouteRecordRaw> = [
    {
        path: `/${root}`,
        name: 'Inventories',
        component: () => import(/* webpackChunkName: "inventories" */ '../views/inventories/Index.vue'),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/display/:id?`,
        name: 'DisplayInventory',
        component: () => import(/* webpackChunkName: "inventories" */ '../views/inventories/Display.vue'),
        props: (route) => ({
            //id: route.params.id && Number.parseInt(route.params.id.toString()) > 0 ? Number.parseInt(route.params.id.toString()) : undefined,
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)),
            externalIdentifier: route.query.externalIdentifier
                ? Number.parseInt(route.query.externalIdentifier.toString())
                : undefined,
        }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/create`,
        name: 'CreateInventory',
        component: () => import(/* webpackChunkName: "inventories" */ '../views/inventories/Create.vue'),
        props: (route) => ({
            // archiveId: route.query.archiveId ? Number.parseInt(route.query.archiveId.toString()) : undefined,
            // fundDraftId: route.query.fundDraftId ? Number.parseInt(route.query.fundDraftId.toString()) : undefined,
            fundSystemIdentifier:
                route.query.fundSystemIdentifier && isValidGuid(route.query.fundSystemIdentifier.toString())
                    ? route.query.fundSystemIdentifier
                    : undefined,
            fundHasExternalSource: parseBoolean(String(route.query.fundHasExternalSource)),
            fundExternalIdentifier: route.query.fundExternalIdentifier
                ? Number.parseInt(route.query.fundExternalIdentifier.toString())
                : undefined,
            descriptionLevel: route.query.descriptionLevel,
            startProcess: parseBoolean(String(route.query.startProcess)),
        }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/edit/:id`,
        name: 'EditInventory',
        component: () => import(/* webpackChunkName: "inventories" */ '../views/inventories/Edit.vue'),
        props: (route) => ({
            //id: Number.parseInt(route.params.id.toString())
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
        }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/print/:componentName/:id?`,
        name: 'PrintInventory',
        component: () => import(/* webpackChunkName: "commission" */ '@/components/inventory/print.vue'),
        props: (route) => ({
            componentName: route.params.componentName,
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)),
            externalIdentifier: route.query.externalIdentifier
                ? Number.parseInt(route.query.externalIdentifier.toString())
                : undefined,
            processTypeId: route.query.processTypeId
                ? Number.parseInt(route.query.processTypeId.toString())
                : undefined,
        }),
        meta: {
            requiresAuth: true,
        },
    },
];

export default routes;
