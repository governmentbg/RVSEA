import { RouteRecordRaw } from 'vue-router';
import { validate as isValidGuid } from 'uuid';
import { parseBoolean } from '@/helpers/boolean.helper';

const root = 'archiveEntities';

const routes : Array<RouteRecordRaw> = [
  {
    path: `/${root}`,
    component: () =>  import(/* webpackChunkName: "archivalEntities" */ '@/views/archiveEntities/Index.vue'),
    name: 'ArchiveEntities',
    meta: { 
      requiresAuth: true,
    },
  },   
  {
      path: `/${root}/create`,
      name: 'CreateArchiveEntity',
      component: () => import(/* webpackChunkName: "archivalEntities" */ '@/views/archiveEntities/Create.vue'),
      props: route => ({ 
        inventorySystemIdentifier: route.query.inventorySystemIdentifier && isValidGuid(String(route.query.inventorySystemIdentifier)) ? route.query.inventorySystemIdentifier : undefined,
        inventoryHasExternalSource: parseBoolean(String(route.query.inventoryHasExternalSource)),
        inventoryExternalIdentifier: route.query.inventoryExternalIdentifier ? Number.parseInt(String(route.query.inventoryExternalIdentifier)) : undefined,
        descriptionLevel: route.query.descriptionLevel,
    }),
      meta: { 
        requiresAuth: true,
      },
    },   
    {
      path: `/${root}/display/:id?`,
      name: 'DisplayArchiveEntity',
      component: () => import(/* webpackChunkName: "archivalEntities" */ '@/views/archiveEntities/Display.vue'),
      props: route => ({ 
        id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
        hasExternalSource: parseBoolean(String(route.query.hasExternalSource)), 
        externalIdentifier: route.query.externalIdentifier ? Number.parseInt(route.query.externalIdentifier.toString()) : undefined,
      }),
      meta: { 
          requiresAuth: true,
      }
    }, 
    {
      path: `/${root}/edit/:id?`,
      name: 'EditArchiveEntity',
      component: () => import(/* webpackChunkName: "archivalEntities" */ '@/views/archiveEntities/Edit.vue'),
      props: route => ({ 
        id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
      }),
      meta: { 
          requiresAuth: true,
      }
    }, 
];


export default routes;