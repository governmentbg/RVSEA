<template>
    <v-list lines="three">
        <session-agenda-list-item
            v-for="item in sessionAgendaData"
            :key="item.id"
            :item="item"
            :showStandpoint="showStandpoint"
            :showDecision="showDecision"
            :showDecisionButton="showDecisionButton"
            :showDeleteButton="showDeleteButton"
            :showSelectButton="showSelectButton"
            :readOnly="readOnly"
            @select="listItemSelectHandler"
            @delete="listItemDeleteHandler"
        />
    </v-list>
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { ISessionAgendaItem } from '@/interfaces/commission';
import sessionAgendaService from '@/services/sessionAgenda.service';
import SessionAgendaListItem from '@/components/commission/sessionAgendaListItem.vue';

export default defineComponent({
    name: 'SessionAgendaList',
    components: {
        SessionAgendaListItem,
    },
    props: {
        sessionId: {
            type: Number,
            required: true,
        },
        readOnly: {
            type: Boolean,
            default: false,
        },
        showDecision: {
            type: Boolean,
            default: true,
        },
        showStandpoint: {
            type: Boolean,
            default: true,
        },
        showDecisionButton: {
            type: Boolean,
            default: true,
        },
        showDeleteButton: {
            type: Boolean,
            default: false,
        },
        showSelectButton: {
            type: Boolean,
            default: false,
        },
    },
    emits: ['select', 'delete'],
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        
        const selectedItems = ref<Array<number>>([]);

        const sessionAgendaData = ref<ISessionAgendaItem[]>([]);
        const getSessionAgendaData = async () => {
            try {
                sessionAgendaData.value = await sessionAgendaService.getSessionAgenda(props.sessionId);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const listItemSelectHandler = (isSelected: boolean, id: number) => {
            const index = selectedItems.value.findIndex(i => i === id);
            if (isSelected) {
                if ( index === -1) {
                    selectedItems.value.push(id)
                } 
            } else {
                if (index !== -1) {
                    selectedItems.value.splice(index, 1);
                }
            }

            context.emit('select', selectedItems.value);
        };

        const listItemDeleteHandler = async () => {
            context.emit('delete');
            await getSessionAgendaData();
        };

        onMounted(async () => {
            await getSessionAgendaData();
        });

        return {
            t,
            sessionAgendaData,
            getSessionAgendaData,
            listItemSelectHandler,
            listItemDeleteHandler,
        };
    },
});
</script>

