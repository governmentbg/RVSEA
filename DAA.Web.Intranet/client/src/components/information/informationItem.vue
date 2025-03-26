<template>
    <v-card>
        <!-- {{ data }} -->
        <!-- {{  modelValue.isEditMode }}
        {{ data.isEditMode }} -->
        <v-card-title>
            <text-field
                v-if="data.isEditMode"
                name="fldTitle"
                :label="t('funds.columns.title')"
                v-model="data.title"
                validation="required"
            />
            <span v-else>
                <div class="d-flex justify-space-between" >
                    <span>{{ data.title }}</span>
                    <v-chip v-if="data.deleted" color="red" variant="flat">
                        {{ $t('common.deleted')}}
                    </v-chip>
                </div>
            </span>
        </v-card-title>
        <v-card-subtitle v-if="!data.isEditMode">
            {{ data.startDate ? formatDate(data.startDate) : '' }}
        </v-card-subtitle>
        <v-card-item v-if="data.isEditMode">
            <v-row dense>
                <v-col cols="12" md="6">
                    <DatePicker
                        :label="t('reports.chronologicalExtentEndDate')"
                        required
                        v-model:date="data.startDate"
                    />
                </v-col>
                <v-col cols="12" md="6">
                    <DatePicker
                        :label="t('reports.chronologicalExtentEndDate')"
                        v-model:date="data.endDate"
                        :start-date="data.startDate"
                    />
                </v-col>
                <v-col cols="12">
                    <RichText v-model="data.content" />
                </v-col>
            </v-row>
        </v-card-item>
        <v-card-item v-else>
            <div v-html="data.content" class="four-lines"/>
        </v-card-item>
        <v-card-actions v-if="!readOnly">
            <slot name="actions" :item="data"/>
        </v-card-actions>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, PropType, ref, watch } from 'vue';
import { IInformation } from '@/interfaces/information';
import { useI18n } from 'vue-i18n';
import { formatDate } from '@/helpers/format.helper';

import TextField from '@/components/field/text.field.vue';
import DatePicker from '@/components/datetime/datepPicker.vue';
import RichText from '@/components/tinyMCE/tinyMCE.vue';

export default defineComponent({
    name: 'InformationItemCard',
    components: {
        TextField,
        DatePicker,
        RichText
    },
    props: {
        modelValue: {
            type: Object as PropType<IInformation>,
            required: true,
        },
        readOnly: {
            type: Boolean,
            default: false,
        }
    },
    emits: ['update:modelValue', 'change'],
    setup(props, { emit }) {
        const data = ref(props.modelValue);
        const { t } = useI18n();

        watch(
            () => data,
            () => {
                emit('update:modelValue', data.value);
                emit('change', data.value);
            }
        );
        return {
            t,
            data,
            formatDate
        };
    },
});
</script>
