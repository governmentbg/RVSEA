<template>
    <v-expansion-panel :value="value" :readonly="readOnly">
        <v-expansion-panel-title>{{ t('processes.panels.start') }}</v-expansion-panel-title>
        <v-expansion-panel-text>
            <v-row align="center">
                <v-col align="center" class="col-12 col-lg-9">
                    <Dropdown v-model="processType" :items="processTypes" valueProp="id" :disabled="readOnly" />
                </v-col>
                <v-col align="center" class="col-12 col-lg-3">
                    <v-dialog v-model="showDialog" persistent>
                        <template v-slot:activator="{ props }">
                            <v-btn :disabled="readOnly || (processType === undefined || processType === null)" v-bind="props"
                                >{{ t('processes.buttons.start') }}
                                <v-tooltip activator="parent" location="bottom">
                                    {{ t('processes.buttons.startTooltip') }}
                                </v-tooltip>
                            </v-btn>
                        </template>
                        <v-card>
                            <v-card-text v-if="entityHasExternalSource">
                                {{ t('processes.buttons.partialStartConfirmation') }}
                            </v-card-text>
                            <v-card-text>
                                {{ t('processes.buttons.startConfirmation', { title: processTypeTitle }) }}
                            </v-card-text>
                            <v-card-actions style="margin-bottom: 25px;">
                                <v-spacer />
                                <submit-btn style="margin-right: 15px;" class="not" @click="btnStartClickHandler" :disabled="disableOk">
                                    {{ t('common.yes') }}
                                    <v-tooltip activator="parent" location="bottom">
                                        {{ t('processes.buttons.startTooltip') }}
                                    </v-tooltip>
                                </submit-btn>
                                <cancel-btn class="not" @click="btnCancelClickHandler">
                                    {{ t('common.cancel') }}
                                    <v-tooltip activator="parent" location="bottom">
                                        {{ t('processes.buttons.cancelTooltip') }}
                                    </v-tooltip>
                                </cancel-btn>
                                <v-spacer />
                            </v-card-actions>
                        </v-card>
                    </v-dialog>
                </v-col>
            </v-row>
        </v-expansion-panel-text>
    </v-expansion-panel>
</template>
<script lang="ts">
import { defineComponent, onMounted, PropType, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';

import { IDropdownOption } from '@/interfaces/dropdown';
import dropdownService from '@/services/dropdown.service';

import Dropdown from '@/components/dropdown/dropdown.vue';

export default defineComponent({
    name: 'StartProcessPanel',
    components: {
        Dropdown,
    },
    props: {
        value: {
            type: [String, Boolean],
        },
        entityType: {
            type: [String, Array] as PropType<string | string[]>,
        },
        entityHasExternalSource: {
            type: Boolean,
            default: false,
        },
        readOnly: {
            type: Boolean,
            default: false,
        },
    },
    emits: ['startProcess', 'cancel'],
    setup(props, context) {
        const { t } = useI18n();

        const processType = ref<number>();
        const processTypeTitle = ref<string>();

        const processTypes = ref<IDropdownOption[]>([]);

        const getProcessTypes = async () => {
            processTypes.value = await dropdownService.getProcessTypes(props.entityType);
        };

        const showDialog = ref<boolean>(false);
        const disableOk = ref<boolean>(false);

        const btnStartClickHandler = async () => {
            disableOk.value = true;
            showDialog.value = false;
            context.emit('startProcess', processType.value);
        };

        const btnCancelClickHandler = () => {
            showDialog.value = false;
            processType.value = undefined;
            context.emit('cancel', processType.value);
        };

        onMounted(async () => {
            await getProcessTypes();
        });

        watch(processType, (newVal, oldVal) => {
            if (newVal !== oldVal) {
                processTypeTitle.value = processTypes.value.find((p) => p.id === newVal)?.label;
            }
        });

        watch(props, async () => {
            await getProcessTypes();
        });

        return {
            t,
            processType,
            processTypeTitle,
            processTypes,
            showDialog,
            disableOk,
            btnStartClickHandler,
            btnCancelClickHandler,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/dialog.scss';

.v-expansion-panel-text {
    height: 200px;
}

:deep(.d-down),
.v-btn {
    top: 50px !important;
}

:deep(.d-down.is-open > .multiselect-dropdown) {
    top: -75% !important;
}

// :deep(::-webkit-scrollbar-track) {
//     background-color: rgba(211, 211, 211, 0.434);
//     border-radius: 0px 7.5px 7.5px 0px;
// }

:deep(div.multiselect-dropdown) {
    border-radius: 7.5px;
}

:deep(div.multiselect-dropdown) {
    transform-origin: center;
}

.not {
    top: 0% !important;
}
</style>
