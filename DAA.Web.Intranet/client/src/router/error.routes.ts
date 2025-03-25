import { RouteRecordRaw } from 'vue-router'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/accessdenied',
    name: 'AccessDenied',
    component: () => import(/* webpackChunkName: "auth" */ '@/views/error/AccessDenied.vue')
  },
  {
    path: '/notAuthorized',
    name: 'NotAuthorized',
    component: () => import(/* webpackChunkName: "auth" */ '@/views/error/NotAuthorized.vue')
  },
]

export default routes;