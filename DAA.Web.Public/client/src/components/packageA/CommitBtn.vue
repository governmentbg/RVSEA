<template>
    <ConfirmDialog
        :width="800"
        :disabled="disabled"
        :activatorButtonText="'Изпрати към държавен архив'"
        :confirmationText="'Последните запаметени промени ще бъдат изпратени към държавен архив. Потвърждавате ли изпращането?'"
        :confirmButtonText="$t('common.yes')"
        :cancelButtonText="$t('common.no')"
        @confirm="onSubmit"
        @cancel="onCancel"
    ></ConfirmDialog>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import packagesService from '@/services/packages.service';

export default defineComponent({
    name: 'CommitPackageBtn',
    components: {
        ConfirmDialog,
    },
    props: {
        applicationId: {
            type: Number,
            required: true,
        },
        disabled: {
            type: Boolean,
            default: false,
        },
    },
    emits: ['cancel', 'committing', 'commited', 'error'],
    setup(props, { emit }) {
        const onSubmit = () => {
            emit('committing');
            packagesService
                .submit(props.applicationId)
                .then(() => {
                    emit('commited');
                })
                .catch((err) => emit('error', err));
        };

        const onCancel = () => {
            emit('cancel');
        };

        return {
            onCancel,
            onSubmit,
        };
    },
});
</script>

<style scoped></style>
