<template>
    <v-list lines="three">
        <v-list-subheader v-if="showListHeader">{{ t('sessionAgenda.columns.standpoints') }}</v-list-subheader>
        <session-agenda-standpoint-item
            v-for="item in standpointData"
            :key="item.id"
            :item="item"
            :processId="process.id"
            :process="process"
            :readOnly="readOnly"
            @setStatus="getStandpointData"
            @editStandpoint="editStandpointMethod"
            @validateCanEditStandpoint="validateCanEditStandpoint"
        />
    </v-list>
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, PropType, Ref, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { formatDateTime } from '@/helpers/format.helper';

import { IProcess } from '@/interfaces/process';
import { ISessionAgendaItemStandpoint } from '@/interfaces/commission';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import sessionAgendaService from '@/services/sessionAgenda.service';

import SessionAgendaStandpointItem from '@/components/commission/sessionAgendaStandpointItem.vue';

export default defineComponent({
    name: 'SessionAgendaStandpoints',
    components: {
        SessionAgendaStandpointItem,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>,
        },
        showListHeader: {
            type: Boolean,
            default: false,
        },
        readOnly: {
            type: Boolean,
            default: false,
        },
    },
    emits: ['editStandpoint', 'validateCanEditStandpoint'],
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const standpointData = ref<ISessionAgendaItemStandpoint[]>([]);

        const editStandpointMethod = async () => {
         context.emit("editStandpoint");
        }

        const validateCanEditStandpoint = async () => {
            context.emit('validateCanEditStandpoint');
        }

        const getStandpointData = async () => {
            try {
                standpointData.value = await sessionAgendaService.displaySessionAgendaItemStandpointsByProcess(
                    props.process!.id!
                );
                standpointData.value.forEach(s => {
                    if(s.updatedBy != null 
                       && s.updatedBy != undefined 
                       && formatDateTime(s.createdOn!) == formatDateTime(s.updatedOn!)) {
                        s.updatedBy = undefined;
                        s.updatedByDisplayName = undefined;
                        s.updatedOn = undefined;
                    }
                });
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        onMounted(async () => {
            await getStandpointData();
        });

        return {
            t,
            formatDateTime,
            standpointData,
            getStandpointData,
            editStandpointMethod,
            validateCanEditStandpoint,
        };
    },
});
</script>
