<template>
    <div v-if="loading" class="d-flex justify-content-center">
        <v-progress-circular :size="50" color="green-lighten-2" indeterminate></v-progress-circular>
    </div>

    <div v-if="!loading">
        <Form @submit="btnSubmitHandler" ref="sessionAgendaItemForm">
            <v-row>
                <v-col>
                    <label for="fldSessionDate" class="required">{{ t('sessions.columns.date') }}</label>
                    <Dropdown
                        v-model="sessionAgendaItem.sessionId"
                        name="fldSessionDate"
                        :label="t('sessions.columns.date')"
                        :items="sessions"
                        valueProp="id"
                        labelProp="label"
                        :disabled="isReadOnly"
                        required="required"
                    />
                </v-col>
            </v-row>
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
            <v-row class="mb-2" v-if="!readOnly">
                <v-col class="d-flex justify-content-center">
                        <v-btn v-if="!isReadOnly" type="submit"
                            >{{ t('common.save') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('common.saveTooltip') }}
                            </v-tooltip>
                        </v-btn>
                        <v-btn v-if="isReadOnly" @click="btnEditHandler">{{ t('common.edit') }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('common.edit') }}
                            </v-tooltip>
                        </v-btn>
                        <slot name="actions"></slot>
                </v-col>
            </v-row>
        </Form>
    </div>
</template>
<script lang="ts">
import { computed, defineComponent, inject, onMounted, PropType, Ref, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { IMessage } from '@/interfaces/notification';

import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { IProcess } from '@/interfaces/process';
import { ISessionAgendaItem, ISessionAgendaItemStandpoint } from '@/interfaces/commission';
import { SessionAgendaItem, SessionAgendaItemStandpoint } from '@/models/commission';
import { IDropdownOption } from '@/interfaces/dropdown';
import dropdownService from '@/services/dropdown.service';
import commissionReportService from '@/services/commissionReport.service';
import sessionAgendaService from '@/services/sessionAgenda.service';

import Dropdown from '@/components/dropdown/dropdown.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import { Form } from 'vee-validate';

export default defineComponent({
    name: 'SessionAgendaItem',
    components: {
        Dropdown,
        TextAreaField,
        Form,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>,
        },
        readOnly: {
            type: Boolean,
            default: false,
        },
    },
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const loading = ref(true);
        const sessionAgendaItemForm = ref();

        const isEditMode = ref<boolean>(false);
        const isReadOnly = computed(() => props.readOnly || !isEditMode.value);

        const sessionAgendaItem = ref<ISessionAgendaItem>(new SessionAgendaItem());
        const sessionAgendaItemStandpoint = ref<ISessionAgendaItemStandpoint>(new SessionAgendaItemStandpoint());

        const sessions = ref<IDropdownOption[]>([]);

        const getSessions = async () => {
            sessions.value = await dropdownService.getEPKSessions(props.process?.archiveId as number);
        };

        const getSessionAgendaItemData = async () => {
            loading.value = true;
            try {
                const item = await sessionAgendaService.displaySessionAgendaItemByProcess(props.process!.id!);
                if (item) {
                    console.log(item);
                    sessionAgendaItem.value = item;
                    sessionAgendaItemStandpoint.value =
                        await sessionAgendaService.displaySessionAgendaItemStandpointByItem(
                            sessionAgendaItem.value.id!
                        );
                }
                loading.value = false;
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
                loading.value = false;
            }
        };

        const isValidData = () => {
            (sessionAgendaItemForm.value! as typeof Form).validate();
            return true;
        };

        const btnSubmitHandler = async () => {
            if (!isValidData()) {
                return;
            }

            loading.value = true;
            try {
                sessionAgendaItem.value.standpoints = [sessionAgendaItemStandpoint.value];
                console.log(sessionAgendaItem.value, sessionAgendaItemStandpoint.value);
                if (!sessionAgendaItem.value.id) {
                    sessionAgendaItem.value.processId = props.process?.id;

                    const report = await commissionReportService.getByProcessId(props.process!.id!);

                    sessionAgendaItem.value.reportId = report.id;

                    await sessionAgendaService.createSessionAgendaItem(sessionAgendaItem.value);

                    await getSessionAgendaItemData();
                } else {
                    await sessionAgendaService.updateSessionAgendaItem(sessionAgendaItem.value);
                }

                loading.value = false;
                isEditMode.value = false;
                context.emit('submit', sessionAgendaItem.value);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
                loading.value = false;
            }
        };

        const btnEditHandler = () => {
            isEditMode.value = !isEditMode.value;
        };

        onMounted(async () => {
            await getSessions();
            await getSessionAgendaItemData();
            if (!props.readOnly && !sessionAgendaItem.value.id) {
                isEditMode.value = true;
            }
        });

        return {
            t,
            loading,
            sessionAgendaItemForm,
            isReadOnly,
            sessionAgendaItem,
            sessionAgendaItemStandpoint,
            sessions,
            btnSubmitHandler,
            btnEditHandler,
        };
    },
});
</script>
