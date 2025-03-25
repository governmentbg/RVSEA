import { RouteRecordRaw } from 'vue-router'
import { validate as isValidGuid } from 'uuid';
import { parseBoolean } from '@/helpers/boolean.helper';
import { useRedirectWithIdAndExternalIdentifierAndExternalSource } from '@/helpers/router.helper';

const root = 'films';

const routes: Array<RouteRecordRaw> = [
    {
        path: `/${root}`,
        name: 'Films',
        component: () => import(/* webpackChunkName: "films" */ '../views/films/Index.vue'),
        meta: {
            requiresAuth: true,
        }
    },
    {
        path: `/${root}/external`,
        name: 'FilmsExternal',
        component: () => import(/* webpackChunkName: "films" */ '../views/films/Index.vue'),
        props: route => ({ 
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)), 
            externalIdentifier: route.query.externalIdentifier ? Number.parseInt(route.query.externalIdentifier.toString()) : undefined
        }),
        meta: {
            requiresAuth: true,
        }
    },
    {
        path: `/${root}/display/:id?`,
        name: 'DisplayFilm',
        component: () => import(/* webpackChunkName: "films" */ '../views/films/Display.vue'),
        props: route => ({ 
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)), 
            externalIdentifier: route.query.externalIdentifier ? Number.parseInt(route.query.externalIdentifier.toString()) : undefined
        }),
        meta: {
            requiresAuth: true,
        }
    },
    {
        path: `/${root}/create`,
        name: 'CreateFilm',
        component: () => import(/* webpackChunkName: "films" */ '../views/films/Create.vue'),
        meta: {
            requiresAuth: true,
        },
    },
    {
        path: `/${root}/edit/:id`,
        name: 'EditFilm',
        component: () => import(/* webpackChunkName: "films" */ '../views/films/Edit.vue'),
        props: route => ({ 
            id: isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
        }),
        meta: {
            requiresAuth: true,
        }
    },

// -------------------------------------------------------
// FilmCards
// -------------------------------------------------------
    {
        path: `/${root}/:filmId/cards/create/`,
        name: 'CreateFilmCard',
        component: () => import(/* webpackChunkName: "cards" */ '../views/films/cards/Create.vue'),
        props: route => ({
            filmId: isValidGuid(route.params.filmId.toString()) ? route.params.filmId : undefined,
        }),
        meta: {
            requiresAuth: true,
        }
    },
    {
        path: `/${root}/:filmId/cards/edit/:id`,
        name: 'EditFilmCard',
        component: () => import(/* webpackChunkName: "cards" */ '../views/films/cards/Edit.vue'),
        props: route => ({
            filmId: isValidGuid(route.params.filmId.toString()) ? route.params.filmId : undefined,
            id: isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
        }),
        meta: {
            requiresAuth: true,
        }
    },
    {
        path: `/${root}/:filmId/cards/display/:id?`,
        name: 'DisplayFilmCard',
        component: () => import(/* webpackChunkName: "cards" */ '../views/films/cards/Display.vue'),
        props: route => ({
            filmId: parseBoolean(String(route.query.hasExternalSource)) 
            ? route.params.filmId
                ? route.params.filmId.toString()
                : undefined
            : isValidGuid(route.params.filmId.toString()) 
                ? route.params.filmId 
                : undefined,
            id: parseBoolean(String(route.query.hasExternalSource)) 
            ? route.params.id
                ? route.params.id.toString()
                : useRedirectWithIdAndExternalIdentifierAndExternalSource
            : isValidGuid(route.params.id.toString()) 
                ? route.params.id 
                : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)), 
        }),
        meta: {
            requiresAuth: true,
        }
    },
    {
        path: `/${root}/cards/print/:cardId`,
        name: 'PrintFilmCard',
        component: () => import(/* webpackChunkName: "cards" */ '../views/films/cards/Print.vue'),
        props: route => ({
            cardId: route.params.cardId
        }),
        meta: {
            requiresAuth: true,
        }
    },


// -------------------------------------------------------
// FilmDocuments
// -------------------------------------------------------
    {
        path: `/${root}/:filmId/:packageId/:packageType/create/`,
        name: 'CreateFilmDocument',
        component: () => import(/* webpackChunkName: "packageDocuments" */ '../views/films/documents/Create.vue'),
        props: route => ({
            filmId: isValidGuid(route.params.filmId.toString()) ? route.params.filmId : undefined,
            packageId: Number.parseInt(route.params.packageId.toString()),
            packageType: route.params.packageType,
        }),
        meta: {
            requiresAuth: true,
        }
    },
    {
        path: `/${root}/:filmId/document/:packageType/display/:id`,
        name: 'DisplayFilmDocument',
        component: () => import(/* webpackChunkName: "packageDocuments" */ '../views/films/documents/Display.vue'),
        props: route => ({
            filmId: isValidGuid(route.params.filmId.toString()) ? route.params.filmId : undefined,
            packageType: route.params.packageType,
            id: Number.parseInt(route.params.id.toString()),
        }),
        meta: {
            requiresAuth: true,
        }
    },
    {
        path: `/${root}/:filmId/document/:packageType/edit/:id`,
        name: 'EditFilmDocument',
        component: () => import(/* webpackChunkName: "packageDocuments" */ '../views/films/documents/Edit.vue'),
        props: route => ({
            filmId: isValidGuid(route.params.filmId.toString()) ? route.params.filmId : undefined,
            packageType: route.params.packageType,
            id: Number.parseInt(route.params.id.toString()),
        }),
        meta: {
            requiresAuth: true,
        }
    },

// -------------------------------------------------------
// FilmReviews
// -------------------------------------------------------
    {
        path: `/${root}/filmReviews`,
        name: 'DisplayFilmReviews',
        component: () => import(/* webpackChunkName: "films" */ '../views/films/filmReviews/Index.vue'),
        props: route => ({ 
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)), 
            externalIdentifier: route.query.externalIdentifier ? Number.parseInt(route.query.externalIdentifier.toString()) : undefined
        }),
        meta: {
            requiresAuth: true,
        }
    },
    {
        path: `/${root}/filmReviews/create`,
        name: 'CreateFilmReview',
        component: () => import(/* webpackChunkName: "films" */ '../views/films/filmReviews/Create.vue'),
        props: route => ({ 
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)), 
            externalIdentifier: route.query.externalIdentifier ? Number.parseInt(route.query.externalIdentifier.toString()) : undefined
        }),
        meta: {
            requiresAuth: true,
        }
    },
];


export default routes;