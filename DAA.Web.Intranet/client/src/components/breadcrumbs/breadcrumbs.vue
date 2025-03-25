<template>
    <div style="height: 0px; margin-bottom: 50px;">
        <v-breadcrumbs :items="items" divider="-"></v-breadcrumbs>
    </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
export default defineComponent({
    props: {
        items: {
            type: Array,
            required: true,
        },
    },

    setup() {
        return {};
    },
});
</script>
<style scoped></style>
