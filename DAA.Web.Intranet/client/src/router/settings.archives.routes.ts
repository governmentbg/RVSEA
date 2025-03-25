import { RouteRecordRaw } from 'vue-router'

const root = 'settings/archives';

const routes : Array<RouteRecordRaw> = [
    {
        path: `/${root}`,
        name: 'Archives',
        component: () => import(/* webpackChunkName: "archives" */ '../views/archives/Index.vue'),
        meta: { 
          requiresAuth: true,
         }
    },
    {
        path: `/${root}/display/:id`,
        name: 'DisplayArchive',
        component:() => import(/* webpackChunkName: "archives" */ '../views/archives/Display.vue'),
        props: route => ({ id: Number.parseInt(route.params.id.toString()) }),
        meta: { 
            requiresAuth: true,
        }
    },
    {
        path: `/${root}/create`,
        name: 'CreateArchive',
        component: () => import(/* webpackChunkName: "archives" */ '../views/archives/Create.vue'),
        meta: { 
          requiresAuth: true,
        },
    },
    {
        path: `/${root}/edit/:id`,
        name: 'EditArchive',
        component: () => import(/* webpackChunkName: "archives" */ '../views/archives/Edit.vue'),
        props: route => ({ id: Number.parseInt(route.params.id.toString()) }),
        meta: { 
            requiresAuth: true,
        }
    },    
];


export default routes;