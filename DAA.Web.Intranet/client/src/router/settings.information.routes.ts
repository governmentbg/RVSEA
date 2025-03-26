import { RouteRecordRaw } from 'vue-router'

const root = 'settings/information';

const routes : Array<RouteRecordRaw> = [
    {
        path: `/${root}`,
        name: 'Information',
        component: () => import('../views/settings/InformationAdministration.vue'),
        meta: { 
          requiresAuth: true,
         }
    }, 
    {
        path: `/${root}/display/:id`,
        name: 'InformationItemDisplay',
        component: () => import('../views/information/Display.vue'),
        props: (route) => ({ id: Number.parseInt(route.params.id.toString()) }),
    },     
];


export default routes;