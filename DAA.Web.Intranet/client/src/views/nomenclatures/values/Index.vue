<template>
  <div class="py-3">
    <grid
      ref="grid"
      :mode="'remote'"
      :baseUrl="gridUrl"
      :columns="columns"
      :paging="true"
      :pageSize="pageSize"
      :searchLabel="t('grid.search.tooltip')"
    >
      <template v-slot:menubar>
        <v-btn @click="addNomenclatureValueHandler">{{
          t("nomenclature.buttons.createValue")
        }}
          <v-tooltip
              activator="parent"
              location="bottom"
          >
          {{t('nomenclature.buttons.createValueTooltip')}}
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
import { formatDateTime, formatYesNo } from "@/helpers/format.helper";
import { Message } from "@/models/notification";

import authorization from "@/helpers/authorization.helper";
import nomenclatureService from "@/services/nomenclature.service";
import { INomenclatureValue } from "@/interfaces/nomenclature";
import { PageSize } from "@/models/grid";

import Grid from "@/components/grid/grid.vue";
import BtnsTemplate from "@/components/grid/btnsTemplate.vue";
import { IMessage } from "../../../interfaces/notification";
import { ResponseResult } from "../../../models/responseResult";

export default defineComponent({
  name: "NomenclatureValues",
  components: {
    Grid,
  },
  props: {
    parentId: {
      type: Number,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n();
    const message = inject("notificationMessage") as Ref<IMessage>;

    const gridUrl = computed(() =>
      nomenclatureService.getNomenclatureValuesUrl(props.parentId)
    );

    const router = useRouter();

    const grid = ref();

    const addNomenclatureValueHandler = () => {
      useRedirect(router, "CreateNomenclatureValue", {
        parentId: props.parentId,
      });
    };

    const rowButtons = [
      {
        name: "btnDisplayNomenclatureValue",
        text: t("nomenclature.values.buttons.display"),
        tooltip: t("nomenclature.values.buttons.displayTooltip"),
        icon: "mdi mdi-eye",
        show: authorization.isAuthenticated(),
        clickHandler: (item: INomenclatureValue) => {
          if (item.id && item.parentId) {
            useRedirect(router, "DisplayNomenclatureValue", {
              parentId: item.parentId,
              id: item.id,
            });
          }
        },
      },
      {
        name: "btnEditNomenclatureValue",
        text: t("nomenclature.values.buttons.edit"),
        tooltip: t("nomenclature.values.buttons.editTooltip"),
        icon: "mdi mdi-pencil",
        show: authorization.isAuthenticated(),
        clickHandler: (item: INomenclatureValue) => {
          if (item.id && item.parentId) {
            useRedirect(router, "EditNomenclatureValue", {
              parentId: item.parentId,
              id: item.id,
            });
          }
        },
      },
      {
        name: "btnDeleteNomenclatureValue",
        text: t("nomenclature.values.buttons.delete"),
        tooltip: t("nomenclature.values.buttons.deleteTooltip"),
        class: "text-danger",
        icon: "mdi mdi-delete",
        show: authorization.isAuthenticated(),
        clickHandler: async (item: INomenclatureValue) => {
          if (item.id) {
            if (
              confirm(
                t("nomenclature.values.buttons.deleteConfirmation", {
                  title: item.text,
                })
              )
            ) {
              try {
                const result =
                  await nomenclatureService.deleteNomenclatureValue(item.id);
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
                const errorResult  = error as ResponseResult
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
        title: t("nomenclature.columns.text"),
        prop: "text",
        type: "string",
        sortable: true,
        filterable: true,
      },
      {
        title: t("nomenclature.columns.code"),
        prop: "code",
        type: "string",
        sortable: true,
        filterable: true,
      },
      {
        title: t("nomenclature.columns.inactive"),
        prop: "inactive",
        type: "boolean",
        renderFunction: formatYesNo,
        sortable: true,
        filterable: true,
      },
      {
        title: t("nomenclature.columns.description"),
        prop: "description",
        type: "string",
        sortable: true,
        filterable: true,
      },
      {
        title: t("nomenclature.columns.sortOrder"),
        prop: "sortOrder",
        type: "number",
        sortable: true,
      },
      {
        title: t("nomenclature.columns.createdBy"),
        prop: "createdByDisplayName",
        type: "string",
        sortable: true,
        filterable: true,
      },
      {
        title: t("nomenclature.columns.createdOn"),
        prop: "createdOn",
        type: "date",
        renderFunction: formatDateTime,
        sortable: true,
        filterable: true,
      },
      {
        title: t("nomenclature.columns.updatedBy"),
        prop: "updatedByDisplayName",
        type: "string",
        sortable: true,
        filterable: true,
      },
      {
        title: t("nomenclature.columns.updatedOn"),
        prop: "updatedOn",
        type: "date",
        renderFunction: formatDateTime,
        sortable: true,
        filterable: true,
      },
    ];

    const pageSize = PageSize.twenty;

    return {
      t,
      grid,
      gridUrl,
      columns,
      pageSize,
      addNomenclatureValueHandler,
    };
  },
});
</script>

<style lang="scss" scoped>

@import "@/assets/styles/index.scss";

:deep(.input-group) {
  background-color: white;
  box-shadow: none;
}

:deep(.py-3:has(input)) {
  height: 40px;
}

:deep(input.form-control) {
  height: 40px;
  margin: auto;
  box-shadow: gray 0px 1px 3px 0px;
}

</style>