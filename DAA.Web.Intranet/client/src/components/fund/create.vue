<template>
    <v-card-title class="v-card-title-uppercase">{{ t('funds.create') }}</v-card-title>
    <Form @submit="submitFundData" @invalid-submit="showHintMessageForRequiredFields">
        <submit-btn id="sticky-button" type="submit" class="me-3">{{ t('common.save') }}</submit-btn>
        <cancel-btn id="sticky-button2" @click="onCancel">{{ t('common.cancel') }}</cancel-btn>
        <fund-create-form
            v-model="fundData"
            :disableDescLevel="fundDescLevel !== null && fundDescLevel !== undefined"
            :disableArchive="!isNaN(archiveId)"
            :type="type"
            @chronologicalScopeLabelText="getChronologicalScopeLabelText"
        ></fund-create-form>
        <v-row class="mt-3 mb-3">
            <v-col class="d-flex gap-2 justify-content-center">
                <submit-btn type="submit"
                    >{{ t('common.save') }}
                    <v-tooltip activator="parent" location="bottom">
                        {{ t('common.saveTooltip') }}
                    </v-tooltip>
                </submit-btn>
                <cancel-btn @click="onCancel"
                    >{{ t('common.cancel') }}
                    <v-tooltip activator="parent" location="bottom">
                        {{ t('funds.buttons.cancelTooltip') }}
                    </v-tooltip>
                </cancel-btn>
            </v-col>
        </v-row>
    </Form>
</template>

<script lang="ts">
import { defineComponent, ref, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { Message } from '@/models/notification';

import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '../../models/responseResult';
import { IFundDraft } from '@/interfaces/fund';
import { FundDraft } from '@/models/fund';
import fundService from '@/services/fund.service';

import { Form } from 'vee-validate';
import FundCreateForm from '@/components/fund/createForm.vue';

export default defineComponent({
    name: 'CreateFund',
    components: {
        Form,
        FundCreateForm,
    },
    props: {
        fundDescLevel: {
            type: String,
        },
        archiveId: {
            type: Number,
        },
        type: {
            type: String,
        },
    },
    emits: ['created', 'cancel'],
    setup(props, { emit }) {
        const { t } = useI18n();
        const chronologicalScopeLabelText = ref('');
        const message = inject('notificationMessage') as Ref<IMessage>;
        const panel = ref(['general', 'additional', 'availability', 'chronologicalScope', 'storage']);
        const fundData = ref<IFundDraft>(new FundDraft());
        const submitFundData = async () => {
            try {
                if (chronologicalScopeLabelText.value) {
                    showHintMessageRequirements();
                    return;
                }
                fundData.value.statusCode = '1';

                const result = await fundService.createFund(fundData.value, true);
                if (result.status == 200) {
                    message.value = new Message({
                        text: t('common.successfullyCreated'),
                        display: true,
                        type: 'success',
                        timeout: 5000,
                    });
                    emit('created', result.data.data);
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };
        const showHintMessageRequirements = () => {
            message.value = new Message({
                text: t('common.requirements'),
                display: true,
            });
        };
        const showHintMessageForRequiredFields = () => {
            message.value = new Message({
                text: t('common.requiredFields'),
                display: true,
            });
        };
        const onCancel = () => {
            emit('cancel');
        };

        if (props.fundDescLevel) {
            fundData.value.descriptionLevelCode = props.fundDescLevel.toString();
        }

        if (props.archiveId) {
            fundData.value.archiveId = parseInt(props.archiveId.toString());
        }
        const getChronologicalScopeLabelText = (val: string) => {
            chronologicalScopeLabelText.value = val;
        };

        return {
            t,
            panel,
            fundData,
            onCancel,
            showHintMessageForRequiredFields,
            getChronologicalScopeLabelText,
            submitFundData,
        };
    },
});
</script>

<style lang="scss" scoped>
@use '@/assets/styles/common.scss' as *;
@import '@/assets/styles/display-create-edit.scss';

#sticky-button,
#sticky-button2 {
    top: 130px;
    right: 0px;
    margin: 0px 50px !important;
    position: fixed;
}

#sticky-button2 {
    top: 200px;
}

// button {
//     @include button();
// }

#to-fixed,
#to-fixed2 {
    position: fixed;
    right: 160px;
}

#to-fixed {
    top: 100px;
}
</style>
