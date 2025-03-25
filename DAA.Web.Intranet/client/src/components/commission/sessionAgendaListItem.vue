<template>
    <v-list-group v-if="item" collapse-icon="" expand-icon="">
        <template v-slot:activator="{ props }">
            <v-list-item>
                <v-list-item-title
                    >{{ t('sessionAgenda.columns.reportNumber') }} {{ item.reportNumber }}</v-list-item-title
                >
                <v-list-item-title>{{ item.processTypeTitle }}</v-list-item-title>
                <v-list-item-subtitle>
                    {{ t('sessionAgenda.columns.reportCreatedBy') }} {{ item.reportCreatedByDisplayName }}
                </v-list-item-subtitle>
                <template v-slot:append="{ isActive }">
                    <v-btn
                        color="transparent"
                        flat
                        icon
                        v-bind="props"
                        @click="btnShowAgendaItemClickHandler(!isActive)"
                    >
                        <v-icon>mdi-eye</v-icon>
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('sessionAgenda.buttons.displaySessionAgendaItem') }}
                        </v-tooltip>
                    </v-btn>
                    <v-btn
                        v-if="showDecisionButton && !readOnly"
                        color="transparent"
                        flat
                        icon
                        @click="btnSetDecisionClickHandler(item.id)"
                    >
                        <v-icon>mdi-note-edit</v-icon>
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('sessionAgenda.buttons.setDecision') }}
                        </v-tooltip>
                    </v-btn>
                    <v-btn
                        v-if="showDeleteButton && !readOnly"
                        color="transparent"
                        flat
                        icon
                        @click="btnDeleteClickHandler(item.id)"
                    >
                        <v-icon>mdi-playlist-remove</v-icon>
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('common.remove') }}
                        </v-tooltip>
                    </v-btn>
                    <v-checkbox-btn
                        v-if="showSelectButton"
                        v-model="isSelected"
                        color="primary"
                        hide-details
                    ></v-checkbox-btn>
                </template>
            </v-list-item>
        </template>
        <v-list-item>
            <div class="mb-2">
                <hyper-link :title="entityLinkText" :to="entityLinkData" target="_blank" />
            </div>
            <textarea-field
                :label="t('sessionAgenda.columns.reportContent')"
                v-model="reportData.content"
                :readonly="true"
            />
            <v-list v-if="reportFiles && reportFiles.length > 0" density="compact">
                <v-list-subheader>{{ t('epkReport.files') }}</v-list-subheader>
                <v-list-item
                    density="compact"
                    v-for="item in reportFiles"
                    :key="item.id"
                    :value="item.id"
                    :title="item.sourceName"
                >
                    <template #append>
                        <v-btn
                            class="floatingBtnIcon"
                            icon="mdi-download"
                            @click="downloadReportFile(item.id, item.sourceName)"
                        />
                    </template>
                </v-list-item>
            </v-list>
        </v-list-item>
        <v-list-item v-if="process && showStandpoint">
            <v-divider></v-divider>
            <SessionAgendaStandpoints :process="process" :readOnly="true" :showListHeader="true" />
        </v-list-item>
        <v-list-item v-if="showDecision">
            <v-divider></v-divider>
            <textarea-field
                :label="t('sessionAgenda.columns.decision')"
                v-model="decisionData.decisionText"
                :readonly="true"
            />
        </v-list-item>
    </v-list-group>
    <v-dialog v-model="showDecisionDialog" persistent>
        <v-card width="30%">
            <v-card-title>{{ t('sessionAgenda.decision') }}</v-card-title>
            <v-card-text>
                <label>{{ t('epkProtocol.deadline') }}</label>
                <datep-picker
                    :startDate="new Date()"
                    v-model:date="modifiedDecisionData.deadlineForApproval"
                    class="mb-2"
                />
                <label>{{ t('epkProtocol.decision') }}</label>
                <textarea-field v-model="modifiedDecisionData.decisionText" />
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <dialog-btn :disabled="disabledSaveButton" @click="btnSubmitDecisionClickHandler">
                    {{ t('common.save') }}
                </dialog-btn>
                <cancel-btn @click="btnCancelClickHandler">
                    {{ t('common.cancel') }}
                </cancel-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>
