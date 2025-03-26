<template>
    <div v-for="(hlink, index) in hlinks" :key="index">
        <hyperlink
            :title="hlink.title"
            :href="hlink.href"
            :to="hlink.to"
            :target="hlink.target"
            :description="hlink.description"
        />
    </div>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue';
import Hyperlink from '@/components/hyperlink/hyperlink.vue';
// templateArgs: {
// 	prop: String,
// 	formatter: Function
// },
export default defineComponent({
    name: 'HyperlinkTemplate',
    components: {
        Hyperlink,
    },
    props: {
        templateArgs: {
            type: Object,
            required: true,
        },
    },
    setup(props) {
        const hlinks = computed(() => {
            if (props.templateArgs.formatter) {
                return props.templateArgs.prop
                    ? props.templateArgs.formatter(props.templateArgs[props.templateArgs.prop])
                    : props.templateArgs.formatter(props.templateArgs);
            }
            return props.templateArgs.prop ? props.templateArgs[props.templateArgs.prop] : props.templateArgs;
        });

        return {
            hlinks,
        };
    },
});
</script>

<style></style>
