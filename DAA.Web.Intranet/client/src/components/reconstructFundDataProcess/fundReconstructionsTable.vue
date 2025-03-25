<template>
    <v-row v-if="!readOnly">
        <v-col class="col-12">
            <v-checkbox
                v-model="entityType" 
                :label="t('fundReconstructions.buttons.mergeInventory')" 
                :value="BusinessObjectType.inventory" 
                hide-details="auto"
            />
        </v-col>
        <v-col class="col-12 col-lg-5">
            <v-autocomplete 
                v-model="selectedSourceInventory"
                :label="t('fundReconstructions.columns.sourceInventory')" 
                :disabled="entityType !== BusinessObjectType.inventory" 
                hide-details="auto"
                :items="sourceInventories"
                item-title="calculatedTitle"
                item-value="systemIdentifier"
                clearable
            />
        </v-col>
        <v-col class="col-12 col-lg-5">
            <v-autocomplete 
                v-model="selectedTargetInventory"
                :label="t('fundReconstructions.columns.targetInventory')" 
                :disabled="entityType !== BusinessObjectType.inventory"
                hide-details="auto" 
                :items="targetInventories"
                item-title="calculatedTitle"
                item-value="systemIdentifier"
                clearable
            />
        </v-col>
        <v-col class="col-12 col-lg-2">
            <v-btn
                :disabled="entityType !== BusinessObjectType.inventory"
                @click="btnMergeInventoryClickHandler"
            >{{ 
                t('fundReconstructions.buttons.merge') 
            }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('fundReconstructions.buttons.mergeInventory')}}
                </v-tooltip>
            </v-btn>
        </v-col>
    </v-row>
    <v-row v-if="!readOnly">
        <v-col class="col-12">
            <v-checkbox
                v-model="entityType" 
                :label="t('fundReconstructions.buttons.mergeArchivalEntity')"
                :value="BusinessObjectType.archivalEntity" 
                hide-details="auto"
            />
        </v-col>
        <v-col class="col-12 col-lg-5">
            <v-autocomplete 
                v-model="selectedSourceArchivalEntity"
                :label="t('fundReconstructions.columns.sourceArchivalEntity')"
                :disabled="entityType !== BusinessObjectType.archivalEntity" 
                hide-details="auto"
                :items="sourceArchivalEntities"
                item-title="calculatedTitle"
                item-value="systemIdentifier"
                clearable
            />
        </v-col>
        <v-col class="col-12 col-lg-5">
            <v-autocomplete 
                v-model="selectedTargetArchivalEntity"
                :label="t('fundReconstructions.columns.targetArchivalEntity')"
                :disabled="entityType !== BusinessObjectType.archivalEntity" 
                hide-details="auto"
                :items="targetArchivalEntities"
                item-title="calculatedTitle"
                item-value="systemIdentifier"
                clearable
            />
        </v-col>
        <v-col class="col-12 col-lg-2">
            <v-btn
                :disabled="entityType !== BusinessObjectType.archivalEntity" 
                @click="btnMergeArchivalEntityClickHandler"
            >{{ 
                t('fundReconstructions.buttons.merge') 
            }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('fundReconstructions.buttons.mergeArchivalEntity')}}
                </v-tooltip>
            </v-btn>
        </v-col>
    </v-row>
    <v-row>
        <v-col>
            <grid
                ref="grid"
                :mode="'remote'"
                :baseUrl="gridUrl"
                :columns="columns"
                :paging="true"
                :pageSize="pageSize"
                :showSearch="false"
                :searchLabel="t('grid.search.tooltip')"
                :businessObjectType="objectType"
                :exportMode="exportMode"
            >
                <template v-slot:menubar>
                </template>
            </grid>
        </v-col>
    </v-row>
