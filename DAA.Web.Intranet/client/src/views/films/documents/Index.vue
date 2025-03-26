<template>
  <div class="py-3">
    <grid
      ref="grid"
      :baseUrl="gridUrl"
      :columns="columns"
      :mode="'remote'"
      :paging="true"
      :pageSize="pageSize"
      :showSearch="false"
      :showExport="false"
      :noDataMessage="t('common.noDataMessage')"
    >
      <template v-slot:menubar>
        <v-btn v-if="!readonly" @click="addFilmDocumentHandler">{{
          t("common.add")
        }}
          <v-tooltip
              activator="parent"
              location="bottom"
          >
          {{t('filmDocuments.create')}}
          </v-tooltip>
        </v-btn>
      </template>
    </grid>
  </div>
</template>
<script lang="ts">
import { computed, defineComponent, inject, ref, Ref } from "vue";
import { useI18n } from "vue-i18n";
import { useRouter } from "vue-router";
import { useRedirect } from "@/helpers/router.helper";
import { Message } from "@/models/notification";

import authorization from "@/helpers/authorization.helper";
import filmDocumentService from "@/services/filmDocument.service";
import { IFilmPackageDocument } from "@/interfaces/film";
import { PageSize } from "@/models/grid";

import Grid from "@/components/grid/grid.vue";
import BtnsTemplate from "@/components/grid/btnsTemplate.vue";
import HyperlinkTemplate from '@/components/grid/hyperlinkTemplate.vue';
import { IMessage } from "@/interfaces/notification";
import { ResponseResult } from "@/models/responseResult";
import { formatBytes } from "@/helpers/format.helper";
import { EntityType } from "@/enums/entity";
import { HyperlinkInfo } from '@/models/hyperlink';

export default defineComponent({
  name: "FilmDocuments",
  components: {
    Grid,
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
    readonly: {
      type: Boolean,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n();
    const message = inject("notificationMessage") as Ref<IMessage>;

    const gridUrl = computed(() =>
      filmDocumentService.getFilmDocumentsUrl(props.packageId)
    );

    const router = useRouter();

    const grid = ref();

    const addFilmDocumentHandler = () => {
      useRedirect(router, "CreateFilmDocument", {
        filmId: props.filmId,
        packageId: props.packageId,
        packageType: props.packageType,
      });
    };

    const rowButtons = [
      {
        name: "btnDisplayFilmDocument",
        text: t("common.display"),
        tooltip: t("filmDocuments.displayTooltip"),
        icon: "mdi mdi-eye",
        show: authorization.isAuthenticated(),
        clickHandler: (item: IFilmPackageDocument) => {
          if (item.id) {
            useRedirect(router, "DisplayFilmDocument", {
              filmId: props.filmId,
              packageType: props.packageType,
              id: item.id,
            });
          }
        },
      },
      {
        name: "btnEditFilmDocument",
        text: t("filmDocuments.edit"),
        tooltip: t("filmDocuments.editTooltip"),
        icon: "mdi mdi-pencil",
        show: () => {
          return authorization.isAuthenticated() && !props.readonly;
        },
        clickHandler: (item: IFilmPackageDocument) => {
          if (item.id) {
            useRedirect(router, "EditFilmDocument", {
              filmId: props.filmId,
              packageType: props.packageType,
              id: item.id,
            });
          }
        },
      },
      {
        name: "btnDeleteFilmDocument",
        text: t("common.delete"),
        tooltip: t("filmDocuments.deleteTooltip"),
        class: "text-danger",
        icon: "mdi mdi-delete",
        show: () => {
          return authorization.isAuthenticated() && !props.readonly;
        },
        clickHandler: async (item: IFilmPackageDocument) => {
          if (item.id) {
            if (confirm(t("filmDocuments.deleteConfirmation"))) {
              try {
                const result = await filmDocumentService.deleteFilmDocument(item.id, EntityType.film, props.filmId);
                if (result.status == 200) {
                  if (grid.value) {
                    //grid.value.refreshData();
                    router.go(0);
                  }
                } else {
                  message.value = new Message({
                    text: result.response.data.message,
                    display: true,
                  });
                }
              } catch (error: unknown) {
                const errorResult  = error as ResponseResult;
                message.value = new Message({
                  text:  errorResult.showMessage ? errorResult.message : t('error.basic'),
                  display: true,
                });
              }
            }
          }
        },
      },
    ];

    const columns = [
      {
        prop: "",
        title: "",
        type: "vue",
        template: (e: ObjectConstructor) => {
          return {
            template: BtnsTemplate,
            templateArgs: {
              ...e,
              btns: rowButtons,
              showAsDropdown: true,
            },
          };
        },
        sortable: false,
        filterable: false,
      },
      {
        title: t("filmDocuments.docType"),
        prop: "documentTypeName",
        type: "string",
        sortable: false,
        filterable: false,
      },
      {
        title: t("filmDocuments.fileName"),
        prop: '', 
        type: 'vue', 
        sortable: false,
        filterable: false,
        template: (e: IFilmPackageDocument) => {
              return {
                  template: HyperlinkTemplate,
                  templateArgs: {
                      ...e,
                      formatter: (item: IFilmPackageDocument | undefined) => {
                          return [
                              new HyperlinkInfo({
                                  title: item?.fileName,
                                  href: filmDocumentService.getFileDownloadUrl(item?.id || 0, true),
                                  target: '_blank',
                              }),
                          ];
                      },
                  },
              };
          },
      },
      {
        title: t("filmDocuments.fileSize"),
        prop: "fileSizeInBytes",
        type: "number",
        renderFunction: formatBytes,
        sortable: false,
        filterable: false,
      },
      {
        title: t("filmDocuments.description"),
        prop: "description",
        type: "string",
        sortable: false,
        filterable: false,
      },
    ];

    const pageSize = PageSize.ten;

    return {
      t,
      grid,
      gridUrl,
      columns,
      pageSize,
      addFilmDocumentHandler,
    };
  },
});
</script>

<style lang="scss" scoped>

@import "@/assets/styles/index.scss"

</style>
