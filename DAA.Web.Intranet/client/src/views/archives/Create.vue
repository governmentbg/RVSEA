<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('archives.create') }}</v-card-title>

        <Form @submit="submitArchiveData">
            <v-container>
                <v-row>
                    <v-col class="col-12 mb-10">
                        <label for="fldExisingArchive">{{ t('archives.select') }}</label>
                        <AsyncDropdown
                            name="fldExisingArchive"
                            :label="t('archives.select')"
                            labelProp="name"
                            valueProp="externalIdentifier"
                            :itemsFunction="getExternalData"
                            @change="changeExternalData"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12">
                        <text-field
                            name="fldName"
                            :label="t('archives.columns.name')"
                            v-model="archiveData.name"
                            validation="required"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12">
                        <text-field
                            name="fldCode"
                            :label="t('archives.columns.code')"
                            v-model="archiveData.code"
                            validation="required|numeric"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12">
                        <text-field
                            name="fldSortOrder"
                            :label="t('archives.columns.sortOrder')"
                            v-model="archiveData.sortOrder"
                            validation="numeric"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12">
                        <Switch
                            :label="t('archives.columns.hasExternalSource')"
                            v-model="archiveData.hasExternalSource"
                            :large="false"
                            :showLabel="true"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col class="col-12">
                        <text-field
                            name="fldExternalIdentifier"
                            :label="t('archives.columns.externalIdentifier')"
                            v-model="archiveData.externalIdentifier"
                            :validation="archiveData.hasExternalSource ? 'required|numeric' : 'numeric'"
                        />
                    </v-col>
                </v-row>
                <v-row>
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
                            {{t('common.cancelTooltip')}}
                            </v-tooltip>
                        </v-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, inject, Ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useRedirect } from '@/helpers/router.helper';
import { Message } from '@/models/notification';

import archiveService from '@/services/archive.service';
import { IArchive } from '@/interfaces/archive';
import { Archive } from '@/models/archive';

import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import AsyncDropdown from '@/components/dropdown/asyncDropdown.vue';
import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '../../models/responseResult';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
export default defineComponent({
    name: 'CreateArchive',
    components: {
        Form,
        TextField,
        Switch,
        AsyncDropdown,
        Breadcrumbs,
    },
    setup() {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;

        const router = useRouter();
        const goBack = () => {
            useRedirect(router, 'Archives');
        };

        const archiveData = ref<IArchive>(new Archive());

        const getExternalData = async (searchText: string) => {
            const result = await archiveService.getArchivesFromExternalSource(searchText);
            return result;
        };
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const changeExternalData = (option: any) => {
            console.log(option);
            if (option) {
                archiveData.value.name = option.name;
                archiveData.value.code = option.code;
                archiveData.value.sortOrder = option.sortOrder;
                archiveData.value.hasExternalSource = true;
                archiveData.value.externalIdentifier = option.externalIdentifier;
            }
        };

        const submitArchiveData = async () => {
            try {
                const result = await archiveService.createArchive(archiveData.value);
                if (result.status == 200) {
                    message.value = new Message({
                        text: t('common.successfullyCreated'),
                        display: true,
                        type: 'success',
                        timeout: 5000,
                    });
                    goBack();
                }
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
                title: t('navigation.left.archives'),
                disabled: false,
                to: { name: 'Archives' },
            },
            {
                title: t('archives.create'),
                disabled: true,
            },
        ];
        return {
            t,
            breadcrumbItems,
            archiveData,
            getExternalData,
            changeExternalData,
            submitArchiveData,
            goBack,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
