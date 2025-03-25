import { RouteRecordRaw } from 'vue-router'
const prefix = '/edocscollection';
const routes: Array<RouteRecordRaw> = [
	{
		path: `${prefix}/`,
		name: 'ЕDocsCollectingProcesses',
		component: () => import(/* webpackChunkName: "auth" */ '@/views/eDocsCollection/Index.vue')
	},
	{
		path: `${prefix}/applications`,
		name: 'ЕDocsCollectingApplications',
		component: () => import(/* webpackChunkName: "auth" */ '@/views/eDocsCollection/Applications.vue'),
	},
	{
		path: `${prefix}/applications/display/:id`,
		name: 'ApplicationDisplay',
		component: () => import(/* webpackChunkName: "auth" */ '@/views/eDocsCollection/ApplicationDisplay.vue'),
		props: (route) => ({
			id: parseInt(route.params.id as string),
		})
	},
]

export default routes;