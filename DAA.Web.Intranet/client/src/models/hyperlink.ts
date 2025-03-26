import { IHyperlinkInfo } from '@/interfaces/hyperlink';
import { RouteLocationRaw } from 'vue-router';

export class HyperlinkInfo implements IHyperlinkInfo {
    constructor(obj: HyperlinkInfo | undefined) {
        if (obj) {
            Object.assign(this, obj);
        }
    }

    title: string | undefined;
    to?: RouteLocationRaw;
    href?: string;
    description?: string;
    target?: string;
}
