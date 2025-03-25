import { RouteRecordRaw } from 'vue-router';
import { validate as isValidGuid } from 'uuid';
import { parseBoolean } from '@/helpers/boolean.helper';

const root = 'archiveEntities';

const routes: Array<RouteRecordRaw> = [
    {
        path: `/${root}/display/:id?`,
        name: 'DisplayArchivalEntity',
        component: () => import(/* webpackChunkName: "archivalEntities" */ '@/views/archiveEntities/Display.vue'),
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
        name: 'ModifyArchivalEntity',
        component: () => import(/* webpackChunkName: "archivalEntities" */ '@/views/archiveEntities/Modify.vue'),
        props: (route) => ({
            sysId: route.params.sysId && isValidGuid(route.params.sysId.toString()) ? route.params.sysId : undefined,
        }),
    },
];

export default routes;
