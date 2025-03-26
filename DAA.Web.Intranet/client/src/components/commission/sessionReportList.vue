<template>
    <v-list lines="three">
        <session-report-list-item
            v-for="report in archiveReportData"
            :item="report"
            :key="report.id"
            :readOnly="readOnly"
            :sessionId="session.id"
            :showAddButton="showAddButton"
            @add="listItemAddHandler"
        />
    </v-list>
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, PropType, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { CommissionReportModel } from '@/models/commission';
import commisionReportService from '@/services/commissionReport.service';

import SessionReportListItem from '@/components/commission/sessionReportListItem.vue';
import { ICommissionSession, ISessionAgendaItem } from '@/interfaces/commission';


export default defineComponent({
    name: 'SessionReportList',
    components: {
        SessionReportListItem,
    },
    props: {
        session: {
            type: Object as PropType<ICommissionSession>,
            required: true,
        },
        readOnly: {
            type: Boolean,
            default: false,
        },
        showAddButton: {
            type: Boolean,
            default: true,
        },
    },
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const archiveReportData = ref<CommissionReportModel[]>([]);

        const getArchiveReportData = async () => {
            try {
                    archiveReportData.value = await commisionReportService.getListOfReportsByArchiveId(props.session.archiveId!);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const listItemAddHandler = async (item: ISessionAgendaItem) => {
            await getArchiveReportData();
            context.emit('add', item);
        };

        onMounted(async () => {
            await getArchiveReportData();
        });

        return {
            t,
            archiveReportData,
            getArchiveReportData,
            listItemAddHandler,
        };
    },
});
</script>
