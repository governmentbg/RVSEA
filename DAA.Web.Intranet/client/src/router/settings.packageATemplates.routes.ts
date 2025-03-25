import { RouteRecordRaw } from 'vue-router'

const root = 'settings/packageATemplates';

const routes : Array<RouteRecordRaw> = [
    {
        path: `/${root}`,
        name: 'PackageATemplates',
        component: () => import(/* webpackChunkName: "users" */ '../views/settings/PackageATemplates.vue'),
        meta: { 
          requiresAuth: true,
         }
    }
];


export default routes;