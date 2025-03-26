<template>
    <v-list-item>

    </v-list-item>
</template>
<script lang="ts">
import { ISearchResult } from '@/interfaces/searchResult'
import { defineComponent, PropType } from 'vue'

export default defineComponent({
    name: "SearchResultItem",
    props: {
        item: {
            type : Object as PropType<ISearchResult>,
            required: true,
        }
    },
    setup() {
        
    },
})
</script>
