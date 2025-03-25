<template>
    <v-list-group 
        v-if="visible"
    >
        <template v-slot:activator="{ props }">
            <v-list-item 
                v-bind="props" 
                :prepend-icon="icon" 
                :title="title" 
                :value="title"
            ></v-list-item>
        </template>
        <slot name="items"></slot>
    </v-list-group>

</template>
<script lang="ts">
import { defineComponent } from 'vue'

export default defineComponent({
    name: 'SideNavigationItemGroup',
    props: {
        title: {
            type: String,
        },
        icon: {
            type: String,
        },
        visible: {
            type: Boolean,
            default: true,
        }
    },
})
</script>
