import { RouteRecordRaw } from 'vue-router';

const root = 'commission';

const routes: Array<RouteRecordRaw> = [
    {
        path: `/${root}/sessions`,
        name: 'Sessions',
        component: () => import(/* webpackChunkName: "commission" */ '@/views/commission/Sessions.vue'),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/sessions/upcoming`,
        name: 'UpcomingSessions',
        component: () => import(/* webpackChunkName: "commission" */ '@/views/commission/UpcomingSessions.vue'),
        meta: {
            requiresAuth: true,
        },
    },

    {
        path: `/${root}/sessions/past`,
        name: 'PastSessions',
        component: () => import(/* webpackChunkName: "commission" */ '@/views/commission/PastSessions.vue'),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/sessions/display/:id`,
        name: 'DisplaySession',
        component: () => import(/* webpackChunkName: "commission" */ '@/views/commission/sessions/Display.vue'),
        props: (route) => ({ id: Number.parseInt(route.params.id.toString()) }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/sessions/current/:id`,
        name: 'CurrentSession',
        component: () => import(/* webpackChunkName: "commission" */ '@/views/commission/sessions/CurrentSession.vue'),
        props: (route) => ({ id: Number.parseInt(route.params.id.toString()) }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/sessions/agenda/:id`,
        name: 'ManageSessionAgenda',
        component: () => import(/* webpackChunkName: "commission" */ '@/views/commission/sessions/Agenda.vue'),
        props: (route) => ({ id: Number.parseInt(route.params.id.toString()) }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/sessions/edit/protocol/:id`,
        name: 'EditProtocol',
        component: () => import(/* webpackChunkName: "commission" */ '@/views/commission/protocol/Edit.vue'),
        props: (route) => ({
            id: Number.parseInt(route.params.id.toString()),
        }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/sessions/display/protocol/:id`,
        name: 'ViewProtocol',
        component: () => import(/* webpackChunkName: "commission" */ '@/views/commission/protocol/Display.vue'),
        props: (route) => ({
            id: Number.parseInt(route.params.id.toString()),
        }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/sessions/print/transcript/:id`,
        name: 'PrintTranscript',
        component: () => import(/* webpackChunkName: "commission" */ '@/components/protocol/printTranscript.vue'),
        props: (route) => ({
            id: Number.parseInt(route.params.id.toString()),
            items: route.params.items,
        }),
        meta: {
            requiresAuth: true,
        },
    },
];

export default routes;
