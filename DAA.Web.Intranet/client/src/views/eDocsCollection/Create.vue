<template>
    <div class="pb-3">
        <h3 class="text-center">
            {{ $t(`eDocsCollection.create.${type}Title`) }}
        </h3>
    </div>
    <v-row>
        <v-col cols="12">
            <CreateInventory
                @created="inventoryCreated"
                :internal="internal"
                :processed="processed"
                @cancel="onCancel"
            ></CreateInventory>
        </v-col>
    </v-row>
</template>

<script lang="ts">
import { defineComponent, ref } from 'vue';
import CreateInventory from '@/components/inventory/create.vue';

export default defineComponent({
    components: {
        CreateInventory,
    },
    props: {
        type: {
            type: String,
            required: true,
        },
    },
    setup(props) {
        const internal = ref(false);
        const processed = ref(false);

        switch (props.type) {
            case 'Processed':
                internal.value = false;
                processed.value = true;
                break;
            case 'NotProcessedInternal':
                internal.value = true;
                processed.value = false;
                break;
            case 'NotProcessedExternal':
                internal.value = false;
                processed.value = false;
                break;
        }

        return {
            internal,
            processed,
        };
    },
    methods: {
        inventoryCreated() {
            //TODO Message
            this.$router.back();
        },
        onCancel() {
            this.$router.back();
        },
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
</style>
