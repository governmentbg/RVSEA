<template>
    <v-row>
        <v-col>
            <slot name="toolbar" v-if="addEnabled || addFromPackageEnabled">
                <v-toolbar color="transparent">
                    <v-btn color="primary" variant="elevated" @click="goAddArchivalEntity" v-if="addEnabled">
                        {{ t('archiveEntities.create') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('archiveEntities.buttons.createTooltip') }}
                        </v-tooltip>
                    </v-btn>
                    <v-btn
                        color="primary"
                        variant="elevated"
                        @click="goAddArchivalEntityFromPackage"
                        v-if="addFromPackageEnabled"
                    >
                        {{ t('archiveEntities.createFromPackage') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('archiveEntities.buttons.createFromPackageTooltip') }}
                        </v-tooltip>
                    </v-btn>
                    <v-btn
                        color="primary"
                        variant="elevated"
                        @click="goMarkInvaluableFiles"
                        v-if="addFromPackageEnabled && filesFromPackage && filesFromPackage.length > 0"
                    >
                        {{
                            hasInvaluableFiles == true
                                ? t('archiveEntities.unmarkAsInvaluable')
                                : t('archiveEntities.markAsInvaluable')
                        }}
                        <v-tooltip activator="parent" location="bottom">
                            {{
                                hasInvaluableFiles == true
                                    ? t('archiveEntities.buttons.unmarkInvaluableTooltip')
                                    : t('archiveEntities.buttons.markInvaluableTooltip')
                            }}
                        </v-tooltip>
                    </v-btn>
                    <FileUpload
                        v-if="addFromPackageEnabled"
                        ref="fileUploader"
                        :multipleFiles="false"
                        :label="$t('archiveEntities.buttons.importFile')"
                        icon="mdi-paperclip"
                        @change="goImportFile"
                    />
                    <Loader :isLoading="isLoading" />
                </v-toolbar>
            </slot>
        </v-col>
    </v-row>
    <v-row align="center" v-if="searchEnabled">
        <v-col class="col-12 col-md-6 col-lg-4">
            <text-field
                onkeypress="return event.charCode >= 48"
                :label="t('archiveEntities.columns.number')"
                v-model="searchNumber"
                validation="numeric"
            />
        </v-col>
        <v-col class="col-12 col-md-6 col-lg-4">
            <text-field :label="t('archiveEntities.keyWords')" v-model="searchKeyword" />
        </v-col>
        <v-col class="col-12 col-lg-4 d-flex gap-2 justify-content-start">
            <submit-btn @click="searchArchivalEntities"
                >{{ t('common.search') }}
                <v-tooltip activator="parent" location="bottom">
                    {{ t('common.searchTooltip') }}
                </v-tooltip>
            </submit-btn>
            <cancel-btn @click="clearAllSearchCriteria"
                >{{ t('common.clear') }}
                <v-tooltip activator="parent" location="bottom">
                    {{ t('common.clearTooltip') }}
                </v-tooltip>
            </cancel-btn>
        </v-col>
    </v-row>
    <v-row v-if="archivalEntityData.totalCount > 0">
        <v-col>
            <v-list lines="two">
                <v-list-item
                    lines="two"
                    v-for="item in archivalEntityData.items"
                    :key="item"
                    :to="{
                        name: 'DisplayArchiveEntity',
                        params: { id: item.systemIdentifier },
                        query: {
                            hasExternalSource: item.hasExternalSource,
                            externalIdentifier: item.externalIdentifier,
                        },
                    }"
                >
                    <template #prepend>
                        <v-checkbox
                            @click.stop
                            v-if="selectionEnabled"
                            v-model="selectedItems"
                            :value="item.systemIdentifier"
                            hide-details="auto"
                            :disabled="
                                readOnly ||
                                selectionConditions === false ||
                                (typeof selectionConditions === 'function' && !selectionConditions(item))
                            "
                        />

                        <button
                            v-if="deleteEnabled"
                            type="button"
                            class="icon-btn"
                            @click.prevent="onDeleteArchivalEntity(item.id!, item.title!)"
                        >
                            <i class="fas fa-trash-alt"></i>
                        </button>
                    </template>

                    <v-list-item-title
                        >{{
                            t('archiveEntities.searchTemplate', {
                                descriptionLevel: item.descriptionLevelText,
                                number: item.number,
                                title: trimText(item.title, 100),
                                chronologicalScope: formatApproximateChronologicalScope(item.approximateChronologicalScope),
                            })
                        }}
                        <span v-if="item.isInProcess">
                            <v-icon>mdi-progress-check</v-icon
                            ><v-tooltip activator="parent" location="bottom">{{
                                t('films.columns.process')
                            }}</v-tooltip>
                        </span></v-list-item-title
                    >
                    <v-list-item-subtitle>{{ item.statusText }}{{item.hasDigitizedDigitalObjects === true ? ' / ' + t('archiveEntities.activeDigitalObjectYes') : ' / ' + t('archiveEntities.activeDigitalObjectNo')}}</v-list-item-subtitle>
                </v-list-item>
            </v-list>
        </v-col>
    </v-row>
    <v-row v-else>
        <v-col>
            {{ t('search.emptyResult') }}
        </v-col>
    </v-row>
    <v-row v-if="archivalEntityData.totalCount > pagerOptions.itemsPerPage">
        <v-col>
            <Pager
                :initialPage="pagerOptions.page"
                :initialPageSize="pagerOptions.itemsPerPage"
                :totalPages="pagerOptions.totalPages"
                @change="changePage"
                ref="pager"
            ></Pager>
        </v-col>
    </v-row>
    <slot name="actions"></slot>
    <v-dialog v-model="dialogIsVisible" persistent width="60%">
        <v-card>
            <v-card-title>{{ t('archiveEntities.modal.title') }}</v-card-title>
            <v-card-text>
                <v-row
                    v-if="
                        filesFromPackage.length > 0 &&
                        filesFromPackage.filter((x) => x.isInvaluable === false).length > 0
                    "
                >
                    <v-col>
                        <v-list>
                            <v-list-item
                                v-for="item in filesFromPackage.filter((x) => x.isInvaluable === false)"
                                :key="item.id"
                            >
                                <template #prepend>
                                    <v-checkbox v-model="selectedFiles" :value="item.id" hide-details="auto" />
                                </template>

                                <v-list-item-title>{{ item.fileName }}</v-list-item-title>
                            </v-list-item>
                        </v-list>
                    </v-col>
                </v-row>
                <v-row v-else>
                    <v-col>
                        {{ t('archiveEntities.modal.noFiles') }}
                    </v-col>
                </v-row>
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <DialogBtn
                    @click="submitDialog"
                    :disabled="
                        submitDialogDisabled ||
                        !filesFromPackage ||
                        filesFromPackage.length == 0 ||
                        filesFromPackage.filter((x) => x.isInvaluable === false).length == 0
                    "
                >
                    {{ t('common.save') }}
                </DialogBtn>
                <CancelBtn @click="cancelDialog">
                    {{ t('common.cancel') }}
                </CancelBtn>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>