<script lang="ts">
import { defineComponent, inject, PropType, ref, Ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { formatDateTime } from '@/helpers/format.helper';
import { RouteLocationRaw } from 'vue-router';

import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { IProcess } from '@/interfaces/process';
import {
    ICommissionDecision,
    ICommissionReport,
    ICommissionReportFile,
    ISessionAgendaItem,
} from '@/interfaces/commission';
import { CommissionDecisionModel, CommissionReportModel } from '@/models/commission';
import commissionReportService from '@/services/commissionReport.service';
import commissionDecisionService from '@/services/commissionDecision.service';
import processService from '@/services/process.service';
import fundService from '@/services/fund.service';
import inventoryService from '@/services/inventory.service';
import archiveEntityService from '@/services/archivalEntity.service';
import documentService from '@/services/document.service';
import sessionAgendaService from '@/services/sessionAgenda.service';

import TextareaField from '@/components/field/textarea.field.vue';
import HyperLink from '@/components/hyperlink/hyperlink.vue';
import SessionAgendaStandpoints from '@/components/commission/sessionAgendaStandpoints.vue';
import DatepPicker from '../datetime/datepPicker.vue';

export default defineComponent({
    name: 'SessionAgendaListItem',
    components: {
        TextareaField,
        HyperLink,
        SessionAgendaStandpoints,
        DatepPicker,
    },
    props: {
        item: {
            type: Object as PropType<ISessionAgendaItem>,
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
        const disabledSaveButton = ref<boolean>(false);
        const isSelected = ref<boolean>(false);

        const showDecisionDialog = ref<boolean>(false);

        const entityLinkText = ref<string>('');
        const entityLinkData = ref<RouteLocationRaw>();

        const process = ref<IProcess>();
        const reportData = ref<ICommissionReport>(new CommissionReportModel());
        const reportFiles = ref<Array<ICommissionReportFile>>([]);
        const decisionData = ref<ICommissionDecision>(new CommissionDecisionModel());
        const modifiedDecisionData = ref<ICommissionDecision>(new CommissionDecisionModel());

        const downloadReportFile = (id: number, name: string) => {
            const url = commissionReportService.reportFileDownloadUrl(
                id,
                props.item!.reportId!,
                props.item!.processId!
            );
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', name);
            document.body.appendChild(link);
            link.click();
        };

        const getSessionAgendaItemData = async () => {
            try {
                const processData = await processService.getProcess(props.item!.processId!);
                if (processData) {
                    process.value = processData;

                    if (processData.fundSystemIdentifier) {
                        const fund = await fundService.displayFund(processData.fundSystemIdentifier);
                        entityLinkText.value = t('funds.searchTemplate', {
                            descriptionLevel: fund.descriptionLevelText,
                            number: fund.number ?? fund.systemIdentifier,
                            title: fund.title,
                            chronologicalScope: fund.approxmateChronologicalScope,
                        });

                        entityLinkData.value = {
                            name: 'DisplayFund',
                            params: { id: fund.systemIdentifier },
                            query: {
                                hasExternalSource: String(fund.hasExternalSource),
                                externalIdentifier: fund.externalIdentifier,
                            },
                        };
                    } else if (processData.inventorySystemIdentifier) {
                        const inventory = await inventoryService.displayInventory(
                            processData.inventorySystemIdentifier
                        );
                        entityLinkText.value = t('inventories.searchTemplate', {
                            descriptionLevel: inventory.descriptionLevelText,
                            number: inventory.number ?? inventory.systemIdentifier,
                            chronologicalScope: inventory.approxmateChronologicalScope,
                        });

                        entityLinkData.value = {
                            name: 'DisplayInventory',
                            params: { id: inventory.systemIdentifier },
                            query: {
                                hasExternalSource: String(inventory.hasExternalSource),
                                externalIdentifier: inventory.externalIdentifier,
                            },
                        };
                    } else if (processData.archivalEntitySystemIdentifier) {
                        const archivalEntity = await archiveEntityService.displayArchivalEntity(
                            processData.archivalEntitySystemIdentifier
                        );
                        entityLinkText.value = t('archiveEntities.searchTemplate', {
                            descriptionLevel: archivalEntity.descriptionLevelText,
                            number: archivalEntity.number ?? archivalEntity.systemIdentifier,
                            title: archivalEntity.title,
                            chronologicalScope: archivalEntity.approximateChronologicalScope,
                        });

                        entityLinkData.value = {
                            name: 'DisplayArchivalEntity',
                            params: { id: archivalEntity.systemIdentifier },
                            query: {
                                hasExternalSource: String(archivalEntity.hasExternalSource),
                                externalIdentifier: archivalEntity.externalIdentifier,
                            },
                        };
                    } else if (processData.documentSystemIdentifier) {
                        const document = await documentService.displayDocument(processData.documentSystemIdentifier);
                        entityLinkText.value = t('documents.searchTemplate', {
                            descriptionLevel: document.descriptionLevelText,
                            title: document.title,
                            chronologicalScope: document.approximateChronologicalScope,
                        });

                        entityLinkData.value = {
                            name: 'DisplayDocument',
                            params: { id: document.systemIdentifier },
                            query: {
                                hasExternalSource: String(document.hasExternalSource),
                                externalIdentifier: document.externalIdentifier,
                            },
                        };
                    }
                }

                const itemReport = await commissionReportService.getById(props.item!.reportId!);
                if (itemReport) {
                    reportData.value = itemReport;

                    const fileData = await commissionReportService.getFiles(props.item!.reportId!);
                    if (fileData) {
                        reportFiles.value = fileData;
                    }
                }

                const itemDecision = await commissionDecisionService.getDecisionBySessionAgendaId(props.item!.id!);
                if (itemDecision) {
                    decisionData.value = itemDecision;
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnShowAgendaItemClickHandler = async (loadData: boolean) => {
            try {
                if (loadData) {
                    await getSessionAgendaItemData();
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnDeleteClickHandler = async (itemid: number) => {
            try {
                await sessionAgendaService.deleteSessionAgendaItem(itemid);

                context.emit('delete', itemid);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnSetDecisionClickHandler = async (itemId: number) => {
            try {
                const itemDecision = await commissionDecisionService.getDecisionBySessionAgendaId(itemId);
                if (itemDecision) {
                    modifiedDecisionData.value = itemDecision;
                } else {
                    modifiedDecisionData.value = new CommissionDecisionModel();
                    modifiedDecisionData.value.sessionAgendaId = itemId;
                }
                showDecisionDialog.value = true;
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnSubmitDecisionClickHandler = async () => {
            disabledSaveButton.value = true;
            try {
                if (modifiedDecisionData.value.id) {
                    await commissionDecisionService.updateDecision(modifiedDecisionData.value);
                } else {
                    await commissionDecisionService.createDecision(modifiedDecisionData.value);
                }

                showDecisionDialog.value = false;
                await getSessionAgendaItemData();
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                disabledSaveButton.value = false;
            }
        };

        const btnCancelClickHandler = () => {
            showDecisionDialog.value = false;
            modifiedDecisionData.value = new CommissionDecisionModel();
        };

        watch(
            () => isSelected.value,
            (val) => {
                context.emit('select', val, props.item?.id);
            }
        );

        return {
            t,
            isSelected,
            process,
            reportData,
            decisionData,
            modifiedDecisionData,
            disabledSaveButton,
            showDecisionDialog,
            entityLinkText,
            reportFiles,
            entityLinkData,
            formatDateTime,
            downloadReportFile,
            btnShowAgendaItemClickHandler,
            btnDeleteClickHandler,
            btnSetDecisionClickHandler,
            btnSubmitDecisionClickHandler,
            btnCancelClickHandler,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/dialog.scss';

.floatingBtnIcon {
    background-color: transparent !important;
    color: var(--ISDA-main-color1) !important;
    box-shadow: none !important;
    margin: 15px 0px;
}

.popper {
    margin-top: 0px !important;
}
</style>
