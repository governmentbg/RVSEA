import { RouteRecordRaw } from 'vue-router';
import { validate as isValidGuid } from 'uuid';
import { parseBoolean } from '@/helpers/boolean.helper';

const root = 'inventories';

const routes: Array<RouteRecordRaw> = [
    {
        path: `/${root}/display/:id?`,
        name: 'DisplayInventory',
        component: () => import(/* webpackChunkName: "inventories" */ '../views/inventories/Display.vue'),
        props: (route) => ({
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)),
            externalIdentifier: route.query.externalIdentifier
                ? Number.parseInt(route.query.externalIdentifier.toString())
                : undefined,
        }),
    },
    {
        path: `/${root}/modify/:sysId?`,
        name: 'ModifyInventory',
        component: () => import(/* webpackChunkName: "inventories" */ '../views/inventories/Modify.vue'),
        props: (route) => ({
            sysId: route.params.sysId && isValidGuid(route.params.sysId.toString()) ? route.params.sysId : undefined,
        }),
    },
];

export default routes;
