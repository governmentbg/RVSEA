<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('tasks.display') }}</v-card-title>

        <v-container>
            <display-task-data :taskData="taskData"></display-task-data>

            <v-row class="mt-3">
                <v-col class="d-flex justify-content-center">
                    <v-btn class="clear bg-secondary" @click="goBack"
                        >{{ t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('tasks.buttons.backTooltip') }}
                        </v-tooltip>
                    </v-btn>
                </v-col>
            </v-row>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { Message } from '@/models/notification';
import { useRouter } from 'vue-router';

import taskService from '@/services/task.service';
import { ITask } from '@/interfaces/task';
import { Task } from '@/models/task';
import { formatDate, formatDateTime } from '@/helpers/format.helper';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import DisplayTaskData from '@/components/tasks/display.vue';
//import { AxiosError } from 'axios'
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';

export default defineComponent({
    name: 'DisplayTask',
    components: {
        DisplayTaskData,
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
            router.go(-1);
        };

        const taskData = ref<ITask>(new Task());
        const getTaskData = async () => {
            try {
                taskData.value = await taskService.display(props.id);
                taskData.value.endDateFormatted = taskData.value.endDate ? formatDate(taskData.value.endDate) : '';
                taskData.value.createdOnFormatted = taskData.value.createdOn
                    ? formatDateTime(taskData.value.createdOn)
                    : '';
                taskData.value.updatedOnFormatted = taskData.value.updatedOn
                    ? formatDateTime(taskData.value.updatedOn)
                    : '';
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.myTasks'),
                disabled: false,
                to: { name: 'MyTasks' },
            },
            {
                title: t('tasks.task'),
                disabled: true,
            },
        ];
        onMounted(async () => {
            await getTaskData();
        });

        return {
            t,

            breadcrumbItems,
            taskData,
            message,
            goBack,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs.scss';
</style>
