<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('filmDocuments.edit') }}</v-card-title>

        <Form @submit="submitFilmDocData" ref="filmDocumentForm" v-if="filmDocData">
            <v-container>
                <v-expansion-panels v-model="panel" multiple>
                    <v-expansion-panel value="doc">
                        <v-expansion-panel-title>{{ t('filmDocuments.title') }}</v-expansion-panel-title>
                        <v-expansion-panel-text>
                            <v-row>
                                <v-col class="col-12 lg-6">
                                    <label for="fldDocType" class="required">{{ t('filmDocuments.docType') }}</label>
                                    <Dropdown
                                        v-model="filmDocData.documentTypeId"
                                        name="fldDocType"
                                        :label="t('filmDocuments.docType')"
                                        labelProp="label"
                                        valueProp="id"
                                        :items="docTypes"
                                        required="required"
                                        @change="showTemplate"
                                        :disabled="readonlyDocTypes"
                                    />
                                </v-col>
                                <v-col class="col-6" v-if="templateItem">
                                    <label for="fldDocTemplate">{{ t('filmDocuments.docTemplate') }}</label>
                                    <div>
                                        {{ templateItem.fileName }}
                                        <a :href="buildFileDownloadUrl(templateItem.id)" class="text-decoration-none">
                                            <v-tooltip>
                                                <template v-slot:activator="{ props }">
                                                    <v-icon color="primary" dark v-bind="props"> mdi-download </v-icon>
                                                </template>
                                                <span>{{ $t('common.download') }}</span>
                                            </v-tooltip>
                                        </a>
                                    </div>
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col cols="12">
                                    <upload-file
                                        ref="fileUploader"
                                        :packageType="packageType"
                                        :fileName="fileName"
                                        @change="filesChanged"
                                        :required="true"
                                    ></upload-file>
                                </v-col>
                            </v-row>
                            <v-row v-if="packageType === 'B'">
                                <v-col cols="12">
                                    <Switch
                                        v-model="skipValidation"
                                        :label="t('filmDocuments.skipValidation')"
                                        :large="false"
                                        :showLabel="true"
                                    />
                                </v-col>
                            </v-row>
                            <v-row>
                                <v-col class="col-12">
                                    <text-area-field
                                        name="fldDescription"
                                        :label="t('filmDocuments.description')"
                                        v-model="filmDocData.description"
                                        auto-grow
                                    />
                                </v-col>
                            </v-row>
                        </v-expansion-panel-text>
                    </v-expansion-panel>
                </v-expansion-panels>
                <v-row class="mt-3">
                    <v-col class="d-flex justify-content-center">
                        <v-btn type="submit" :disabled="isBusy">{{ t('common.save') }}
                            <v-tooltip
                                activator="parent"
                                location="bottom"
                            >
                            {{t('common.saveTooltip')}}
                            </v-tooltip>
                        </v-btn>
                        <v-divider vertical></v-divider>
                        <v-btn class="cancel" @click="goBack" :disabled="isBusy">{{ t('common.cancel') }}
                            <v-tooltip
                                activator="parent"
                                location="bottom"
                            >
                            {{t('filmDocuments.cancelTooltip')}}
                            </v-tooltip>
                        </v-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
        <v-alert v-else
            prominent
            type="error"
            variant="outlined"
            >
            {{t('common.noDataMessage')}}
        </v-alert>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, inject, onMounted, Ref } from 'vue';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { IFilmPackageDocument } from '@/interfaces/film';
import { FilmPackageDocument, FilmPackageDocumentUpdateModel } from '@/models/film';
import { IDropdownOption } from '@/interfaces/dropdown';
import filmDocumentService from '@/services/filmDocument.service';
import dropdownService from '@/services/dropdown.service';
import packageAService from '@/services/packageATemplates.service';
import { ProcessType } from '@/enums/process';
import { EntityType } from '@/enums/entity';

import { Form } from 'vee-validate';
import TextAreaField from '@/components/field/textarea.field.vue';
import Dropdown from '@/components/dropdown/dropdown.vue';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { IPackageATemplate } from '@/models/packageATemplate';
import UploadFile from '@/components/files/uploadFile.vue';
import Switch from '@/components/checkbox/switch.vue';

