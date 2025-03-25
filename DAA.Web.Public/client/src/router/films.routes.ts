import { RouteRecordRaw } from 'vue-router';
import { validate as isValidGuid } from 'uuid';
import { parseBoolean } from '@/helpers/boolean.helper';

const root = 'films';

const routes: Array<RouteRecordRaw> = [
    {
        path: `/${root}/display/:id?`,
        name: 'Films',
        component: () => import(/* webpackChunkName: "films" */ '../views/films/Display.vue'),
        props: (route) => ({
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)),
            externalIdentifier: route.query.externalIdentifier
                ? Number.parseInt(route.query.externalIdentifier.toString())
                : undefined,
        }),
    },
    {
        path: `/${root}/display/:id?`,
        name: 'DisplayFilm',
        component: () => import(/* webpackChunkName: "films" */ '../views/films/Display.vue'),
        props: (route) => ({
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)),
            externalIdentifier: route.query.externalIdentifier
                ? Number.parseInt(route.query.externalIdentifier.toString())
                : undefined,
        }),
    },
    {
        path: `/${root}/:filmId/cards/display/:id?`,
        name: 'DisplayFilmCard',
        component: () => import(/* webpackChunkName: "cards" */ '../views/films/cards/Display.vue'),
        props: (route) => ({
            filmId: isValidGuid(route.params.filmId.toString()) ? route.params.filmId : undefined,
            id: isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
        }),
    },
    {
        path: `/${root}/reader/index/:userId?`,
        name: 'FilmsForReader',
        component: () => import(/* webpackChunkName: "films" */ '../views/filmRviews/Index.vue'),
        props: (route) => ({
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)),
            externalIdentifier: route.query.externalIdentifier
                ? Number.parseInt(route.query.externalIdentifier.toString())
                : undefined,
        }),
        meta: { requiresAuth: true },
    },
    {
        path: `/${root}/reader/display/:id?`,
        name: 'DisplayFilmFull',
        component: () => import(/* webpackChunkName: "films" */ '../views/filmRviews/Display.vue'),
        props: (route) => ({
            id: route.params.id && isValidGuid(route.params.id.toString()) ? route.params.id : undefined,
            hasExternalSource: parseBoolean(String(route.query.hasExternalSource)),
            externalIdentifier: route.query.externalIdentifier
                ? Number.parseInt(route.query.externalIdentifier.toString())
                : undefined,
        }),
        meta: { requiresAuth: true },
    },
];

export default routes;
