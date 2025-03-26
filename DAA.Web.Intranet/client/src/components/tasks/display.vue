<template>
    <v-row>
        <v-col class="col-12">
            <text-field
            name="fldTitle"
            :label="t('tasks.columns.title')"
            v-model="model.title"
            :readonly="true"
            />
        </v-col>    
    </v-row>
    <v-row>
        <v-col class="col-12">
            <!-- <text-area-field
            name="fldDescription"
            :label="t('tasks.columns.description')"
            v-model="model.description"
            :readonly="true"
            /> -->
            <label class="html-label">{{t('tasks.columns.description')}}</label>
            <div
                class="html-body"
                :readonly="true"
                v-html="model.description"
            >
            </div>
        </v-col>
    </v-row>
    <v-row>
        <v-col class="col-12">
            <!-- <text-field
            name="fldUrl"
            :label="t('tasks.columns.relatedContentUrl')"
            v-model="model.relatedContentUrl"
            :readonly="true"
            /> -->
            <label class="html-label">{{t('tasks.columns.relatedContentUrl')}}</label>
            <div
                class="html-body"
                :readonly="true"
                v-html="model.relatedContentUrl"
            >
            </div>
        </v-col>    
    </v-row>
    <v-row>
        <v-col class="col-12">
            <text-field
            name="fldProcess"
            :label="t('tasks.columns.processType')"
            v-model="model.processTypeName"
            :readonly="true"
            />
        </v-col>    
    </v-row>
    <v-row>
        <v-col class="col-12">
            <text-field
            name="fldStep"
            :label="t('tasks.columns.stepTypeName')"
            v-model="model.stepTypeName"
            :readonly="true"
            />
        </v-col>    
    </v-row>
    <v-row>
        <v-col class="col-12">
            <text-field
            name="fldNotificationType"
            :label="t('tasks.columns.notificationTypeName')"
            v-model="model.notificationTypeName"
            :readonly="true"
            />
        </v-col>    
    </v-row>
    <v-row>
        <v-col class="col-4">
            <text-field
            name="fldCreatedOn"
            :label="t('tasks.columns.createdOn')"
            v-model="model.createdOnFormatted"
            :readonly="true"
            />
        </v-col>
        <v-col class="col-4">
            <text-field
            name="fldUpdatedOn"
            :label="t('tasks.columns.updatedOn')"
            v-model="model.updatedOnFormatted"
            :readonly="true"
            />
        </v-col>
        <v-col class="col-4">
            <text-field
            name="fldEndDate"
            :label="t('tasks.columns.endDate')"
            v-model="model.endDateFormatted"
            :readonly="true"
            />
        </v-col>
    </v-row>
    <v-row>
        <v-col class="col-4">
            <text-field
            name="fldCreatedBy"
            :label="t('tasks.columns.createdBy')"
            v-model="model.createdByDisplayName"
            :readonly="true"
            />
        </v-col>
        <v-col class="col-4">
            <text-field
            name="fldUpdatedBy"
            :label="t('tasks.columns.updatedBy')"
            v-model="model.updatedByDisplayName"
            :readonly="true"
            />
        </v-col>
        <v-col class="col-4">
            <text-field
            name="fldStatus"
            :label="t('tasks.columns.status')"
            v-model="model.statusName"
            :readonly="true"
            />
        </v-col>
    </v-row>
    <v-row>
        <v-col class="col-4">
            <text-field
            name="fldAssignedToUser"
            :label="t('tasks.columns.assignedTo')"
            v-model="model.assignedToDisplayName"
            :readonly="true"
            />
        </v-col>
        <v-col class="col-4">
            <text-field
            name="fldAssignedToRole"
            :label="t('tasks.columns.assignedToRole')"
            v-model="model.assignedToRoleName"
            :readonly="true"
            />
        </v-col>
    </v-row>
</template>

<script lang="ts">
import { defineComponent, computed, PropType } from "vue";
import { useI18n } from "vue-i18n";
import { Task } from "@/models/task";

import TextField from "@/components/field/text.field.vue";
//import TextAreaField from "@/components/field/textarea.field.vue";

export default defineComponent({
  name: "DisplayTaskData",
  components: {
    TextField,
    //TextAreaField,
  },
  props: {
    taskData: {
      type: Object as PropType<Task>,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n();

    const model = computed(() => props.taskData);

    return {
      t,
      model,
    };
  },
});
</script>

<style lang="scss" scoped>
.html-label {
  color: #adb5bd;
}
.html-body {
  background-color: #f8f9fa;
}
</style>

