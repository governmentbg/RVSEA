<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('nomenclature.create') }}</v-card-title>

        <Form @submit="submitNomenclatureData">
            <v-container>
                <v-row>
                    <v-col class="col-12">
                        <label class="required" for="fldType">{{ t('nomenclature.columns.code') }}</label>
                        <Dropdown
                            v-model="nomenclatureData.code"
                            name="fldType"
                            :label="t('nomenclature.columns.code')"
                            :items="nomenclatureCodes"
                            :required="true"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12">
                        <text-field
                            name="fldText"
                            :label="t('nomenclature.columns.title')"
                            v-model="nomenclatureData.text"
                            validation="required"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12">
                        <text-area-field
                            name="fldDescription"
                            :label="t('nomenclature.columns.description')"
                            v-model="nomenclatureData.description"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12">
                        <Switch
                            :label="t('nomenclature.columns.inactive')"
                            v-model="nomenclatureData.inactive"
                            :large="false"
                            :showLabel="true"
                        />
                    </v-col>
                </v-row>
                <v-row class="mt-3">
                    <v-col class="d-flex justify-content-center">
                        <v-btn class="mr-4" type="submit">{{ t('common.save') }}
                            <v-tooltip
                                activator="parent"
                                location="bottom"
                            >
                            {{t('common.saveTooltip')}}
                            </v-tooltip>
                        </v-btn>
                        <v-divider vertical></v-divider>
                        <v-btn class="clear bg-secondary" @click="goBack">{{ t('common.cancel') }}
                            <v-tooltip
                                activator="parent"
                                location="bottom"
                            >
                            {{t('nomenclature.buttons.cancelTooltip')}}
                            </v-tooltip>
                        </v-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
    </v-card>
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import { Message } from '@/models/notification';

import { IDropdownOption } from '@/interfaces/dropdown';
import { INomenclature } from '@/interfaces/nomenclature';
import { Nomenclature } from '@/models/nomenclature';
import nomenclatureService from '@/services/nomenclature.service';
import dropdownService from '@/services/dropdown.service';

import { Form } from 'vee-validate';
import Dropdown from '@/components/dropdown/dropdown.vue';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '../../models/responseResult';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
export default defineComponent({
    name: 'CreateNomenclature',
    components: {
        Form,
        Dropdown,
        TextField,
        TextAreaField,
        Switch,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const router = useRouter();
        const goBack = () => {
            useRedirect(router, 'Nomenclatures');
        };

        const nomenclatureCodes = ref<IDropdownOption[]>([]);
        const getNomenclatureCodes = async () => {
            nomenclatureCodes.value = await dropdownService.getNomenclatureCodes();
        };

        const nomenclatureData = ref<INomenclature>(new Nomenclature());
        const submitNomenclatureData = async () => {
            try {
                const result = await nomenclatureService.createNomenclature(nomenclatureData.value);
                if (result.status == 200) {
                    goBack();
                } else {
                    message.value = new Message({
                        text: result.response.data.message,
                        display: true,
                    });
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        onMounted(async () => {
            await getNomenclatureCodes();
        });
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.nomenclatures'),
                disabled: false,
                to: { name: 'Nomenclatures' },
            },
            {
                title: t('nomenclature.create'),
                disabled: true,
            },
        ];
        return {
            t,
            nomenclatureCodes,
            nomenclatureData,
            breadcrumbItems,
            goBack,
            submitNomenclatureData,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
