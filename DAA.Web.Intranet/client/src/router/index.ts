import { createRouter, createWebHistory, RouteRecordRaw } from "vue-router";
import authenticationRoutes from "@/router/authentication.routes";
import errorRoutes from "@/router/error.routes";
import usersRoutes from "@/router/settings.users.routes";
import archivesRoutes from "@/router/settings.archives.routes";
import fundsRoutes from "@/router/funds.routes";
import inventoriesRoutes from "@/router/inventories.routes";
import archiveEntities from "@/router/archivalEntity.routes";
import documentsRoutes from "@/router/document.routes";
import nomenclaturesRoutes from "@/router/settings.nomenclatures.routes";
import filmsRoutes from "@/router/films.routes";
import reports from "@/router/reports.routes";
import authorization from "@/helpers/authorization.helper";
import authenticationService from "@/services/authentication.service";
import packageATemplatesRoutes from './settings.packageATemplates.routes';
import eDocsCollectionRoutes from './eDocsCollection.routes';
import commissionRoutes from './commission.routes';
import tasksRoutes from './tasks.routes';
// import notificationsRoutes from './notifications.routes';
import tasksTemplatesRoutes from './settings.tasksTemplates.routes';
import recordARoutes from '@/router/recordA.routes';
import converter from '@/router/settings.converter.routes';
import information from '@/router/settings.information.routes';

const routes: Array<RouteRecordRaw> = [
    {
        path: '/',
        name: 'Home',
        component: () => import(/* webpackChunkName: "home" */ '@/views/Home.vue'),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: '/search',
        name: 'Search',
        component: () => import(/* webpackChunkName: "home" */ '@/views/Home.vue'),
    },

    ...archiveEntities,
    ...archivesRoutes,
    ...authenticationRoutes,
    ...documentsRoutes,
    ...eDocsCollectionRoutes,
    ...errorRoutes,
    ...filmsRoutes,
    ...fundsRoutes,
    ...inventoriesRoutes,
    ...nomenclaturesRoutes,
    ...packageATemplatesRoutes,
    ...reports,
    ...usersRoutes,
    ...commissionRoutes,
	...tasksRoutes,
    // ...notificationsRoutes,
    ...tasksTemplatesRoutes,
    ...recordARoutes,
    ...converter,
    ...information,
]

const router = createRouter({
    history: createWebHistory(process.env.BASE_URL),
    routes,
})

router.beforeEach(async (to) => {
    console.log('to:     ', to)
    const { requiresAuth } = to.meta
    if (requiresAuth) {
        if (!authorization.isAuthenticated()) {
            const success = await authenticationService.authenticate()
            if (!success) {
                return {
                    name: 'AccessDenied',
                    query: { redirect: to.fullPath },
                }
            }
        }
    }
})

export default router
