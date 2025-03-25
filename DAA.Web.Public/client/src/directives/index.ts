import { App, Directive } from 'vue'
import { Tooltip, Dropdown } from 'bootstrap';

export const addDirectives = (app: App): void => {
    app.directive('tooltip', tooltipDirective);
    app.directive('dropdown', dopdownDirective);
    app.directive('loading', loadingDirective);
}

const tooltipDirective = {
    beforeMount(el, binding) {
        const options = {
            title: binding.value,
            placement: binding.arg || 'top',
            trigger: 'hover',
            html: true
        } as Partial<Tooltip.Options>;

        new Tooltip(el, options)
    },
    beforeUnmount(el) {
        const tooltip = Tooltip.getInstance(el);
        if (tooltip !== null) {
            tooltip.dispose();
        }
    }
} as Directive;

const dopdownDirective = {
    beforeMount(el) {
        new Dropdown(el)
    }
} as Directive;

const loadingDirective = {
    beforeMount(el: HTMLElement, binding) {
        el.classList.add(...['spinner-border', 'text-primary', 'm-auto', 'loadingg']);
        if (binding.arg) {
            el.style.width = binding.arg + 'px';
            el.style.height = binding.arg + 'px';
        }
    }
} as Directive;