<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('nomenclature.edit') }}</v-card-title>

        <Form @submit="submitNomenclatureData">
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

import { Nomenclature } from '@/models/nomenclature';
import nomenclatureService from '@/services/nomenclature.service';
import { Message } from '@/models/notification';
import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import { IMessage } from '../../interfaces/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
export default defineComponent({
    name: 'EditNomenclature',
    components: {
        Form,
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
        const goBack = () => {
            useRedirect(router, 'Nomenclatures');
        };

        const nomenclatureData = ref(new Nomenclature());
        const getNomenclatureData = async () => {
            try {
                nomenclatureData.value = await nomenclatureService.getNomenclature(props.nomId);
            } catch (error) {
                message.value.text = `${error.response.data}`;
            }
        };

        const submitNomenclatureData = async () => {
            try {
                const result = await nomenclatureService.updateNomenclature(nomenclatureData.value);
                if (result.status == 200) {
                    goBack();
                } else {
                    message.value = new Message({
                        text: result.response.data.message,
                        display: true,
                    });
                }
            } catch (error) {
                console.log(error);
                message.value = new Message({
                    text: error.response.data.message,
                    display: true,
                });
            }
        };

        onMounted(getNomenclatureData);
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
                title: t('nomenclature.edit'),
                disabled: true,
            },
        ];
        return {
            t,
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
