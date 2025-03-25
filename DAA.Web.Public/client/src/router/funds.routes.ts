import { RouteRecordRaw } from 'vue-router';
import { validate as isValidGuid } from 'uuid';
import { parseBoolean } from '@/helpers/boolean.helper';

const root = 'funds';

const routes: Array<RouteRecordRaw> = [
    {
        path: `/${root}/display/:id?`,
        name: 'DisplayFund',
        component: () => import(/* webpackChunkName: "funds" */ '../views/funds/Display.vue'),
        props: (route) => ({
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)),
            externalIdentifier: route.query.externalIdentifier
                ? Number.parseInt(route.query.externalIdentifier.toString())
                : undefined,
        }),
    },
];

export default routes;
