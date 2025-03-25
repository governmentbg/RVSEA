<template>
    <v-row>
        <v-col>
            <slot name="toolbar">
                <v-toolbar density="compact" color="transparent" v-if="addEnabled">
                    <li v-for="item in fundInventoryDescLevels" :key="item.code">
                        <v-btn variant="flat" class="me-3" @click="goAddInventory(item.code)">
                            {{ item.label }}
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('inventories.buttons.createFundInventoryTooltip', { title: item.label }) }}
                            </v-tooltip>
                        </v-btn>
                    </li>
                </v-toolbar>
            </slot>
        </v-col>
    </v-row>
    <v-row v-if="inventoryData && inventoryData.totalCount > 0">
        <v-col>
            <v-list lines="two">
                <v-list-item
                    lines="two"
                    v-for="item in inventoryData.items"
                    :key="item"
                    :to="{
                        name: 'DisplayInventory',
                        params: { id: item.systemIdentifier },
                        query: {
                            hasExternalSource: item.hasExternalSource,
                            externalIdentifier: item.externalIdentifier,
                        },
                    }"
                >
                    <template #prepend v-if="selectionEnabled && !disabled(item)">
                        <v-checkbox
                            @click.stop
                            v-model="selectedItems"
                            :value="item.systemIdentifier"
                            hide-details="auto"
                            :disabled="disabled(item)"
                        />
                    </template>
                    <v-list-item-title>
                        {{
                            t('inventories.searchTemplate', {
                                descriptionLevel: item.descriptionLevelText,
                                number: item.number,
                                chronologicalScope: item.approxmateChronologicalScope,
                            })
                        }}
                        <span v-if="item.isInProcess">
                            <v-icon>mdi-progress-check</v-icon
                            ><v-tooltip activator="parent" location="bottom">{{
                                t('films.columns.process')
                            }}</v-tooltip>
                        </span>
                    </v-list-item-title>
                    <v-list-item-subtitle>{{ item.statusText }}</v-list-item-subtitle>
                </v-list-item>
            </v-list>
        </v-col>
    </v-row>
    <v-row v-else>
        <v-col>
            {{ t('search.emptyResult') }}
        </v-col>
    </v-row>
    <v-row v-if="inventoryData && inventoryData.totalCount > pagerOptions.itemsPerPage">
        <v-col>
            <Pager
                :totalPages="totalPages"
                :initialPage="pagerOptions.pageNumber"
                :initialPageSize="pagerOptions.itemsPerPage"
                @change="changePage"
                ref="pager"
            ></Pager>
        </v-col>
    </v-row>
    <slot name="actions"> </slot>
</template>

