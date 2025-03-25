<template>
    <v-row>
        <v-col>
            <text-area-field
                v-model="sessionAgendaItemStandpoint.content"
                :label="t('sessionAgenda.columns.standpoint')"
                validation="required"
                :readonly="isReadOnly"
            />
        </v-col>
    </v-row>
    <v-row class="mb-2" v-if="(!readOnly && isDraft)">
        <v-col class="d-flex gap-2 justify-content-center">
            <v-btn v-if="!isReadOnly" @click="btnSubmitHandler">{{ t('common.save') }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('common.saveTooltip')}}
                </v-tooltip>
            </v-btn>
            <v-btn v-if="isReadOnly" @click="btnEditHandler">{{ t('common.edit') }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('common.edit')}}
                </v-tooltip>
            </v-btn>
            <v-btn v-if="isReadOnly" @click="btnCommitHandler">{{ t('sessionAgenda.buttons.commitStandpoint') }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('sessionAgenda.buttons.commitStandpointTooltip')}}
                </v-tooltip>
            </v-btn>
            <slot name="actions"></slot>
        </v-col>
    </v-row>
</template>
<script lang="ts">
import { computed, defineComponent, inject, onMounted, PropType, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { IMessage } from '@/interfaces/notification';

import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { IProcess } from '@/interfaces/process';
import { ISessionAgendaItemStandpoint } from '@/interfaces/commission';
import { SessionAgendaItemStandpoint } from '@/models/commission';
import commissionReportService from '@/services/commissionReport.service';
import sessionAgendaService from '@/services/sessionAgenda.service';
import { isDateAtLeastNDaysFromStartDay } from '@/helpers/validate.helper';

import TextAreaField from '@/components/field/textarea.field.vue';
import { useStore } from '@/store/user';


export default defineComponent({
    name: 'SessionAgendaStandpoint',
    components: {
        TextAreaField,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>,
        },
        // sessionAgendaItem: {
        //     type: Object as PropType<ISessionAgendaItem>,
        // },
        readOnly: {
            type: Boolean,
            default: false,
        },
        isInTermForEditByUser: {
            type: Boolean,
            default: false,
        },
    },
    emits: ['submit', 'commit'],
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const isEditMode = ref<boolean>(false);
        const isReadOnly = computed(() => props.readOnly || !isEditMode.value);
        const isItInTermForEditByUser = computed(() => props.isInTermForEditByUser);
        
        const userStore = useStore();
        const currUserId =  userStore.getters.userId;
        
        const isDraft = computed(
            () =>
                !sessionAgendaItemStandpoint.value ||
                !sessionAgendaItemStandpoint.value.id ||
                (sessionAgendaItemStandpoint.value.id && sessionAgendaItemStandpoint.value.isDraft)
        );

        const sessionAgendaItemStandpoint = ref<ISessionAgendaItemStandpoint>(new SessionAgendaItemStandpoint());

        const getSessionAgendaItemStandpointData = async () => {
            try {
                const standpoint = await sessionAgendaService.displaySessionAgendaItemStandpointByProcess(
                    props.process!.id!
                );
                if (standpoint) {
                    sessionAgendaItemStandpoint.value = standpoint;
                }
                if (!sessionAgendaItemStandpoint.value.id) {
                    const report = await commissionReportService.getByProcessId(props.process!.id!);
                    if (report) {
                        sessionAgendaItemStandpoint.value.reportId = report.id;
                    }
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnSubmitHandler = async () => {
            try {
                if (!sessionAgendaItemStandpoint.value.id) {
                    await sessionAgendaService.createSessionAgendaItemStandpoint(sessionAgendaItemStandpoint.value);

                    await getSessionAgendaItemStandpointData();
                } else {
                    await sessionAgendaService.updateSessionAgendaItemStandpoint(sessionAgendaItemStandpoint.value);
                }

                isEditMode.value = false;
                context.emit('submit', sessionAgendaItemStandpoint.value);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnCommitHandler = async () => {
            try {
                sessionAgendaItemStandpoint.value.isDraft = false;
                await sessionAgendaService.updateSessionAgendaItemStandpoint(sessionAgendaItemStandpoint.value);
                
                isEditMode.value = false;
                context.emit('commit', sessionAgendaItemStandpoint.value);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnEditHandler = () => {
            isEditMode.value = !isEditMode.value;
        };

        onMounted(async () => {
            await getSessionAgendaItemStandpointData();
            if (!props.readOnly && !sessionAgendaItemStandpoint.value.id) {
                isEditMode.value = true;
            }
        });

        return {
            t,
            isDraft,
            isItInTermForEditByUser,
            isReadOnly,
            sessionAgendaItemStandpoint,
            currUserId,
            btnSubmitHandler,
            btnCommitHandler,
            btnEditHandler,
            isDateAtLeastNDaysFromStartDay,
            getSessionAgendaItemStandpointData,
        };
    },
});
</script>
