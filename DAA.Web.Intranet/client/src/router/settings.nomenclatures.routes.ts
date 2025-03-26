import { RouteRecordRaw } from 'vue-router';

const root = 'settings/nomenclatures';
const routes: Array<RouteRecordRaw> = [
    {
        path: `/${root}`,
        name: 'Nomenclatures',
        component: () => import(/* webpackChunkName: "nomenclatures" */ '../views/nomenclatures/Index.vue'),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/create`,
        name: 'CreateNomenclature',
        component: () => import(/* webpackChunkName: "nomenclatures" */ '../views/nomenclatures/Create.vue'),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/display/:id`,
        name: 'DisplayNomenclature',
        component: () => import(/* webpackChunkName: "nomenclatures" */ '../views/nomenclatures/Display.vue'),
        props: (route) => ({ nomId: Number.parseInt(route.params.id.toString()) }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/edit/:id`,
        name: 'EditNomenclature',
        component: () => import(/* webpackChunkName: "nomenclatures" */ '../views/nomenclatures/Edit.vue'),
        props: (route) => ({ nomId: Number.parseInt(route.params.id.toString()) }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/:parentId/values/display/:id`,
        name: 'DisplayNomenclatureValue',
        component: () => import(/* webpackChunkName: "nomenclatures" */ '../views/nomenclatures/values/Display.vue'),
        props: (route) => ({
            valueId: Number.parseInt(route.params.id.toString()),
            parentId: Number.parseInt(route.params.parentId.toString()),
        }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/:parentId/values/create/`,
        name: 'CreateNomenclatureValue',
        component: () => import(/* webpackChunkName: "nomenclatures" */ '../views/nomenclatures/values/Create.vue'),
        props: (route) => ({ parentId: Number.parseInt(route.params.parentId.toString()) }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/:parentId/values/edit/:id`,
        name: 'EditNomenclatureValue',
        component: () => import(/* webpackChunkName: "nomenclatures" */ '../views/nomenclatures/values/Edit.vue'),
        props: (route) => ({
            valueId: Number.parseInt(route.params.id.toString()),
            parentId: Number.parseInt(route.params.parentId.toString()),
        }),
        meta: {
            requiresAuth: true,
        },
    },
];

export default routes;
