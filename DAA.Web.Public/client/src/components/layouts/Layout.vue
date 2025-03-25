<template>
    <component :is="layout">
        <slot />
    </component>
</template>
<script lang="ts">
import { computed, defineComponent } from 'vue'
import BaseLayout from '@/layouts/BaseLayout.vue';
import RRRLayout from '@/layouts/RRRLayout.vue';
import authorization from '@/helpers/authorization.helper';
import { ProfileType } from '@/enums/profile';


export default defineComponent({
    name: "Layout",
    setup() {
        const layout = computed(() => authorization.isProfileType(ProfileType.ReaderInReadingRoom) ? RRRLayout : BaseLayout);

        // const appLayout = markRaw(BaseLayout);
        // watch(
        //     () => route.meta,
        //     async meta => {
        //         try {
        //             const component = await import(`@/layouts/${meta.layout}.vue`);
        //             appLayout.value = component?.default || BaseLayout;
        //         } catch (error) {
        //             appLayout.value = BaseLayout;
        //             console.log(error);
        //         }
        //     },
        //     { immediate: true }
        // );

        return {
            layout,
        }
    },
})
</script>