</template>
<script lang="ts">
import { computed, defineComponent, inject, PropType, Ref, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { trimText } from '@/helpers/format.helper';
import { useRedirectWithId } from '@/helpers/router.helper';

import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { IProcess } from '@/interfaces/process';
import { IFundReconstructionModel } from '@/interfaces/fundReconstruction';
import { BusinessObjectType, ExportMode, PageSize } from '@/models/grid';
import { AvailabilityStatus } from '@/enums/status';
import { ArchivalEntityShort } from '@/models/archivalEntity';
import { InventoryShort } from '@/models/inventory';
import { FundReconstructionModel } from '@/models/fundReconstructions';
import fundReconstructionService from '@/services/fundReconstruction.service';

import Grid from '@/components/grid/grid.vue';
import BtnsTemplate from '@/components/grid/btnsTemplate.vue';

export default defineComponent({
    name: 'FundReconstructionsTable',
    components: {
        Grid,
    },
    props: {
        process: {
            type: Object as PropType<IProcess>,
            required: true,
        },
        readOnly: {
            type: Boolean,
            default: false,
        },
    },
    setup(props, context) {
        console.log(props.process);
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const gridUrl = computed(() => fundReconstructionService.getReconstructionsByProcessUrl(props.process.id!));

        const entityType = ref<string>();

        const grid = ref();
        const pageSize = PageSize.fifty;
        const objectType = BusinessObjectType.fundReconstruction;
        const exportMode = ExportMode.all;

        const router = useRouter();

        const rowButtons = [
            {
                name: 'btnDeleteReconstruction',
                tooltip: t('fundReconstructions.buttons.deleteTooltip'),
                class: 'text-danger',
                icon: 'mdi mdi-delete',
                text: t('fundReconstructions.buttons.delete'),
                show: () => !props.readOnly,
                clickHandler: async (item: IFundReconstructionModel) => {
                    if (confirm(t('fundReconstructions.buttons.deleteConfirmation'))) {
                        try {
                            await fundReconstructionService.deleteFundReconstruction(props.process.id!, item.id!);
                            if (grid.value) {
                                grid.value.refreshData();
                            }
                            context.emit('delete');
                        } catch (error: unknown) {
                            const errorResult = error as ResponseResult;
                            message.value = new Message({
                                text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                                display: true,
                            });
                        }
                    }                   
                },
            },
            {
                name: 'btnDisplaySource',
                tooltip: t('fundReconstructions.buttons.displaySourceTooltip'),
                icon: 'mdi mdi-eye',
                text: t('fundReconstructions.buttons.displaySource'),
                show: true,
                clickHandler: async (item: IFundReconstructionModel) => {
                    if (item.sourceDocumentSystemIdentifier) {
                        useRedirectWithId(router, 'DisplayDocument', item.sourceDocumentSystemIdentifier);
                    } else if (item.sourceArchivalEntitySystemIdentifier) {
                        useRedirectWithId(router, 'DisplayArchiveEntity', item.sourceArchivalEntitySystemIdentifier);
                    } else if (item.sourceInventorySystemIdentifier) {
                        useRedirectWithId(router, 'DisplayInventory', item.sourceInventorySystemIdentifier);
                    }
                },
            },
            {
                name: 'btnDisplayTarget',
                tooltip: t('fundReconstructions.buttons.displayTargetTooltip'),
                icon: 'mdi mdi-eye',
                text: t('fundReconstructions.buttons.displayTarget'),
                show: true,
                clickHandler: async (item: IFundReconstructionModel) => {
                    if (item.targetDocumentSystemIdentifier) {
                        useRedirectWithId(router, 'DisplayDocument', item.targetDocumentSystemIdentifier);
                    } else if (item.targetArchivalEntitySystemIdentifier) {
                        useRedirectWithId(router, 'DisplayArchiveEntity', item.targetArchivalEntitySystemIdentifier);
                    } else if (item.targetInventorySystemIdentifier) {
                        useRedirectWithId(router, 'DisplayInventory', item.targetInventorySystemIdentifier);
                    }               
                },
            },
        ];

        const columns = [
            {
                prop: '',
                type: 'vue',
                template: (e: ObjectConstructor) => {
                    return {
                        template: BtnsTemplate,
                        templateArgs: {
                            ...e,
                            btns: rowButtons,
                            showAsDropdown: true,
                        },
                    };
                },
                sortable: false,
                filterable: false,
            },
            {
                title: t('documents.columns.availabilityStatus'),
                prop: 'availabilityStatusText',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            // {
            //     title: t('fundReconstructions.columns.archive'),
            //     prop: 'archiveName',
            //     type: 'string',
            //     sortable: true,
            //     filterable: true,
            // },
            // {
            //     title: t('fundReconstructions.columns.fund'),
            //     prop: 'fundNumber',
            //     type: 'string',
            //     sortable: true,
            //     filterable: true,
            // },
            {
                title: t('fundReconstructions.columns.sourceInventory'),
                prop: 'sourceInventoryNumber',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            {
                title: t('fundReconstructions.columns.sourceInventorySystemIdentifier'),
                prop: 'sourceInventorySystemIdentifier',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            {
                title: t('fundReconstructions.columns.sourceArchivalEntity'),
                prop: 'sourceArchivalEntityNumber',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            {
                title: t('fundReconstructions.columns.sourceArchivalEntitySystemIdentifier'),
                prop: 'sourceArchivalEntitySystemIdentifier',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            {
                title: t('fundReconstructions.columns.sourceDocument'),
                prop: 'sourceDocumentTitle',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            
            {
                title: t('fundReconstructions.columns.sourceDocumentSystemIdentifier'),
                prop: 'sourceDocumentSystemIdentifier',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            {
                title: t('fundReconstructions.columns.targetInventory'),
                prop: 'targetInventoryNumber',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            {
                title: t('fundReconstructions.columns.targetInventorySystemIdentifier'),
                prop: 'targetInventorySystemIdentifier',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            {
                title: t('fundReconstructions.columns.targetArchivalEntity'),
                prop: 'targetArchivalEntityNumber',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            {
                title: t('fundReconstructions.columns.targetArchivalEntitySystemIdentifier'),
                prop: 'targetArchivalEntitySystemIdentifier',
                type: 'string',
                sortable: true,
                filterable: false,
            },
            // {
            //     title: t('fundReconstructions.columns.targetDocument'),
            //     prop: 'targetDocumentTitle',
            //     type: 'string',
            //     sortable: true,
            //     filterable: false,
            // },
            
            // {
            //     title: t('fundReconstructions.columns.targetDocumentSystemIdentifier'),
            //     prop: 'targetDocumentSystemIdentifier',
            //     type: 'string',
            //     sortable: true,
            //     filterable: false,
            // },
        ];

        const selectedSourceArchivalEntity = ref<string>();
        const selectedTargetArchivalEntity = ref<string>();
        const selectedSourceInventory = ref<string>();
        const selectedTargetInventory = ref<string>();

        const sourceArchivalEntities = ref<Array<ArchivalEntityShort>>([]);
        const targetArchivalEntities = ref<Array<ArchivalEntityShort>>([]);
        const sourceInventories = ref<Array<InventoryShort>>([]);
        const targetInventories = ref<Array<InventoryShort>>([]);

        const getSourceArchivalEntities = async () => {
            try {
                const archivalEntities = await fundReconstructionService.getReconstructionArchivalEntities(props.process!.id!);
                archivalEntities
                    .forEach(ae => ae.calculatedTitle = t('archiveEntities.searchTemplate', {
                            descriptionLevel: ae.descriptionLevelText,
                            number: ae.number,
                            title: trimText(ae.title, 100),
                            chronologicalScope: ae.approximateChronologicalScope,
                    }));

                sourceArchivalEntities.value = archivalEntities; 

            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const getTargetArchivalEntities = async () => {
            try {
                const archivalEntities = await fundReconstructionService.getReconstructionArchivalEntities(props.process!.id!, true);
                archivalEntities
                    .forEach(ae => ae.calculatedTitle = t('archiveEntities.searchTemplate', 
                        {
                            descriptionLevel: ae.descriptionLevelText,
                            number: ae.number,
                            title: trimText(ae.title, 100),
                            chronologicalScope: ae.approximateChronologicalScope,
                        }));

                targetArchivalEntities.value = archivalEntities;

            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };
        
        const getSourceInventories = async () => {
            try {
                const inventories = await fundReconstructionService.getReconstructionInventories(props.process!.id!);
                inventories
                    .forEach(inv => inv.calculatedTitle = t('inventories.searchTemplate', 
                        {
                            descriptionLevel: inv.descriptionLevelText,
                            number: inv.number,
                            chronologicalScope: inv.approxmateChronologicalScope,
                        }));
                
                sourceInventories.value = inventories;
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const getTargetInventories = async () => {
            try {
                const inventories = await fundReconstructionService.getReconstructionInventories(props.process!.id!, true);
                inventories
                    .forEach(inv => inv.calculatedTitle = t('inventories.searchTemplate', 
                        {
                            descriptionLevel: inv.descriptionLevelText,
                            number: inv.number,
                            chronologicalScope: inv.approxmateChronologicalScope,
                        }));
                
                targetInventories.value = inventories;
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnMergeInventoryClickHandler =async () => {
            try {
                console.log(selectedSourceInventory.value, selectedTargetInventory.value);

                if (!selectedSourceInventory.value || !selectedTargetInventory.value) {
                    message.value = new Message({
                        type: "warning",
                        text: t('warnings.noSelectedInventories'),
                        display: true,
                    });
                } else {
                    const reconstruction = 
                        new FundReconstructionModel({
                            availabilityStatusCode: AvailabilityStatus.RelocationDeduction,
                            processId: props.process?.id,
                            archiveId: props.process?.archiveId,
                            fundSystemIdentifier: props.process?.fundSystemIdentifier,
                            sourceInventorySystemIdentifier: selectedSourceInventory.value,
                            targetInventorySystemIdentifier: selectedTargetInventory.value,
                    });
                    
                    await fundReconstructionService.updateMergeFundReconstructionByTarget(reconstruction);

                    if (grid.value) {
                        grid.value.refreshData();
                    }

                    selectedSourceInventory.value = undefined;
                    selectedTargetInventory.value = undefined;
                    
                    await getSourceInventories();
                    await getTargetInventories();

                    context.emit('merge', reconstruction);
                    
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const btnMergeArchivalEntityClickHandler = async () => {
            try {
                console.log(selectedSourceArchivalEntity.value, selectedTargetArchivalEntity.value);

                if (!selectedSourceArchivalEntity.value || !selectedTargetArchivalEntity.value) {
                    message.value = new Message({
                        type: "warning",
                        text: t('warnings.noSelectedArchivalEntities'),
                        display: true,
                    });
                } else {
                    
                    console.log(selectedSourceArchivalEntity.value, selectedTargetArchivalEntity.value);
                    const reconstruction = 
                        new FundReconstructionModel({
                            availabilityStatusCode: AvailabilityStatus.RelocationDeduction,
                            processId: props.process?.id,
                            archiveId: props.process?.archiveId,
                            fundSystemIdentifier: props.process?.fundSystemIdentifier,
                            sourceInventorySystemIdentifier: sourceArchivalEntities.value.find(ae => ae.systemIdentifier === selectedSourceArchivalEntity.value)?.inventorySystemIdentifier,
                            sourceArchivalEntitySystemIdentifier: selectedSourceArchivalEntity.value,
                            targetInventorySystemIdentifier: targetArchivalEntities.value.find(ae => ae.systemIdentifier === selectedTargetArchivalEntity.value)?.inventorySystemIdentifier,
                            targetArchivalEntitySystemIdentifier: selectedTargetArchivalEntity.value,
                    });
                    
                    await fundReconstructionService.updateMergeFundReconstructionByTarget(reconstruction);
                    
                    if (grid.value) {
                        grid.value.refreshData();
                    }

                    selectedSourceArchivalEntity.value = undefined;
                    selectedTargetArchivalEntity.value = undefined;

                    await getSourceArchivalEntities();
                    await getTargetArchivalEntities();

                    context.emit('merge', reconstruction);
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        watch(
            () => entityType.value,
            async (val?: string) => {
                console.log('entityType', val);
                switch(val) {
                    case BusinessObjectType.inventory:
                        await getSourceInventories();
                        await getTargetInventories();
                        break;
                    case BusinessObjectType.archivalEntity:
                        await getSourceArchivalEntities();
                        await getTargetArchivalEntities();
                        break;
                    default:
                        break;
                }
            }
        );

        return {
            t,
            BusinessObjectType,
            columns,
            pageSize,
            objectType,
            exportMode,
            grid,
            gridUrl,
            entityType,
            sourceArchivalEntities,
            targetArchivalEntities,
            sourceInventories,
            targetInventories,
            selectedSourceArchivalEntity,
            selectedTargetArchivalEntity,
            selectedSourceInventory,
            selectedTargetInventory,
            btnMergeArchivalEntityClickHandler,
            btnMergeInventoryClickHandler,
        };
    },
})
</script>
