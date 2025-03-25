<template>
  <v-expansion-panel :value="showExpanded == true ? 'timeline' : 'false'">
    <v-expansion-panel-title>{{
      t("films.panels.timeline")
    }}</v-expansion-panel-title>
    <v-expansion-panel-text>
      <v-timeline align-top dense light side="end">
        <v-timeline-item
          :dot-color="index % 2 == 0 ? 'purple' : 'blue'"
          fill-dot
          small
          v-for="(item, index) in items"
          :key="item.id"
        >
          <!-- <v-row class="pt-1">
            <v-col cols="4">
              <div>{{ formatDateTime(item.createdOn) }}</div>
            </v-col>
            <v-col cols="8">
              <div>{{ item.stepTypeName }}</div>
              <small>{{t('common.from')}} {{ item.createdByDisplayName }} {{(item.assignedToUserDisplayName || item.assignedToRoleName) ? t('common.to') + ' ' + (item.assignedToUserDisplayName || item.assignedToRoleName) + (item.endDate != null ? ' ' + t('common.to') + ' ' + formatDate(item.endDate) : '') : ''}}</small>
              <div>
                <small class="italic">{{ item.comment }}</small>
              </div>
            </v-col>
          </v-row> -->
          <div class="d-flex">
            <div class="mr-4">{{ formatDateTime(item.createdOn) }}</div>
            <div>
              <div>{{ item.stepTypeName }}</div>
              <small>{{t('common.from')}} {{ item.createdByDisplayName }} {{(item.assignedToUserDisplayName || item.assignedToRoleName) ? t('common.to') + ' ' + (item.assignedToUserDisplayName || item.assignedToRoleName) + (item.endDate != null ? ' ' + t('common.to') + ' ' + formatDate(item.endDate) : '') : ''}}</small>
              <div>
                <small class="italic">{{ item.comment }}</small>
              </div>
            </div>
          </div>
        </v-timeline-item>
      </v-timeline>
    </v-expansion-panel-text>
  </v-expansion-panel>
</template>

<script lang="ts">
import { defineComponent, ref, inject, Ref, onMounted } from "vue";
import { useI18n } from "vue-i18n";
import { ProcessTimeline } from "@/models/process";
import { formatDateTime, formatDate } from "@/helpers/format.helper";
import processService from "@/services/process.service";
import { Message } from "@/models/notification";
import { IMessage } from "../../interfaces/notification";
import { ResponseResult } from "../../models/responseResult";

export default defineComponent({
  name: "TimelinePanel",
  components: {},
  props: {
    processId: {
      type: Number,
      required: true,
    },
    showExpanded: {
      type: Boolean,
      default: false
    }
  },
  setup(props) {
    const { t } = useI18n();
    const message = inject("notificationMessage") as Ref<IMessage>;

    const items = ref<ProcessTimeline[]>();
    items.value = [];

    const getTimeline = async () => {
      processService
        .getTimeline(props.processId)
        .then((result: ProcessTimeline[]) => {
          items.value = [];
          result.forEach((item) => {
            items.value?.push(item);
          });          
        })
        .catch((error: unknown) => {
          console.error(error);
          const errorResult  = error as ResponseResult;
          message.value = new Message({
            text:  errorResult.showMessage ? errorResult.message : t('error.basic'),
            display: true,
          });
        });
    };

    onMounted(async () => {
      await getTimeline();
    });

    return {
      t,
      formatDateTime,
      formatDate,
      items
    };
  },
});
</script>

<style lang="scss" scoped>
.italic {
  font-style: italic;
}
</style>