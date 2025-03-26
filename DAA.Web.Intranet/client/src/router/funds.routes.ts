import { RouteRecordRaw } from 'vue-router';
import { validate as isValidGuid } from 'uuid';
import { parseBoolean } from '@/helpers/boolean.helper';

const root = 'funds';

const routes : Array<RouteRecordRaw> = [
    {
        path: `/${root}`,
        name: 'Funds',
        component: () => import(/* webpackChunkName: "funds" */ '../views/funds/Index.vue'),
        meta: {
          requiresAuth: true,
         }
    },
    {
        path: `/${root}/display/:id?`,
        name: 'DisplayFund',
        component:() => import(/* webpackChunkName: "funds" */ '../views/funds/Display.vue'),
        props: route => ({
            //id: route.params.id && Number.parseInt(route.params.id.toString()) > 0 ? Number.parseInt(route.params.id.toString()) : undefined,
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)),
            externalIdentifier: route.query.externalIdentifier ? Number.parseInt(route.query.externalIdentifier.toString()) : undefined
        }),
        meta: {
            requiresAuth: true,
        }
    },
    {
        path: `/${root}/create`,
        name: 'CreateFund',
        component: () => import(/* webpackChunkName: "funds" */ '../views/funds/Create.vue'),
        meta: {
          requiresAuth: true,
        },
		props: route => ({
			type: route.query.type
		})
    },
    {
        path: `/${root}/edit/:id`,
        name: 'EditFund',
        component: () => import(/* webpackChunkName: "funds" */ '../views/funds/Edit.vue'),
        props: route => ({
            //id: Number.parseInt(route.params.id.toString())
            id: isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
        }),
        meta: {
            requiresAuth: true,
        }
    },
];


export default routes;