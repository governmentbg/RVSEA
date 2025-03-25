<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('nomenclature.values.display') }}</v-card-title>

        <v-container>
            <v-row>
                <v-col class="col-12">
                    <text-field
                        name="fldParent"
                        :label="t('nomenclature.columns.parent')"
                        v-model="nomenclatureValueData.parentText"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="col-12">
                    <text-field
                        name="fldCode"
                        :label="t('nomenclature.columns.code')"
                        v-model="nomenclatureValueData.code"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="col-12">
                    <text-field
                        name="fldCode"
                        :label="t('nomenclature.columns.externalIdentifier')"
                        v-model="nomenclatureValueData.externalIdentifier"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="col-12">
                    <text-field
                        name="fldText"
                        :label="t('nomenclature.columns.title')"
                        v-model="nomenclatureValueData.text"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="col-12">
                    <text-field
                        name="fldSortOrder"
                        :label="t('nomenclature.columns.sortOrder')"
                        v-model="nomenclatureValueData.sortOrder"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="col-12">
                    <text-area-field
                        name="fldDescription"
                        :label="t('nomenclature.columns.description')"
                        v-model="nomenclatureValueData.description"
                        :readOnly="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="col-12">
                    <Switch
                        :label="t('nomenclature.columns.inactive')"
                        v-model="nomenclatureValueData.inactive"
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
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { Message } from '@/models/notification';

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { NomenclatureValue } from '@/models/nomenclature';
import nomenclatureService from '@/services/nomenclature.service';

import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
export default defineComponent({
    name: 'CreateNomenclatureValue',
    components: {
        TextField,
        TextAreaField,
        Switch,
        Breadcrumbs,
    },
    props: {
        parentId: { type: Number, required: true },
        valueId: { type: Number, required: true },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const router = useRouter();
        const goEdit = () => {
            useRedirect(router, 'EditNomenclatureValue', {
                parentId: props.parentId,
                id: props.valueId,
            });
        };
        const goBack = () => {
            if (props.parentId) {
                useRedirectWithId(router, 'DisplayNomenclature', props.parentId);
            } else {
                useRedirect(router, 'Nomenclatures');
            }
        };

        const nomenclatureValueData = ref(new NomenclatureValue());
        const getNomenclatureValueData = async () => {
            try {
                nomenclatureValueData.value = await nomenclatureService.getNomenclatureValue(
                    props.valueId,
                    props.parentId
                );
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };
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
                disabled: false,
                to: { name: 'DisplayNomenclature', params: { id: props.parentId } },
            },
            {
                title: t('nomenclature.values.value'),
                disabled: true,
            },
        ];
        onMounted(async () => {
            await getNomenclatureValueData();
        });

        return {
            t,
            nomenclatureValueData,
            breadcrumbItems,
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
