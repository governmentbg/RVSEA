<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('nomenclature.display') }}</v-card-title>
        <v-container>
            <v-row>
                <v-col class="col-12">
                    <text-field
                        name="fldCode"
                        :label="t('nomenclature.columns.code')"
                        v-model="nomenclatureData.code"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="col-12">
                    <text-field
                        name="fldText"
                        :label="t('nomenclature.columns.title')"
                        v-model="nomenclatureData.text"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="col-12">
                    <text-area-field
                        name="fldDescription"
                        :label="t('nomenclature.columns.description')"
                        v-model="nomenclatureData.description"
                        :readOnly="true"
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
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row class="mt-3">
                <v-col class="d-flex justify-content-center">
                    <v-btn class="mr-4" @click="goEdit"
                        >{{ t('common.edit') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('nomenclature.buttons.editTooltip') }}
                        </v-tooltip>
                    </v-btn>
                    <v-divider vertical></v-divider>
                    <v-btn class="clear bg-secondary" @click="goBack"
                        >{{ t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('nomenclature.buttons.backTooltip') }}
                        </v-tooltip>
                    </v-btn>
                </v-col>
            </v-row>
        </v-container>
    </v-card>

    <NomenclatureValues :parentId="nomId" :showComponentTitle="false" />
</template>
<script lang="ts">
import { defineComponent, onMounted, ref, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { Message } from '@/models/notification';

import { INomenclature } from '@/interfaces/nomenclature';
import nomenclatureService from '@/services/nomenclature.service';
import { Nomenclature } from '@/models/nomenclature';

import NomenclatureValues from '@/views/nomenclatures/values/Index.vue';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '../../models/responseResult';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
export default defineComponent({
    name: 'DisplayNomenclature',
    components: {
        NomenclatureValues,
        TextField,
        TextAreaField,
        Switch,
        Breadcrumbs,
    },
    props: {
        nomId: { type: Number, required: true },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const router = useRouter();
        const goEdit = () => {
            useRedirectWithId(router, 'EditNomenclature', props.nomId);
        };
        const goBack = () => {
            useRedirect(router, 'Nomenclatures');
        };

        const nomenclatureData = ref<INomenclature>(new Nomenclature());
        const getNomenclatureData = async () => {
            try {
                nomenclatureData.value = await nomenclatureService.getNomenclature(props.nomId);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        onMounted(async () => {
            await getNomenclatureData();
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
                title: t('nomenclature.nomenclature'),
                disabled: true,
            },
        ];

        return {
            t,
            breadcrumbItems,
            nomenclatureData,
            goEdit,
            goBack,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
