import { RouteRecordRaw } from 'vue-router'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/login',
    name: 'Login',
    component: () => import(/* webpackChunkName: "login" */ '../views/authentication/Login.vue')
  },
  {
    path: '/login/username',
    name: 'LoginUsername',
    component: () => import(/* webpackChunkName: "login" */ '../views/authentication/LoginUsername.vue')
  },
  {
    path: '/login/result',
    name: 'CertificateLoginResult',
    props: route => ({ 
      auth: route.query.auth?.toString(), 
      error: route.query.error?.toString(), 
      message: route.query.message?.toString(), 
      requireEmail: route.query.requireEmail?.toString(), 
      isEAuth: route.query.isEAuth?.toString(), 
      certPersonIdentifier: route.query.certPersonIdentifier?.toString(), 
      certNames: route.query.certNames?.toString(), 
    }),
    component: () => import('../views/authentication/CertificateLoginResult.vue')
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import(/* webpackChunkName: "register" */ '../views/authentication/Register.vue')
  },
  {
    path: '/register/complete',
    name: 'CompleteRegistration',
    component: () => import(/* webpackChunkName: "register" */ '../views/authentication/CompleteRegistration.vue')
  },
  {
    path: '/confirm',
    name: 'ConfirmAccount',
    props: route => ({ userId: route.query.uid?.toString(), confirmationToken: route.query.code?.toString() }),
    component: () => import(/* webpackChunkName: "confirm" */ '../views/authentication/AccountConfirmation.vue')
  },
  {
    path: '/resetPassword',
    name: 'ResetPassword',
    component: () => import(/* webpackChunkName: "changePassword" */ '../views/authentication/ResetPassword.vue')
  },
  {
    path: '/setPassword',
    name: 'SetPassword',
    props: route => ({ userId: route.query.uid?.toString(), passwordToken: route.query.code?.toString() }),
    component: () => import(/* webpackChunkName: "changePassword" */ '../views/authentication/SetPassword.vue')
  },
  {
    path: '/changePassword',
    name: 'ChangePassword',
    props: route => ({ userId: route.query.uid?.toString(), passwordToken: route.query.code?.toString() }),
    component: () => import(/* webpackChunkName: "changePassword" */ '../views/authentication/ChangePassword.vue')
  },
]

export default routes;