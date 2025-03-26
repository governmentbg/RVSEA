import { RouteRecordRaw } from 'vue-router'

const routes: Array<RouteRecordRaw> = [
	{
		path: '/applications',
		name: 'Applications',
		component: () => import(/* webpackChunkName: "auth" */ '@/views/applications/Index.vue'),
		meta: { requiresAuth: true }
	},
	{
		path: '/applications/create',
		name: 'ApplicationsCreate',
		component: () => import(/* webpackChunkName: "auth" */ '@/views/applications/Create.vue'),
		meta: { requiresAuth: true }
	},
	{
		path: '/applications/display/:id',
		name: 'ApplicationsDisplay',
		component: () => import(/* webpackChunkName: "auth" */ '@/views/applications/Display.vue'),
		meta: { requiresAuth: true },
		props: route => ({
			id: parseInt(route.params.id as string),
		}),
	},
	{
		path: '/applications/packages/raw/:applicationId',
		name: 'PackagesCreateRaw',
		component: () => import(/* webpackChunkName: "auth" */ '@/views/applications/PackagesCreateRaw.vue'),
		meta: { requiresAuth: true },
		props: route => ({
			applicationId: parseInt(route.params.applicationId as string),
		}),
	},
	{
		path: '/applications/packages/assembled/:applicationId',
		name: 'PackagesCreate',
		component: () => import(/* webpackChunkName: "auth" */ '@/views/applications/PackagesCreate.vue'),
		meta: { requiresAuth: true },
		props: route => ({
			applicationId: parseInt(route.params.applicationId as string),
		}),
	},
	{
		path: '/applications/modify-packages/assembled/:applicationId',
		name: 'PackagesModify',
		component: () => import(/* webpackChunkName: "auth" */ '@/views/applications/PackagesModify.vue'),
		meta: { requiresAuth: true },
		props: route => ({
			applicationId: parseInt(route.params.applicationId as string),
		}),
	},
	{
		path: '/applications/modify-packages/raw/:applicationId',
		name: 'PackagesModifyRaw',
		component: () => import(/* webpackChunkName: "auth" */ '@/views/applications/PackagesModifyRaw.vue'),
		meta: { requiresAuth: true },
		props: route => ({
			applicationId: parseInt(route.params.applicationId as string),
		}),
	},
	{
		path: '/applications/packages/signed/:applicationId',
		name: 'UploadSignedDocuments',
		component: () => import(/* webpackChunkName: "auth" */ '@/views/applications/SignedPackageDocuments.vue'),
		meta: { requiresAuth: true },
		props: route => ({
			applicationId: parseInt(route.params.applicationId as string),
		}),
	},
	{
		path: '/applications/packages/:packageType/:packageId/document/',
		name: 'DocumentCreate',
		component: () => import(/* webpackChunkName: "auth" */ '@/views/applications/DocumentCreate.vue'),
		meta: { requiresAuth: true },
		props: route => ({
            filmId:  route.params.filmId || undefined,
            packageId: Number.parseInt(route.params.packageId.toString()),
            packageType: route.params.packageType,
        })
	},
]

export default routes;