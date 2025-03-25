import { RouteRecordRaw } from 'vue-router'

const root = 'settings/converter';

const routes : Array<RouteRecordRaw> = [
    {
        path: `/${root}`,
        name: 'ConvertToPdf',
        component: () => import(/* webpackChunkName: "convertToPdf" */ '../views/settings/ConvertToPdf.vue'),
        meta: { 
          requiresAuth: true,
         }
    },     
];


export default routes;