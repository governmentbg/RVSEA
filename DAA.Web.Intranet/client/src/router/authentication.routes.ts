import { RouteRecordRaw } from 'vue-router'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/login',
    name: 'Login',
    component: () => import(/* webpackChunkName: "auth" */ '@/views/authentication/Login.vue')
  },
  {
    path: '/logout',
    name: 'Logout',
    component: () => import(/* webpackChunkName: "auth" */ '@/views/authentication/Logout.vue')
  },
  {
    path: '/registerReader',
    name: 'RegisterReader',
    meta: { 
      requiresAuth: true,
    },
    component: () => import(/* webpackChunkName: "register" */ '../views/users/external/readers/Create.vue')
  },
  // {
  //   path: '/registerReader/complete',
  //   name: 'CompleteRegistration',
  //   component: () => import(/* webpackChunkName: "register" */ '../views/authentication/CompleteRegistration.vue')
  // },
]

export default routes;