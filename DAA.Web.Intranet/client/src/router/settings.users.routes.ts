import { RouteRecordRaw } from 'vue-router';

const root = 'settings/users';

const routes: Array<RouteRecordRaw> = [
    {
        path: `/${root}`,
        name: 'Users',
        component: () => import(/* webpackChunkName: "users" */ '../views/users/internal/Index.vue'),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/display/:id`,
        name: 'DisplayUser',
        component: () => import(/* webpackChunkName: "users" */ '../views/users/internal/Display.vue'),
        props: (route) => ({ userid: route.params.id }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/create`,
        name: 'CreateUser',
        component: () => import(/* webpackChunkName: "users" */ '../views/users/internal/Create.vue'),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/edit/:id`,
        name: 'EditUser',
        component: () => import(/* webpackChunkName: "users" */ '../views/users/internal/Edit.vue'),
        props: (route) => ({ userid: route.params.id }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/external`,
        name: 'ExternalUsers',
        component: () => import(/* webpackChunkName: "users" */ '../views/users/external/Index.vue'),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/external/display/:id`,
        name: 'DisplayExternalUser',
        component: () => import(/* webpackChunkName: "users" */ '../views/users/external/Display.vue'),
        props: (route) => ({ userid: route.params.id }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/external/edit/:id`,
        name: 'EditExternalUser',
        component: () => import(/* webpackChunkName: "users" */ '../views/users/external/Edit.vue'),
        props: (route) => ({ userid: route.params.id }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/create/reader`,
        name: 'CreateReaderUser',
        component: () => import(/* webpackChunkName: "users" */ '../views/users/external/readers/Create.vue'),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/edit/reader/:id`,
        name: 'EditReaderUser',
        component: () => import(/* webpackChunkName: "users" */ '../views/users/external/readers/Edit.vue'),
        props: (route) => ({ userid: route.params.id }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/readers`,
        name: 'ReaderUsers',
        component: () => import(/* webpackChunkName: "users" */ '../views/users/external/readers/Index.vue'),
        props: (route) => ({ userid: route.params.id }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/verifyChecksums`,
        name: 'VerifyChecksums',
        component: () => import(/* webpackChunkName: "users" */ '@/components/fileReport/displayFileReport.vue'),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/avatar/display`,
        name: 'DisplayAvatar',
        component: () => import(/* webpackChunkName: "users" */ '../views/users/internal/avatar/Display.vue'),
        meta: {
            requiresAuth: true,
        },
    },
];

export default routes;