export default defineComponent({
    name: 'EditFilmDocument',
    components: {
        Form,
        TextAreaField,
        Dropdown,
        UploadFile,
        Breadcrumbs,
        Switch,
    },
    props: {
        filmId: {
            type: String,
            required: true,
        },
        packageType: {
            type: String,
            required: true,
        },
        id: {
            type: Number,
            required: true,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const router = useRouter();

        const panel = ref(['doc']);
        const filmDocumentForm = ref();
        const fileUploader = ref();
        const skipValidation = ref(false);

        const goBack = () => {
            if (props.filmId) {
                useRedirectWithId(router, 'DisplayFilm', props.filmId);
            } else {
                useRedirect(router, 'Films');
            }
        };

        const filmDocData = ref<IFilmPackageDocument>(new FilmPackageDocument());
        const fileName = ref('');
        const isBusy = ref(false);
        const readonlyDocTypes = ref(false);

        const docTypes = ref<IDropdownOption[]>([]);
        const getDocTypes = async () => {
            docTypes.value = await dropdownService.getFilmDocTypes(props.packageType);
            readonlyDocTypes.value = docTypes.value.length == 1;
        };

        const getFilmDocumentData = async () => {
            isBusy.value = true;
            try {
                filmDocData.value = await filmDocumentService.displayFilmDocument(props.id);
                isBusy.value = false;
                if (filmDocData.value?.fileName) {
                    fileName.value = filmDocData.value.fileName;
                }
            } catch (error: unknown) {
                console.error(error);
                isBusy.value = false;
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const templates = ref<IPackageATemplate[]>([]);
        const loadTemplates = async () => {
            templates.value = [];
            templates.value = await packageAService.get(ProcessType.FilmRegisterData);
        };

        const templateItem = ref<IPackageATemplate>();
        const showTemplate = async (option: IDropdownOption) => {
            if (option && props.packageType == 'A') {
                const selectedName = option.label?.replace('*', '');
                templateItem.value = templates.value.find((x) => x.title == selectedName);
            }
        };

        const files = ref([] as File[]);
        const filesChanged = (model: File[]) => {
            files.value = model;
        };

        const buildFileDownloadUrl = (id: number) => {
            return packageAService.getFileDownloadUrl(id);
        };

        const isValidData = () => {
            (filmDocumentForm.value! as typeof Form).validate();

            return fileUploader.value.isValid();
        };

        const submitFilmDocData = async () => {
            if (!isValidData()) {
                return;
            }

            if (filmDocData.value) {
                isBusy.value = true;
                try {
                    const updateModel = new FilmPackageDocumentUpdateModel();
                    updateModel.id = filmDocData.value.id;
                    updateModel.entityType = EntityType.film;
                    updateModel.entitySystemIdentifier = props.filmId;
                    updateModel.packageId = filmDocData.value.packageId;
                    updateModel.documentTypeId = filmDocData.value.documentTypeId;
                    updateModel.description = filmDocData.value.description;
                    updateModel.file = files.value[0];
                    updateModel.skipValidation = props.packageType === 'B' ? skipValidation.value : true;

                    const result = await filmDocumentService.updateFilmDocument(updateModel);
                    isBusy.value = false;
                    if (result.status == 200) {
                        goBack();
                    } else {
                        message.value = new Message({
                            text: result.response.data.message,
                            display: true,
                        });
                    }
                } catch (error: unknown) {
                    console.log(error);
                    isBusy.value = false;
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
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
                title: t('archives.kmf'),
                disabled: false,
                to: { name: 'Films' },
            },
            {
                title: t('films.display'),
                disabled: false,
                to: { name: 'Films', params: { id: props.filmId } },
            },
            {
                title: t('filmDocuments.edit'),
                disabled: true,
            },
        ];

        onMounted(() => {
            getDocTypes();
            getFilmDocumentData();
            loadTemplates();
        });

        return {
            t,
            panel,
            filmDocData,
            submitFilmDocData,
            goBack,
            docTypes,
            breadcrumbItems,
            templateItem,
            showTemplate,
            buildFileDownloadUrl,
            filesChanged,
            fileName,
            filmDocumentForm,
            fileUploader,
            isBusy,
            readonlyDocTypes,
            skipValidation,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
