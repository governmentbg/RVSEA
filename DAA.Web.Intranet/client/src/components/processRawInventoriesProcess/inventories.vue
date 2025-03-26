<template>
    <FundInventories 
        :fund="fund"
        :selectionEnabled="hasRoleB"
        :selectionConditions="inventorySelectionConditions"
        v-model="selectedInventories"
    >
        <template #actions v-if="submitEnabled">
            <v-row>
                <v-col class="d-grid gap-2 d-md-flex justify-content-center">
                    <v-btn @click="goSave">{{ t('funds.buttons.saveSelected') }}
                        <v-tooltip
                            activator="parent"
                            location="bottom"
                        >
                        {{t('funds.buttons.saveSelectedTooltip')}}
                        </v-tooltip>
                    </v-btn>
                </v-col>
            </v-row>
        </template>
    </FundInventories>
</template>
<script lang="ts">
import { computed, defineComponent, inject, onMounted, PropType, ref, Ref } from 'vue';
import { useI18n } from 'vue-i18n';

import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { IFund } from '@/interfaces/fund';
import { IProcess } from '@/interfaces/process';
import { useStore } from '@/store/user';

import processRawInventoriesProcessService from '@/services/processRawInventoriesProcess.service';

import FundInventories from '@/components/inventory/fundInventories.vue';
import { ProcessStep, ProcessType } from '@/enums/process';
import { IInventory } from '@/interfaces/inventory';
import { InventoryDescriptionLevelText } from '@/enums/inventory';
import { StatusText } from '@/enums/status';
import { RoleNames } from '@/enums/roles';

export default defineComponent({
    name: "ProcessRawInventories",
    components : {
        FundInventories,
    },
    props: {
        fund: {
            type: Object as PropType<IFund>,
            required: true,
        },
        process: {
            type: Object as PropType<IProcess>,
        },
    },
    emits: ['submit'],
    setup(props, context) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const selectedInventories = ref<string[]>([]);
        
        const userStore = useStore();
        const hasRoleB = computed(() => userStore.getters.hasRole(RoleNames.GroupB));

        const inventorySelectionConditions = (item?: IInventory) => {
            if (item) {
                const isReadOnly = isInventoryReadonly(item);
                return !isReadOnly;
            }

            return false;
		};

        const submitEnabled = computed(() => 
            hasRoleB.value == true &&
            ((props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory
            && props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ChooseRawInventories) ||
            (props.process?.processTypeId === ProcessType.ProcessFundWithRawInventory
            && props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ChooseRawInventories)));

        const isInventoryReadonly = (item: IInventory) => {
            if (props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory || 
                props.process?.processTypeId === ProcessType.ProcessFundWithRawInventory) {
                if (item) {
                    const isRawInventory = item.descriptionLevelText === InventoryDescriptionLevelText.rawIventory;
                    const isStatusProcessed = item.statusText == StatusText.Processed;
                    const isStepForSelection =
                        props.process.activeProcessStepTypeId === ProcessStep.ProcessRawFundWithRawInventory_ChooseRawInventories ||
                        props.process.activeProcessStepTypeId === ProcessStep.ProcessFundWithRawInventory_ChooseRawInventories;
                    const result = !isRawInventory || isStatusProcessed || !isStepForSelection; 

                    console.log('check', result, !isRawInventory, isStatusProcessed, !isStepForSelection)

                    return result;
                }
            }

            return false;
        };

        const getMarkedInventories = async () => {
			try {
                if (props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory || 
                    props.process?.processTypeId === ProcessType.ProcessFundWithRawInventory) {
                    selectedInventories.value = await processRawInventoriesProcessService.getSelectedRawInventories(props.fund.systemIdentifier!);
                }
			} catch (error: unknown) {
				const errorResult = error as ResponseResult;
				message.value = new Message({
					text: errorResult.showMessage ? errorResult.message : t('error.basic'),
					display: true,
				});
			}
		};


        const goSave = async () => {
            try {
                if(props.process?.processTypeId === ProcessType.ProcessRawFundWithRawInventory ||
                   props.process?.processTypeId === ProcessType.ProcessFundWithRawInventory) {
                    await processRawInventoriesProcessService.saveSelectedRawInventories(
                        props.fund.systemIdentifier || '', 
                        props.process.id || 0,
                        selectedInventories.value || []);
                }

                context.emit('submit', selectedInventories.value);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };
        
        onMounted(async() => {
            await getMarkedInventories();
        })

        return {
            t,
            selectedInventories,
            submitEnabled,
            inventorySelectionConditions,
            goSave,
            hasRoleB,
        }
        
    },
})
</script>
