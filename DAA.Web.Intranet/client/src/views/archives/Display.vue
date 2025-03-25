<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('archives.display') }}</v-card-title>
        <v-container>
            <v-row>
                <v-col class="col-12">
                    <text-field
                        name="fldName"
                        :label="t('archives.columns.name')"
                        v-model="archiveData.name"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="col-12">
                    <text-field
                        name="fldCode"
                        :label="t('archives.columns.code')"
                        v-model="archiveData.code"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="col-12">
                    <text-field
                        name="fldSortOrder"
                        :label="t('archives.columns.sortOrder')"
                        v-model="archiveData.sortOrder"
                        :disabled="true"
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
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="col-12">
                    <text-field
                        name="fldExternalIdentifier"
                        :label="t('archives.columns.externalIdentifier')"
                        v-model="archiveData.externalIdentifier"
                        :disabled="true"
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="d-flex justify-content-center">
                    <v-btn class="mr-4" @click="goEdit">{{ t('common.edit') }}
                        <v-tooltip
                            activator="parent"
                            location="bottom"
                        >
                        {{t('archives.buttons.editTooltip')}}
                        </v-tooltip>
                    </v-btn>
                    <v-divider vertical></v-divider>
                    <v-btn class="clear bg-secondary" @click="goBack">{{ t('common.back') }}
                        <v-tooltip
                            activator="parent"
                            location="bottom"
                        >
                        {{t('archives.buttons.backTooltip')}}
                        </v-tooltip>
                    </v-btn>
                </v-col>
            </v-row>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, Ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import archiveService from '@/services/archive.service';
import { IArchive } from '@/interfaces/archive';
import { Archive } from '@/models/archive';

import TextField from '@/components/field/text.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '../../models/responseResult';

export default defineComponent({
    name: 'DisplayArchive',
    components: {
        TextField,
        Switch,
        Breadcrumbs,
    },
    props: {
        id: {
            type: Number,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;

        const router = useRouter();
        const goEdit = () => {
            useRedirectWithId(router, 'EditArchive', props.id);
        };
        const goBack = () => {
            useRedirect(router, 'Archives');
        };

        const archiveData = ref<IArchive>(new Archive());
        const getArchiveData = async () => {
            try {
                archiveData.value = await archiveService.displayArchive(props.id);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        onMounted(async () => {
            await getArchiveData();
        });

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
                title: t('archives.archive'),
                disabled: true,
            },
        ];

        return {
            t,
            archiveData,
            breadcrumbItems,
            goEdit,
            goBack,
            message,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