<script lang="ts">
import { computed, defineComponent, inject, onMounted, PropType, Ref, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { LocationQueryRaw, useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import { trimText, formatApproximateChronologicalScope } from '@/helpers/format.helper';
import { Message } from '@/models/notification';

import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
//import { ProcessType } from '@/enums/process';
import { PageSize, GridResponseModel, GridOptions } from '@/models/grid';
import { IInventory } from '@/interfaces/inventory';
import { IArchivalEntity } from '@/interfaces/archivalEntity';
//import { IProcess } from '@/interfaces/process';
import archiveEntityService from '@/services/archivalEntity.service';
import packagesService from '@/services/packages.service';
import importService from '@/services/import.service';
import processRawService from '@/services/processRawInventoriesProcess.service';
import { defaultGuidString } from '@/helpers/format.helper';
import { IPackageBFile } from '@/models/packages';

import TextField from '@/components/field/text.field.vue';
import Pager from '@/components/grid/pager.vue';
import FileUpload from '@/components/files/uploadFile.vue';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'InventoryArchivalEntities',
    components: {
        TextField,
        Pager,
        FileUpload,
        Loader,
    },
    props: {
        inventory: {
            type: Object as PropType<IInventory>,
            required: true,
        },
        addEnabled: {
            type: Boolean,
            default: false,
        },
        searchEnabled: {
            type: Boolean,
            default: false,
        },
        selectionEnabled: {
            type: Boolean,
            default: false,
        },
        modelValue: {
            type: Array as PropType<string[]>,
            default: () => [],
        },
        selectionConditions: {
            //type: [Boolean, Function] as PropType<boolean | ((value?: IArchivalEntity) => boolean)>,
            type: [Boolean, Function],
            default: false,
        },
        readOnly: {
            type: Boolean,
            default: false,
        },
        addFromPackageEnabled: {
            type: Boolean,
            default: false,
        },
        deleteEnabled: {
            type: Boolean,
            default: false,
        },
    },
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const selectedItems = computed({
            get: () => props.modelValue,
            set: (value) => context.emit('update:modelValue', value),
        });
        const isLoading = ref(false);

        const hasInvaluableFiles = computed(() => {
            return filesFromPackage.value && filesFromPackage.value.filter((x) => x.isInvaluable === true).length > 0;
        });

        const router = useRouter();

        const goAddArchivalEntity = () => {
            const routeQuery: LocationQueryRaw = {
                inventorySystemIdentifier: props.inventory?.systemIdentifier,
                inventoryHasExternalSource: String(props.inventory?.hasExternalSource),
                inventoryExternalIdentifier: props.inventory?.externalIdentifier,
            };

            useRedirect(router, 'CreateArchiveEntity', undefined, routeQuery);
        };

        const onDeleteArchivalEntity = async (id: number, title: string) => {
            try {
                if (confirm(t('archiveEntities.buttons.deleteConfirmation', { title }))) {
                    isLoading.value = true;

                    const result = await processRawService.deleteArchivalEntityDraft(id);

                    isLoading.value = false;
                    if (result.status == 200) {
                        await getInventoryArchivalEntityData();
                        await getPackageFiles();
                    } else {
                        message.value = new Message({
                            text: result.response.data.message,
                            display: true,
                        });
                    }
                }
            } catch (error: unknown) {
                isLoading.value = false;
                message.value = new Message({
                    text: (error as ResponseResult)?.message,
                    display: true,
                });
            }
        };

        const goImportFile = async (model: File[]) => {
            if (!model || model.length == 0) {
                console.log('No import file selected');
                return;
            }
            if (!confirm(t('inventories.importFileConfirmation'))) {
                return;
            }

            isLoading.value = true;
            try {
                const response = await importService.importFile(
                    props.inventory?.systemIdentifier || defaultGuidString(),
                    model[0]
                );
                isLoading.value = false;
                console.log(response.data);
                await getInventoryArchivalEntityData();
                await getPackageFiles();
            } catch (error: unknown) {
                isLoading.value = false;
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const dialogIsVisible = ref(false);
        const filesFromPackage = ref<Array<IPackageBFile>>([]);
        const selectedFiles = ref<Array<number>>([]);
        const goAddArchivalEntityFromPackage = async () => {
            dialogIsVisible.value = !dialogIsVisible.value;
            await getPackageFiles();
        };

        const goMarkInvaluableFiles = async () => {
            try {
                isLoading.value = true;

                const result = await processRawService.markInvaluableFiles(
                    props.inventory?.systemIdentifier || defaultGuidString()
                );

                isLoading.value = false;
                if (result.status == 200) {
                    await getPackageFiles();
                } else {
                    message.value = new Message({
                        text: result.response.data.message,
                        display: true,
                    });
                }
            } catch (error: unknown) {
                isLoading.value = false;
                message.value = new Message({
                    text: (error as ResponseResult)?.message,
                    display: true,
                });
            }
        };

        const submitDialogDisabled = ref(false);

        const submitDialog = async () => {
            if (!selectedFiles.value || selectedFiles.value.length == 0) {
                alert(t('archiveEntities.modal.noFilesSelected'));
                dialogIsVisible.value = false;
                return;
            }

            submitDialogDisabled.value = true;

            isLoading.value = true;
            try {
                await archiveEntityService.archivalEntityFromPackage(
                    props.inventory?.systemIdentifier || defaultGuidString(),
                    selectedFiles.value
                );
                selectedFiles.value = [];
                isLoading.value = false;

            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }

            dialogIsVisible.value = false;
            submitDialogDisabled.value = false;
            await getInventoryArchivalEntityData();
            await getPackageFiles();
        };

        const cancelDialog = () => {
            console.log('cancelDialog');
            dialogIsVisible.value = false;
        };

        const getPackageFiles = async () => {
            const result = await packagesService.getAvailableDocsForAE(
                props.inventory?.systemIdentifier || defaultGuidString(),
                props.inventory?.packageBId || 0
            );

            if (result) {
                filesFromPackage.value = result;
            }

            console.log('files:');
            console.log(filesFromPackage.value);
        };

        const pagerOptions = ref<GridOptions>({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: PageSize.twenty,
            sortByType: '',
            totalPages: 1
        });

        const initPagerOptions = () => {
            pagerOptions.value = new GridOptions({
                sortBy: '',
                sortDesc: false,
                page: 1,
                itemsPerPage: PageSize.twenty,
                sortByType: '',
                searchString: '',
                totalPages: 1,
            });
        };

        const changePage = async (pageNumber: number, pageSize: number) => {
            pagerOptions.value.page = pageNumber;
            pagerOptions.value.itemsPerPage = pageSize;

            await getInventoryArchivalEntityData();
        };

        const archivalEntityData = ref<GridResponseModel<IArchivalEntity>>(
            new GridResponseModel<IArchivalEntity>({ totalCount: 0, items: [] })
        );

        const getInventoryArchivalEntityData = async (keywords?: string, number?: string) => {
            try {
                if (keywords || number) {
                    initPagerOptions();
                }
                if (keywords) {
                    pagerOptions.value.searchString = keywords;
                }
                const result = await archiveEntityService.getInventoryArchivalEntities(
                    pagerOptions.value,
                    props.inventory?.systemIdentifier,
                    props.inventory?.hasExternalSource,
                    props.inventory?.externalIdentifier,
                    number
                );
                if (result) {
                    archivalEntityData.value = result;
                    pagerOptions.value.totalPages = archivalEntityData.value.totalCount < pagerOptions.value.itemsPerPage
                        ? 1
                        : Math.ceil(archivalEntityData.value.totalCount / pagerOptions.value.itemsPerPage)
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const searchKeyword = ref('');
        const searchNumber = ref('');

        const searchArchivalEntities = async () => {
            await getInventoryArchivalEntityData(searchKeyword.value, searchNumber.value);
        };

        const clearAllSearchCriteria = async () => {
            searchKeyword.value = '';
            searchNumber.value = '';
            initPagerOptions();
            await getInventoryArchivalEntityData();
        };

        onMounted(async () => {
            await getInventoryArchivalEntityData();
            await getPackageFiles();
        });

        return {
            t,
            selectedItems,
            archivalEntityData,
            searchKeyword,
            searchNumber,
            pagerOptions,
            trimText,
            changePage,
            searchArchivalEntities,
            clearAllSearchCriteria,
            goAddArchivalEntity,
            goAddArchivalEntityFromPackage,
            dialogIsVisible,
            submitDialog,
            cancelDialog,
            filesFromPackage,
            selectedFiles,
            submitDialogDisabled,
            goImportFile,
            isLoading,
            onDeleteArchivalEntity,
            goMarkInvaluableFiles,
            hasInvaluableFiles,
            formatApproximateChronologicalScope,
        };
    },
});
</script>
