<template>
    <span>
        <v-row class="darken">
            <v-col class="col-5">
                <div>
                    <span class="text-white">{{ t('docsCreateProc.comment') }}</span>
                </div>
            </v-col>
            <v-col class="col-3">
                <div>
                    <span class="text-white">{{ comentTypeProp }}</span>
                </div>
            </v-col>
            <v-col class="col-3">
                <div>
                    <span class="text-white">{{ t('docsCreateProc.createDate') }}</span>
                </div>
            </v-col>
            <v-col class="col-1">
                <div class="text-center"></div>
            </v-col>
        </v-row>
        <v-row class="mt-3" v-for="(item, index) in items" :key="index">
            <v-col class="col-5">
                <span>{{ item.text }}</span>
            </v-col>
            <v-col class="col-3">
                <span class="text-center">{{ item.userName }}</span>
            </v-col>
            <v-col class="col-3">
                <span>{{ formatDate(item.date) }}</span>
            </v-col>
            <span v-if="showDelete && index == items.length - 1 && item.id == null" class="col-1 text-center">
                <button type="button" class="btn btn-actions-bar" @click="onClickDelete(item.id)">
                    <i class="fas fa-trash-alt text-danger"></i>
                </button>
            </span>
        </v-row>
    </span>
</template>

<script lang="ts">
import { defineComponent, PropType, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { CommentModel } from '../../models/comment'
import { formatDate } from '@/helpers/format.helper'

export default defineComponent({
    components: {},
    props: {
        Items: {
            type: Array as PropType<CommentModel[]>,
            required: false,
        },
        comentTypeProp: {
            type: String,
            required: true,
        },
        showDelete: {
            type: Boolean,
            required: true,
        },
        deleteLast: {
            type: Boolean,
            required: true,
            default: false,
        },
    },
    setup(props) {
        const items = ref<CommentModel[]>()
        const deleteLastEl = ref(false)
        const { t } = useI18n()
        // eslint-disable-next-line vue/no-setup-props-destructure
        items.value = props.Items

        function onClickDelete(id: number) {
            if (items?.value?.length == 1) {
                items.value = []
            }
            const arr = [] as CommentModel[]

            items?.value?.forEach((element) => {
                if (element.id != id) {
                    arr.push(element)
                }
            })
            items.value = []
            items.value = [...arr]

            deleteLastEl.value = true
        }

        return {
            t,
            onClickDelete,
            formatDate,
            items,
            deleteLastEl,
        }
    },

    watch: {
        items: function (val) {
            this.$emit('update:Items', val)
        },
        Items: function (val) {
            this.items = val
        },
        deleteLastEl: function (val) {
            this.$emit('update:deleteLast', val)
        },
        deleteLast: function (val) {
            this.deleteLastEl = val
        },
    },
})
</script>
<style scoped>
.darken {
    background-color: rgb(49, 57, 53);
}
</style>
