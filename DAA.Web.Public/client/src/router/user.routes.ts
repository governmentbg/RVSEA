import { RouteRecordRaw } from 'vue-router';

const root = 'user/profile';

const routes: Array<RouteRecordRaw> = [
    {
        path: `/${root}`,
        name: 'UserProfile',
        props: true,
        component: () => import(/* webpackChunkName: "userprofile" */ '@/views/userProfile/Details.vue'),
        meta: {
            requiresAuth: true,
        },
    },
];

export default routes;
