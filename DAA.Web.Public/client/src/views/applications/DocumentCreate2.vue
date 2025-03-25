<template>
  <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
    <v-card-title class="v-card-title-uppercase">{{
      t("filmDocuments.create")
    }}</v-card-title>

    <Form @submit="submitFilmDocData" ref="filmDocumentForm">
      <v-container>
        <v-expansion-panels v-model="panel" multiple>
          <v-expansion-panel value="doc">
            <v-expansion-panel-title>{{
              t("filmDocuments.title")
            }}</v-expansion-panel-title>
            <v-expansion-panel-text>
              <v-row>
                <v-col class="col-6">
                  <label for="fldDocType" class="required">{{
                    t("filmDocuments.docType")
                  }}</label>
                  <Dropdown
                    v-model="filmDocData.documentTypeId"
                    name="fldDocType"
                    :label="t('filmDocuments.docType')"
                    labelProp="label"
                    valueProp="id"
                    :items="docTypes"
                    required="required"
                    @change="showTemplate"
                  />
                </v-col>
                <v-col class="col-6" v-if="templateItem">
                  <label for="fldDocTemplate">{{
                    t("filmDocuments.docTemplate")
                  }}</label>
                  <div>
                    {{ templateItem.fileName }}
                    <a
                      :href="buildFileDownloadUrl(templateItem.id)"
                      class="text-decoration-none"
                    >
                      <v-tooltip>
                        <template v-slot:activator="{ props }">
                          <v-icon color="primary" dark v-bind="props">
                            mdi-download
                          </v-icon>
                        </template>
                        <span>{{ $t("common.download") }}</span>
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
                    @change="filesChanged"
                  ></upload-file>
                </v-col>
              </v-row>
              <v-row>
                <v-col class="col-12">
                  <text-area-field
                    name="fldDescription"
                    :label="t('filmDocuments.description')"
                    v-model="filmDocData.description"
                  />
                </v-col>
              </v-row>
            </v-expansion-panel-text>
          </v-expansion-panel>
        </v-expansion-panels>
        <v-row class="mt-3">
          <v-col class="d-flex justify-content-center">
            <v-btn type="submit">{{ t("common.save") }}</v-btn>
            <v-divider vertical></v-divider>
            <v-btn class="cancel" @click="goBack">{{ t("common.cancel") }}</v-btn>
          </v-col>
        </v-row>
      </v-container>
    </Form>
  </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, inject, onMounted, Ref } from "vue";
import { useRouter } from "vue-router";
import { useI18n } from "vue-i18n";
import { useRedirect, useRedirectWithId } from "@/helpers/router.helper";
import { Message } from "@/models/notification";

import { IPackageDocument } from "@/models/applications";
import {
  PackageDocument,
  PackageDocumentCreateModel,
} from "@/models/applications";
import { IDropdownOption } from "@/interfaces/dropdown";
import filmDocumentService from "@/services/applicationPackages.service";
//import dropdownService from "@/services/dropdown.service";
import packageAService from "@/services/packageATemplates.service";
import { ProcessType } from "@/enums/process";
import { EntityType } from "@/enums/entity";

import { Form } from "vee-validate";
import TextAreaField from "@/components/field/textarea.field.vue";
import Dropdown from "@/components/dropdown/dropdown.vue";
import { IMessage } from "@/interfaces/notification";
import { ResponseResult } from "@/models/responseResult";
import { IPackageATemplate } from "@/models/packageATemplates";
import UploadFile from "@/components/files/upload.vue";

export default defineComponent({
  name: "CreateDocument",
  components: {
    Form,
    TextAreaField,
    Dropdown,
    UploadFile,
  },
  props: {
    filmId: {
      type: String,
      required: true,
    },
    packageId: {
      type: Number,
      required: true,
    },
    packageType: {
      type: String,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n();
    const message = inject("notificationMessage") as Ref<IMessage>;
    const router = useRouter();

    const panel = ref(["doc"]);
    const filmDocumentForm = ref();
    const fileUploader = ref();

    const goBack = () => {
      if (props.filmId) {
        useRedirectWithId(router, "DisplayFilm", props.filmId);
      } else {
        useRedirect(router, "Films");
      }
    };

    const filmDocData = ref<IPackageDocument>(new PackageDocument());

    const docTypes = ref<IDropdownOption[]>([]);
    const getDocTypes = async () => {
    //   docTypes.value = await dropdownService.getFilmDocTypes(props.packageType);
    //   if(docTypes.value.length == 1){
    //     filmDocData.value.documentTypeId = docTypes.value[0].id;
    //   }
    };

    const templates = ref<IPackageATemplate[]>([]);
    const loadTemplates = async () => {
      templates.value = [];
      templates.value = await packageAService.get(ProcessType.FilmRegisterData);
    };

    const templateItem = ref<IPackageATemplate>();
    const showTemplate = async (option: IDropdownOption) => {
      if (option && props.packageType == "A") {
        let selectedName = option.label?.replace("*", "");
        templateItem.value = templates.value.find(
          (x) => x.title == selectedName
        );
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

      try {
        filmDocData.value.packageId = props.packageId;

        let createModel = new PackageDocumentCreateModel();
        createModel.entityType = EntityType.film;
        createModel.entitySystemIdentifier = props.filmId;
        createModel.packageId = filmDocData.value.packageId;
        createModel.documentTypeId = filmDocData.value.documentTypeId;
        createModel.description = filmDocData.value.description;
        createModel.file = files.value[0];

        const result = await filmDocumentService.createFilmDocument(
          createModel
        );
        if (result.status == 200) {
          goBack();
        }
      } catch (error: unknown) {
        console.error(error);
        const errorResult  = error as ResponseResult;
        message.value = new Message({
          text:  errorResult.showMessage ? errorResult.message : t('error.basic'),
          display: true,
        });
      }
    };

    onMounted(() => {
      getDocTypes();
      loadTemplates();
    });

    return {
      t,
      panel,
      filmDocData,
      submitFilmDocData,
      goBack,
      docTypes,
      templateItem,
      showTemplate,
      buildFileDownloadUrl,
      filesChanged,
      filmDocumentForm,
      fileUploader,
    };
  },
});
</script>

<style lang="scss" scoped>

@import "@/assets/styles/display-create-edit.scss"

</style>
