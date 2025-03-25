import { Router, RouteParamsRaw, LocationQueryRaw } from "vue-router";

// export const useRedirect = (router: Router, routeName: string, routeParams?: RouteParamsRaw) => {
//     if (routeParams) {
//         router.push({ name: routeName, params: routeParams });
//     } else {
//         router.push({name: routeName});
//     }
// }

export const useRedirect = (
    router: Router,
    routeName: string,
    routeParams?: RouteParamsRaw,
    routeQuery?: LocationQueryRaw
) => {
    // if (routeParams) {
    //     router.push({ name: routeName, params: routeParams });
    // } else {
    //     router.push({name: routeName});
    // }
    router.push({
        name: routeName,
        params: routeParams ?? {},
        query: routeQuery ?? {},
    });
};

export const useRedirectWithId = (router: Router, routeName: string, id: string|number) => {
    router.push({ name: routeName, params: { id: id } });
}
