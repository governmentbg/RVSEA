import { RouteLocationRaw } from "vue-router";

export interface IHyperlinkInfo {
    title: string | undefined,
    to?: RouteLocationRaw,
    href?: string,
    description?: string,
    target?: string | undefined,
}