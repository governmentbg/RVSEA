<template>
    <v-row justify="center">
        <v-dialog v-model="dialog" persistent>
            <div class="p-3">
                <CreateFundView
                    @cancel="dialog = false"
                    @created="onCreated"
                    :fundDescLevel="fundDescLevel"
                    :archiveId="archiveId"
                ></CreateFundView>
            </div>
        </v-dialog>
    </v-row>
</template>

<script lang="ts">
import { defineComponent, ref } from 'vue';
import CreateFundView from '@/components/fund/create.vue';

export default defineComponent({
    components: {
        CreateFundView,
    },
    props: {
        show: {
            type: Boolean,
            required: true,
        },
        fundDescLevel: {
            type: String,
        },
        archiveId: {
            type: Number,
        },
    },
    emits: ['created', 'update:show'],
    setup(props, { emit }) {
        const dialog = ref(false);
        const onCreated = (data: unknown) => {
            emit('created', data);
        };

        return { dialog, onCreated };
    },

    watch: {
        show: function (val: boolean) {
            this.dialog = val;
        },
        dialog: function (val: boolean) {
            this.$emit('update:show', val);
        },
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/dialog.scss';
</style>
