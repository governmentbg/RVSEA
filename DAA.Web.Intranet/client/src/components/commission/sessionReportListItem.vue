<template>
    <v-list-group 
        v-if="item"
        collapse-icon=""
        expand-icon=""
    >
        <template v-slot:activator="{ props }">
            <v-list-item>
                <v-list-item-title>{{ t('sessionAgenda.columns.reportNumber') }} {{ item.number }}</v-list-item-title>
                <v-list-item-title>{{ item.processTypeTitle }}</v-list-item-title>
                <v-list-item-subtitle>
                    {{ t('sessionAgenda.columns.reportCreatedBy') }} {{ item.createdByDisplayName }}
                </v-list-item-subtitle>
                <template v-slot:append="{ isActive }">
                    <v-btn class="sessionAgendaItemIcons" flat icon v-bind="props" @click="btnShowContentClickHandler(!isActive)">
                        <v-icon>mdi-eye</v-icon>
                        <v-tooltip
                            activator="parent"
                            location="bottom"
                        >
                        {{t('common.showOrHide')}}
                        </v-tooltip>
                    </v-btn>
                    <!-- <v-checkbox-btn
                        v-model="bool"
                        @change="changeSelectedItems(bool, report.processId)"
                        color="orange-darken-3"
                        hide-details
                    ></v-checkbox-btn> -->
                    <v-btn 
                        v-if="!readOnly && showAddButton" 
                        class="sessionAgendaItemIcons" 
                        flat 
                        icon 
                        @click="btnAddToSessionAgendaClickHandler"
                    >
                        <v-icon>mdi-playlist-plus</v-icon>
                        <v-tooltip
                            activator="parent"
                            location="bottom"
                        >
                        {{t('common.add')}}
                        </v-tooltip>
                    </v-btn>
                </template>
            </v-list-item>
        </template>
        <v-list-item>
            <div class="mb-2">
                <hyper-link :title="entityLinkText" :to="entityLinkData" target="_blank" />
            </div>
            <textarea-field 
                :label="t('sessionAgenda.columns.reportContent')" 
                :modelValue="item.content" 
                :readonly="true" 
            />
            <v-list v-if="reportFiles && reportFiles.length > 0" density="compact">
                <v-list-subheader>{{ $t('epkReport.files') }}</v-list-subheader>
                <v-list-item
                    density="compact"
                    v-for="file in reportFiles"
                    :key="file.id"
                    :value="file.id"
                    :title="file.sourceName"
                >
                    <template #append>
                        <v-btn class="sessionAgendaItemIcons" icon="mdi-download" @click="downloadFile(file.id, file.sourceName)" >
                        <v-tooltip
                            activator="parent"
                            location="bottom"
                        >
                        {{t('common.download')}}
                        </v-tooltip>
                        </v-btn>
                    </template>
                </v-list-item>
            </v-list>
        </v-list-item>
    </v-list-group>
</template>
<script lang="ts">
import { defineComponent, inject, PropType, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { formatDateTime } from '@/helpers/format.helper';
import { RouteLocationRaw } from 'vue-router';

import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { CommissionReportModel, SessionAgendaItem } from '@/models/commission';
import { ICommissionReportFile } from '@/interfaces/commission';

import inventoryService from '@/services/inventory.service';
import archiveEntityService from '@/services/archivalEntity.service';
import documentService from '@/services/document.service';
import commissionReportService from '@/services/commissionReport.service';
import sessionAgendaService from '@/services/sessionAgenda.service';

import processService from '@/services/process.service';
import fundService from '@/services/fund.service';

import TextareaField from '@/components/field/textarea.field.vue';
import HyperLink from '@/components/hyperlink/hyperlink.vue';

export default defineComponent({
    name: 'SessionReportListItem',
    components: {
        TextareaField,
        HyperLink,
    },
    props: {
        sessionId: {
            type: Number,
        },
        item: {
            type: Object as PropType<CommissionReportModel>,
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
    emits: ['add'],
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const entityLinkText = ref<string>('');
        const entityLinkData = ref<RouteLocationRaw>();

        const reportFiles = ref<Array<ICommissionReportFile>>([]);

        const getReportItemData = async () => {
            try {
                const processData = await processService.getProcess(props.item!.processId!);
                
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
                    const inventory = await inventoryService.displayInventory(processData.inventorySystemIdentifier);
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

                const fileData = await commissionReportService.getFiles(props.item!.id!);
                if (fileData) {
                    reportFiles.value = fileData;
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const downloadFile = (id: number, name: string) => {
            const url = commissionReportService.reportFileDownloadUrl(
                id,
                props.item!.id!,
                props.item!.processId!
            );
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', name);
            document.body.appendChild(link);
            link.click();
        };

        const btnShowContentClickHandler = async (loadData: boolean) => {
            try {
                console.log('loaddata', loadData);
                if (loadData) {
                    await getReportItemData();
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnAddToSessionAgendaClickHandler = async () => {
            try {
                const sessionAgendaItem = new SessionAgendaItem({
                    sessionId: props.sessionId,
                    reportId: props.item!.id,
                    processId: props.item!.processId
                });
                await sessionAgendaService.createSessionAgendaItem(sessionAgendaItem);
                
                context.emit('add', sessionAgendaItem);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };


        return {
            t,

            entityLinkText,
            entityLinkData,
            reportFiles,
            downloadFile,
            formatDateTime,
            btnShowContentClickHandler,
            btnAddToSessionAgendaClickHandler,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/dialog.scss';

.sessionAgendaItemIcons {
    background-color: transparent !important;
    color: var(--ISDA-main-color1) !important;
    box-shadow: none !important;
    margin: 15px 0px;
}

</style>
