<template>
    <div class="row flex">
        <div class="col col-sm-6 col-md-6 col-lg-6 py-3">
            <grid
                ref="grid"
                mode="custom"
                :items="items"
                :columns="columns"
                :paging="true"
                :pageSize="pageSize"
                :totalItems="totalCount"
                :showLoading="loading"
                :showExport="false"
                :showSearch="false"
                :rowHighlighting="true"
                :noDataMessage="t('notifications.noNotificationsMessage')"
                @rowClick="onRowClick"
                @refresh="fetchItems"
            >
            </grid>
        </div>
        <span
            v-if="selectedNotification"
            class="body html-output col-xs-6 col-sm-6 col-md-6 py-3"
            v-html="text"
            disabled
        ></span>
    </div>
</template>

<script lang="ts">
import { defineComponent, ref, computed, onMounted, watch, inject, Ref } from 'vue'
import { useI18n } from 'vue-i18n'
import Grid from '@/components/grid/grid.vue'
import notificationService from '@/services/notification.service'
import { NotificationViewModel, NotificationDataSourceResponseModel } from '@/models/notification'
import { IDataTableOptions } from '@/interfaces/dataTable'
import { INotification } from '@/interfaces/notification'
import { formatDateTime } from '@/helpers/format.helper'
import RowItem from '@/components/grid/rowItem.vue'
import { PageSize } from '@/models/grid'
import { DataTableOptions } from '@/models/dataTable'
import { useStore } from '@/store/user'
import { ActionTypes as UserStoreActionTypes } from '@/store/user/actions'
import { ResponseResult } from '@/models/responseResult'
import { IMessage } from '@/interfaces/notification'
import { Message } from '@/models/notification'

export default defineComponent({
    name: 'UserNotifications',
    components: { Grid },
    emits: ['unseen:count'],
    setup(props, context) {
        const { t } = useI18n()
        const message = inject('notificationMessage') as Ref<IMessage>
        const grid = ref()
        const userStore = useStore()

        userStore.dispatch(UserStoreActionTypes.RefreshNotificationsPage, false)

        const refreshNotificationsPage = computed(() => userStore.getters.refreshNotificationsPage)
        watch(refreshNotificationsPage, async (val) => {
            if (val) {
                await fetchItems(options.value)
                userStore.dispatch(UserStoreActionTypes.RefreshNotificationsPage, false)
            }
        })

        const columns = [
            {
                title: '',
                prop: 'isSeen',
                type: 'html',
                renderFunction: (item: boolean) => {
                    if (item == true) {
                        return "<i class='far fa-envelope-open'></i>"
                    } else {
                        return "<i class='fas fa-envelope'></i>"
                    }
                },
                sortable: false,
            },
            {
                title: t('notifications.list.createdOn'),
                prop: 'createdOn',
                type: 'date',
                renderFunction: formatDateTime,
                sortable: false,
            },
            {
                title: t('notifications.list.subject'),
                prop: 'subject',
                type: 'string',
                sortable: false,
            },
        ]

        const pageSize = PageSize.ten

        const items = ref<NotificationViewModel[]>()
        items.value = []

        const options = ref(new DataTableOptions())
        options.value.sortBy = ''
        options.value.sortDesc = false
        options.value.page = 1
        options.value.itemsPerPage = pageSize
        options.value.searchString = ''

        let loading = false
        let totalCount = ref(0)

        let unseenCount = ref(0)
        const unseen = computed({
            get: () => unseenCount,
            set: (value) => {
                context.emit('unseen:count', value)
            },
        })

        const fetchItems = async (requestParams: IDataTableOptions) => {
            loading = true

            options.value.page = requestParams.page
            options.value.itemsPerPage = requestParams.itemsPerPage

            notificationService
                .list(requestParams)
                .then((response) => {
                    const result = response.data as NotificationDataSourceResponseModel<NotificationViewModel>

                    totalCount.value = result.totalCount
                    items.value = []
                    result.items.forEach((item: INotification) => {
                        items.value?.push(new NotificationViewModel(item))
                    })
                    unseenCount.value = result.totalUnseen || 0
                    unseen.value = unseenCount

                    loading = false
                })
                .catch(() => {
                    loading = false
                })
        }

        const selectedNotification = ref(undefined as NotificationViewModel | undefined)
        const text = computed(() => (selectedNotification.value != undefined ? selectedNotification.value.body : ''))

        const onRowClick = (row: typeof RowItem) => {
            const id = row.items.id

            if (selectedNotification.value && selectedNotification.value.id === id) {
                selectedNotification.value = undefined
            } else {
                selectedNotification.value = items.value?.find((item) => item.id == id)
            }
            if (!row.items.isSeen) {
                markAsSeen(id)
            }
        }

        const markAsSeen = (id: number) => {
            notificationService
                .markAsSeen(id)
                .then(() => {
                    fetchItems(options.value)
                    highlightRowByItemId(id)
                    console.log('marked as seen: ', id)
                    userStore.dispatch(UserStoreActionTypes.DecreaseUnSeenNotifications, id)
                })
                .catch((error: unknown) => {
                    const errorResult = error as ResponseResult
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    })
                })
        }

        const highlightRowByItemId = (id: number) => {
            grid.value?.highlightRowByItemId(id)
        }

        onMounted(async () => {
            await fetchItems(options.value)
        })

        return {
            t,
            columns,
            pageSize,
            items,
            fetchItems,
            loading,
            totalCount,
            onRowClick,
            selectedNotification,
            text,
        }
    },
})
</script>

<style lang="scss" scoped>

@import "@/assets/styles/index.scss";
@import "@/assets/styles/tasks.scss";

</style>