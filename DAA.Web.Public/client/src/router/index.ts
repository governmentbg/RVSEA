import authorization from '@/helpers/authorization.helper';
import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router';
import authenticationRoutes from './authentication.routes';
import reportsRoutes from './reports.routes';
import errorRoutes from './error.routes';
import inventoriesRoutes from '@/router/inventories.routes';
import archiveEntities from '@/router/archivalEntity.routes';
import fundsRoutes from '@/router/funds.routes';
import documentsRoutes from '@/router/document.routes';
import applicationsRoutes from './applications.routes';
import filmsRoutes from '@/router/films.routes';
import userProfile from '@/router/user.routes';

const routes: Array<RouteRecordRaw> = [
    {
        path: '/',
        name: 'Home',
        component: () => import(/* webpackChunkName: "home" */ '../views/Home.vue'),
    },
    {
        path: '/search',
        name: 'Search',
        component: () => import(/* webpackChunkName: "home" */ '@/views/Home.vue'),
    },
    {
        path: `/information/display/:id`,
        name: 'InformationItemDisplay',
        component: () => import('../views/information/Display.vue'),
        props: (route) => ({ id: Number.parseInt(route.params.id.toString()) }),
    },  
    ...applicationsRoutes,
    ...authenticationRoutes,
    ...errorRoutes,
    ...reportsRoutes,
    ...inventoriesRoutes,
    ...archiveEntities,
    ...fundsRoutes,
    ...documentsRoutes,
    ...filmsRoutes,
    ...userProfile,
];

const router = createRouter({
    history: createWebHistory(process.env.BASE_URL),
    routes,
});

router.beforeEach(async (to) => {
    const { requiresAuth } = to.meta;
    if (requiresAuth) {
        if (!authorization.isAuthenticated()) {
            return {
                name: 'Login',
                query: { redirect: to.fullPath },
            };
        }
    }
    // explicitly return false to cancel the navigation
    //return false
});

export default router;