<script lang="ts">
import { defineComponent, computed, PropType, ref, inject, Ref, onMounted, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { LocationQueryRaw, useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';

import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { FundDescriptionLevel } from '@/enums/fund';
import { InventoryDescriptionLevel } from '@/enums/inventory';
import { GridOptions, GridResponseModel, PageSize } from '@/models/grid';
import { IInventory } from '@/interfaces/inventory';
import { IFund } from '@/interfaces/fund';
import inventoryService from '@/services/inventory.service';

import Pager from '@/components/grid/pager.vue';
import { IDropdownOption } from '@/interfaces/dropdown';
import dropdownService from '@/services/dropdown.service';

export default defineComponent({
    name: 'FundInventories',
    components: {
        Pager,
    },
    props: {
        fund: {
            type: Object as PropType<IFund>,
            required: true,
        },
        addEnabled: {
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
            type: [Boolean, Function],
            default: false,
        },
        readOnly: {
            type: Boolean,
            default: false,
        },
        displayRouteName: {
            type: String,
            default: 'DisplayInventory',
        },
    },
    emits: ['update:modelValue', 'select'],
    setup(props, context) {
        const { t } = useI18n();
        const router = useRouter();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const fundSysId = computed(() => props.fund.systemIdentifier);
        const fundExternalId = computed(() => props.fund.externalIdentifier);
        const itemCount = computed(() => inventoryData.value.totalCount);

        const selectedItems = computed({
            get: () => props.modelValue,
            set: (value) => context.emit('update:modelValue', value),
        });

        const goAddInventory = (descLevel: string) => {
            const routeQuery: LocationQueryRaw = {
                fundSystemIdentifier: props.fund.systemIdentifier,
                fundHasExternalSource: String(props.fund.hasExternalSource),
                fundExternalIdentifier: props.fund.externalIdentifier,
                descriptionLevel: descLevel,
            };

            useRedirect(router, 'CreateInventory', undefined, routeQuery);
        };

        const fundInventoryDescLevels = ref<IDropdownOption[]>([]);
        const getFundInventoryDescLevels = async () => {
            try {
                fundInventoryDescLevels.value = await dropdownService.getInventoryDescriptionLevels(
                    props.fund.descriptionLevelCode
                );
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const inventoryTypes = [
            {
                id: InventoryDescriptionLevel.inventory,
                text: 'Пореден опис',
            },
            {
                id: InventoryDescriptionLevel.rawInventory,
                text: 'Груб опис',
            },
        ];
        const disabled = (val: IInventory) => {
            const result =
                props.readOnly ||
                props.selectionConditions === false ||
                (typeof props.selectionConditions === 'function' && (!props.selectionConditions(val) as unknown));
            return result;
        };
        const fundDescriptionLevel = FundDescriptionLevel;
        const inventoryDescriptionLevel = InventoryDescriptionLevel;

        const currentInventoryTypes = computed(() => {
            let types = inventoryTypes;

            if (props.fund.descriptionLevelCode === fundDescriptionLevel.rawFund) {
                types = types.filter((x) => x.id !== inventoryDescriptionLevel.inventory);
            }

            return types;
        });

        const inventoryData = ref<GridResponseModel<IInventory>>(
            new GridResponseModel<IInventory>({ totalCount: 0, items: [] })
        );

        const pagerOptions = ref<GridOptions>({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: PageSize.ten,
            sortByType: '',
        });
        const changePage = async (pageNumber: number, pageSize: number) => {
            pagerOptions.value.page = pageNumber;
            pagerOptions.value.itemsPerPage = pageSize;

            await getFundInventoryData();
        };

        const totalPages = computed(() => {
            const total =
                inventoryData.value.totalCount < pagerOptions.value.itemsPerPage
                    ? 1
                    : Math.ceil(inventoryData.value.totalCount / pagerOptions.value.itemsPerPage);
            return total;
        });

        const getFundInventoryData = async () => {
            try {
                inventoryData.value = await inventoryService.getFundInventories(
                    pagerOptions.value,
                    props.fund.systemIdentifier,
                    props.fund.hasExternalSource,
                    props.fund.externalIdentifier
                );
                console.log(inventoryData.value);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        watch(
            () => fundSysId.value,
            async () => {
                if (fundSysId.value && !fundExternalId.value) {
                    await getFundInventoryData();
                    if (props.addEnabled) {
                        await getFundInventoryDescLevels();
                    }
                }
            }
        );

        watch(
            () => fundExternalId.value,
            async () => {
                if (fundExternalId.value && !fundSysId.value) {
                    await getFundInventoryData();
                    if (props.addEnabled) {
                        await getFundInventoryDescLevels();
                    }
                }
            }
        );

        watch(
            () => selectedItems.value,
            () => {
                context.emit('select', selectedItems.value);
            }
        );

        onMounted(async () => {
            if (fundSysId.value || fundExternalId.value) {
                await getFundInventoryData();
                if (props.addEnabled) {
                    await getFundInventoryDescLevels();
                }
            }
        });

        return {
            t,
            disabled,
            selectedItems,
            itemCount,
            goAddInventory,
            fundInventoryDescLevels,
            currentInventoryTypes,
            changePage,
            pagerOptions,
            inventoryData,
            totalPages,
            //showAddInventoryButtons,
            getFundInventoryData,
        };
    },
});
</script>
