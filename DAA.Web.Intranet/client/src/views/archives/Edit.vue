<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('archives.edit') }}</v-card-title>
        <Form @submit="submitArchiveData">
            <v-container>
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
                            {{t('archives.buttons.cancelTooltip')}}
                            </v-tooltip>
                        </v-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, onMounted, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import archiveService from '@/services/archive.service';
import { IArchive } from '@/interfaces/archive';
import { Archive } from '@/models/archive';

import { Form } from 'vee-validate';
import TextField from '@/components/field/text.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import { IMessage } from '../../interfaces/notification';

export default defineComponent({
    name: 'EditArchive',
    components: {
        Form,
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
        const goBack = () => {
            useRedirect(router, 'Archives');
        };

        const panel = ref(0);

        const archiveData = ref<IArchive>(new Archive());
        const getArchiveData = async () => {
            try {
                archiveData.value = await archiveService.displayArchive(props.id);
            } catch (error) {
                console.error(error);
                message.value = new Message({
                    text: error.response.data.message,
                    display: true,
                });
            }
        };

        const submitArchiveData = async () => {
            if (archiveData.value) {
                try {
                    const result = await archiveService.updateArchive(archiveData.value);
                    if (result.status == 200) {
                        message.value = new Message({
                            text: t('common.successfullyEdit'),
                            display: true,
                            type: 'success',
                            timeout: 5000,
                        });
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
                title: t('archives.edit'),
                disabled: true,
            },
        ];
        onMounted(() => {
            getArchiveData();
        });

        return {
            t,
            panel,
            breadcrumbItems,
            archiveData,
            goBack,
            submitArchiveData,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
