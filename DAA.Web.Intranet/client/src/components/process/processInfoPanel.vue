<template>
    <v-expansion-panel :value="value">
        <v-expansion-panel-title>{{
            t('processes.panels.generalInfo')
        }}</v-expansion-panel-title>
        <v-expansion-panel-text>
            <v-row>
                <v-col class="col-12 col-lg-6">
                    <TextField 
                        :disabled="true" 
                        name="fldProcessType" 
                        :label="t('processes.columns.processType')" 
                        :modelValue="process.processTypeTitle" 
                    />
                </v-col>
                <v-col class="col-12 col-lg-6">
                    <TextField 
                        :disabled="true" 
                        name="fldProcessStep" 
                        :label="t('processes.columns.processStep')" 
                        :modelValue="process.activeProcessStepName" 
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col class="col-12 col-lg-6">
                    <TextField 
                        :disabled="true" 
                        name="fldCreatedOn" 
                        :label="t('processes.columns.createdOn')" 
                        :modelValue="formatDate(process.createdOn)" 
                    />
                </v-col>
                <v-col class="col-12 col-lg-6">
                    <TextField 
                        :disabled="true" 
                        name="fldCreatedBy" 
                        :label="t('processes.columns.createdBy')" 
                        :modelValue="process.createdByDisplayName" 
                    />
                </v-col>
            </v-row>
            <!-- <v-row>
                <v-col>
                    <TextField 
                        :disabled="true" 
                        name="fldFund" 
                        :label="t('processes.columns.fund')" 
                        :modelValue="process.fundNumber" 
                    />
                </v-col>
                <v-col>
                    <TextField 
                        :disabled="true" 
                        name="fldInventory" 
                        :label="t('processes.columns.inventory')" 
                        :modelValue="process.inventoryNumber" 
                    />
                </v-col>
            </v-row>
            <v-row>
                <v-col>
                    <TextField 
                        :disabled="true" 
                        name="fldArchivalEntity" 
                        :label="t('processes.columns.archivalEntity')" 
                        :modelValue="process.archivalEntityNumber" 
                    />
                </v-col>
                <v-col>
                    <TextField 
                        :disabled="true" 
                        name="fldDocument" 
                        :label="t('processes.columns.document')" 
                        :modelValue="process.documentTitle" 
                    />
                </v-col>
            </v-row> -->
            <!-- <v-row>
                <v-col class="col-12"> -->
                    <!-- <v-dialog 
                        v-model="showDialog"
                        persistent
                    >
                        <template v-slot:activator="{ props }">
                            <v-btn 
                                v-bind="props"
                            >{{ 
                                t('processes.buttons.complete') 
                            }}</v-btn>
                        </template>
                        <v-card>
                            <v-card-text>
                                 {{ t('processes.buttons.completeConfirmation', {title: process.processTypeTitle}) }}
                            </v-card-text>
                            <v-card-actions>
                            <v-spacer></v-spacer>
                            <v-btn
                                text
                                @click="btnCompleteClickHandler"
                            >
                                {{ t('processes.buttons.complete') }}
                            </v-btn>
                            <v-btn
                                text
                                @click="btnCancelClickHandler"
                            >
                                {{ t('common.cancel') }}
                            </v-btn>
                            </v-card-actions>
                        </v-card>
                    </v-dialog>  -->
                    <slot name="actions"></slot>
                <!-- </v-col>
            </v-row> -->
        </v-expansion-panel-text>
    </v-expansion-panel>
</template>
<script lang="ts">
import { defineComponent, PropType, } from 'vue'
import { useI18n } from 'vue-i18n';
import {formatDate} from "@/helpers/format.helper";
//import { Message } from "@/models/notification";

//import { IMessage } from '@/interfaces/notification';
//import { ResponseResult } from "@/models/responseResult";
import { IProcess } from '@/interfaces/process';
//import processService from '@/services/process.service';

import TextField from "@/components/field/text.field.vue";

export default defineComponent({
    name: "ProcessInformationPanel",
    components: {
        TextField,
    },
    props: {
        value: {
            type: [String, Boolean],
        },
        // entityType: {
        //     type: String,
        //     required: true,
        // },
        // entitySysId: {
        //     type: String,
        //     required: true,
        // },
        process: {
            type: Object as PropType<IProcess>,
        }
    },
    setup() {
        const { t } = useI18n();
        
        //const message = inject("notificationMessage") as Ref<IMessage>;
        
        //const showDialog = ref<boolean>(false);

        //const process = ref<IProcess>();

        // const getProcessData = async () => {
        //     try {
        //         process.value = await processService.getCurrentActiveProcess(props.entityType, props.entitySysId);
        //     } catch (error: unknown) {
        //         const errorResult  = error as ResponseResult;
        //         message.value = new Message({
        //             text:  errorResult.showMessage ? errorResult.message : t('error.basic'),
        //             display: true,
        //         });
        //     }
        // };

        // const btnCompleteClickHandler = async () => {
        //     try {
        //         //await processService.completeProcess(process.value!.id!);
        //         await processService.completeProcess(props.process!.id!);
                 
        //         showDialog.value = false;
        //         context.emit('completeProcess');

        //     } catch (error: unknown) {
        //         const errorResult  = error as ResponseResult;
        //         message.value = new Message({
        //             text:  errorResult.showMessage ? errorResult.message : t('error.basic'),
        //             display: true,
        //         });
        //     }
        // };

        // const btnCancelClickHandler = () => {
        //     showDialog.value = false;
        //     context.emit('cancel');
        // };

        // onMounted(async() => {
        //     await getProcessData();
        // });

        return {
            t,
            //process,
            //showDialog,
            //btnCompleteClickHandler,
            //btnCancelClickHandler,
            formatDate,
        }
    },
})
</script>
