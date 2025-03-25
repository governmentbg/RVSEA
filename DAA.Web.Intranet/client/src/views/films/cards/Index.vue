<template>
  <div class="py-3">
    <grid
      ref="grid"
      :baseUrl="gridUrl"
      :columns="columns"
      :mode="'remote'"
      :paging="true"
      :pageSize="pageSize"
      :searchLabel="t('grid.search.tooltip')"
      :showSearch="false"
      :showExport="false"
      :noDataMessage="t('common.noDataMessage')"
    >
      <template v-slot:menubar>
        <v-btn v-if="!readonly" @click="addFilmCardHandler">{{
          t("films.buttons.createCard")
        }}
          <v-tooltip
              activator="parent"
              location="bottom"
          >
          {{t('films.buttons.createCardTooltip')}}
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
//import { formatYesNo } from '@/helpers/format.helper';
import { Message } from "@/models/notification";

import authorization from "@/helpers/authorization.helper";
import filmCardService from "@/services/filmCard.service";
import { IFilmCard } from "@/interfaces/film";
import { PageSize } from "@/models/grid";

import Grid from "@/components/grid/grid.vue";
import BtnsTemplate from "@/components/grid/btnsTemplate.vue";
import { IMessage } from "@/interfaces/notification";
import { ResponseResult } from "@/models/responseResult";

export default defineComponent({
  name: "FilmCards",
  components: {
    Grid,
  },
  props: {
    filmId: {
      type: String,
      required: true,
    },
    hasExternalSource: {
        type: Boolean,
        required: false,
    },
    externalIdentifier: {
      type: Number,
      required: false,
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
      filmCardService.getFilmCardsUrl(props.filmId, props.hasExternalSource, props.externalIdentifier)
    );

    const router = useRouter();

    const grid = ref();
     
    const addFilmCardHandler = () => {
      useRedirect(router, "CreateFilmCard", {
        filmId: props.filmId
      });
    };

    const rowButtons = [
      {
        name: "btnDisplayFilmCard",
        text: t("filmCards.buttons.display"),
        tooltip: t("filmCards.buttons.displayTooltip"),
        icon: "mdi mdi-eye",
        show: authorization.isAuthenticated(),
        clickHandler: (item: IFilmCard) => {          
          if (item.hasExternalSource) {
            useRedirect(router, "DisplayFilmCard", {
              filmId: item.filmExternalIdentifier,
              id: item.externalIdentifier
            },
            { 
              hasExternalSource: String(true)
            });
          }
          else {
            useRedirect(router, "DisplayFilmCard", {
              filmId: item.filmSystemIdentifier,
              id: item.systemIdentifier
            },
            { 
              hasExternalSource: String(false)
            });
          }
        },
      },
      {
        name: "btnEditFilmCard",
        text: t("filmCards.buttons.edit"),
        tooltip: t("filmCards.buttons.editTooltip"),
        icon: "mdi mdi-pencil",
        show: (item: IFilmCard) => {
          return authorization.isAuthenticated() && !props.readonly && !item.deleted && !item.hasExternalSource;
        },
        clickHandler: (item: IFilmCard) => {
          if (item.id && item.filmSystemIdentifier) {
            useRedirect(router, "EditFilmCard", {
              filmId: item.filmSystemIdentifier,
              id: item.systemIdentifier,
            });
          }
        },
      },
      {
        name: "btnDeleteFilmCard",
        text: t("filmCards.buttons.delete"),
        tooltip: t("filmCards.buttons.deleteTooltip"),
        class: "text-danger",
        icon: "mdi mdi-delete",
        show: (item: IFilmCard) => {
          return authorization.isAuthenticated() && !props.readonly && !item.deleted && !item.hasExternalSource;
        },
        clickHandler: async (item: IFilmCard) => {
          if (item.id) {
            if (
              confirm(t("filmCards.buttons.deleteConfirmation", {number: item.inventoryNumber }))
            ) {
              try {
                const result = item.isDraft == true ? await filmCardService.deleteFilmCardDraft(item.id) : await filmCardService.deleteFilmCard(item.systemIdentifier || '0');
                if (result.status == 200) {
                  if (grid.value) {
                    grid.value.refreshData();
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
      {
        name: "btnPrintFilmCard",
        text: t("filmCards.buttons.print"),
        tooltip: t("filmCards.buttons.printTooltip"),
        icon: "mdi mdi-printer",
        show: authorization.isAuthenticated(),
        clickHandler: async (item: IFilmCard) => {
          if(item.isDraft) {
            message.value = new Message({
              text:  t('filmCards.cannotPrintCard'),
              display: true,
              type: 'warning'
            });

            return;
          }
          if (item.systemIdentifier) {
            const { href } = router.resolve({ name: "PrintFilmCard", params: { cardId: item.systemIdentifier }});
            window.open(href, '_blank');
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
        title: t("filmCards.columns.country"),
        prop: "countryName",
        type: "string",
        sortable: false,
        filterable: false,
      },
      {
        title: t("filmCards.columns.inventoryNumber"),
        prop: "inventoryNumber",
        type: "string",
        sortable: false,
        filterable: false,
      },
      {
        title: t("filmCards.columns.title"),
        prop: "title",
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
      addFilmCardHandler,
    };
  },
});
</script>

<style lang="scss" scoped>

@import "@/assets/styles/index.scss"

</style>
