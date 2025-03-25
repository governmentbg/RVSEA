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
      @rowClick="onRowClick"
    >
      <template v-slot:menubar>
        <v-btn v-if="!readonly" @click="addFilmCardHandler">{{
          t("films.buttons.createCard")
        }}</v-btn>
      </template>
    </grid>
  </div>
</template>
<script lang="ts">
import { computed, defineComponent, ref, inject, Ref } from "vue";
import { useI18n } from "vue-i18n";
import { useRouter } from "vue-router";
import { useRedirect } from "@/helpers/router.helper";
import { Message } from "@/models/notification";

import filmCardService from "@/services/filmCard.service";
import { PageSize } from "@/models/grid";

import Grid from "@/components/grid/grid.vue";
import { IMessage } from "@/interfaces/notification";
import RowItem from '@/components/grid/rowItem.vue'

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
    readonly: {
      type: Boolean,
      required: true,
    },
    // doRefresh: {
    //   type: Boolean,
    //   required: false,
    //   default: false,
    // },
  },
  setup(props) {
    const { t } = useI18n();
    const message = inject("notificationMessage") as Ref<IMessage>;
    
    const gridUrl = computed(() =>
      filmCardService.getFilmCardsUrl(props.filmId)
    );

    const router = useRouter();

    const grid = ref();
     
    const addFilmCardHandler = () => {
      useRedirect(router, "CreateFilmCard", {
        filmId: props.filmId
      });
    };

    const onRowClick = (row: typeof RowItem) => {
        if (row.items.systemIdentifier && !row.items.hasExternalSource) {
            useRedirect(router, "DisplayFilmCard", {
                filmId: row.items.filmSystemIdentifier,
                id: row.items.systemIdentifier,
              });
        } else {
            message.value = new Message({
                text: t('error.operationError'),
                display: true,
            });
        }
    };

    const columns = [
      {
        title: () => t("filmCards.columns.country"),
        prop: "countryName",
        type: "string",
        sortable: false,
        filterable: false,
      },
      {
        title: () => t("filmCards.columns.inventoryNumber"),
        prop: "inventoryNumber",
        type: "string",
        sortable: true,
        filterable: false,
      },
      {
        title: () => t("filmCards.columns.title"),
        prop: "title",
        type: "string",
        sortable: true,
        filterable: false,
      },
    ];

    const pageSize = PageSize.ten;

    // watch(() => props.doRefresh, () => {      
    //     if(props.doRefresh && grid.value){
    //         grid.value.refreshData();            
    //     }
    // })

    return {
      t,
      grid,
      gridUrl,
      columns,
      pageSize,
      addFilmCardHandler,
      onRowClick,
    };
  },
});
</script>

<style lang="scss" scoped>

@import "@/assets/styles/index.scss";

</style>
