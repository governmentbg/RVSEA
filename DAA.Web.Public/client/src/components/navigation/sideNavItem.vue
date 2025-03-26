<template>
    <v-list-item 
        v-if="visible"
        :to="to"
        @click="clickHandler"
        :value="value"
        :title="title"
        :prepend-icon="icon"
    >
    </v-list-item>
</template>
<script lang="ts">
import { defineComponent, PropType } from 'vue';
import { RouteLocationRaw } from 'vue-router';

export default defineComponent({
    name: 'SideNavigationItem',
    props: {
        title: {
            type: String
        },
        icon: {
            type: String,
        },
        to: {
            type: Object as PropType<RouteLocationRaw>,
            default: undefined,
        },
        value: {
            type: String,
        },
        clickHandler: {
            type: Function,
        },
        visible: {
            type: Boolean,
            default: true,
        },
    },
})
</script>
