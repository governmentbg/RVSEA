import { RouteRecordRaw } from 'vue-router'
import { validate as isValidGuid } from 'uuid'
import { parseBoolean } from '@/helpers/boolean.helper'

const root = 'documents'

const routes: Array<RouteRecordRaw> = [
    {
        path: `/${root}/create`,
        name: 'CreateDocument',
        component: () => import(/* webpackChunkName: "documents" */ '@/views/documents/Create.vue'),
        props: (route) => ({
            archivalEntitySystemIdentifier:
                route.query.archivalEntitySystemIdentifier &&
                isValidGuid(String(route.query.archivalEntitySystemIdentifier))
                    ? route.query.archivalEntitySystemIdentifier
                    : undefined,
            archivalEntityHasExternalSource: parseBoolean(String(route.query.archivalEntityHasExternalSource)),
            archivalEntityExternalIdentifier: route.query.archivalEntityExternalIdentifier
                ? Number.parseInt(String(route.query.archivalEntityExternalIdentifier))
                : undefined,
            processType: route.query.processType ? Number.parseInt(route.query.processType.toString()) : undefined,
        }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}`,
        component: () => import(/* webpackChunkName: "documents" */ '@/views/documents/Index.vue'),
        name: 'Documents',
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/display/:id?`,
        name: 'DisplayDocument',
        component: () => import(/* webpackChunkName: "documents" */ '@/views/documents/Display.vue'),
        props: (route) => ({
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)),
            externalIdentifier: route.query.externalIdentifier
                ? Number.parseInt(route.query.externalIdentifier.toString())
                : undefined,
            //   processType: route.query.processType ? Number.parseInt(route.query.processType.toString()) : undefined,
        }),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/edit/:id?`,
        name: 'EditDocument',
        component: () => import(/* webpackChunkName: "documents" */ '@/views/documents/Edit.vue'),
        props: (route) => ({
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
        }),
        meta: {
            requiresAuth: true,
        },
    },
]

export default routes
