<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <div
        v-if="!informationData.items.some(x => x.isEditMode === true)"
        class="d-flex justify-space-between pb-2"
    >
        <v-btn
            @click.stop="onAdd "
            >
            {{ t('common.new') }}
        </v-btn>
        <v-text-field
            v-model="pagerOptions.searchString"
            density="comfortable"
            :placeholder="t('grid.search.tooltip')"
            prepend-inner-icon="mdi-magnify"
            style="max-width: 600px;"
            variant="solo"
            clearable
            hide-details
          />
    </div>
    <v-row justify="center" dense v-if="!isLoading">
        <v-col v-for="(item, index) in informationData.items"
            :key="item.uid"
            cols="12" :md="!!item.isEditMode ? '12' : '6'" 
        >
            <Form @submit="onSubmit(informationData.items[index])">
                <information-item
                    v-model="informationData.items[index]"
                    :read-only="item.deleted"
                >
                    <template #actions="{ item }">
                        <v-spacer />
                        <v-btn 
                            v-if="!item.isEditMode"
                            icon
                            color="transparent"
                            variant="flat"
                            @click.stop="item.isEditMode = true"
                        >
                            <v-icon>mdi-pencil-outline</v-icon>
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('common.edit') }}
                            </v-tooltip>
                        </v-btn>
                        <v-btn
                            v-if="!item.isEditMode && !!item.id"
                            icon
                            color="transparent"
                            variant="flat"
                            @click="onDelete(item)">
                            <v-icon>mdi-delete-outline</v-icon>
                            <v-tooltip activator="parent" location="bottom">
                                {{ t('common.delete') }}
                            </v-tooltip>
                        </v-btn>
                        <v-btn 
                            v-if="!item.isEditMode && !!item.id"
                            icon
                            color="transparent"
                            variant="flat"
                            :to="{ name: 'InformationItemDisplay', params: { id: item.id }}"
                        >
                            <v-icon>mdi-eye</v-icon>
                            <v-tooltip activator="parent" location="bottom">
                                {{ $t('common.display') }}
                            </v-tooltip>       
                        </v-btn>            
                        <submit-btn
                            v-if="item.isEditMode"
                            type="submit"
                        >
                            {{ t('common.save') }}
                        </submit-btn>
                        <cancel-btn
                            v-if="item.isEditMode"
                            @click="onCancel(item)"
                        >
                            {{ t('common.cancel') }}
                        </cancel-btn>
                    </template>
                </information-item>
            </Form>
        </v-col>
    </v-row>
    <v-row justify="center" class="mt-4">
        <Pager
            :initialPage="pagerOptions.page"
            :initialPageSize="pagerOptions.itemsPerPage"
            :totalPages="pagerOptions.totalPages"
            @change="changePage"
            ref="pager"
        />
    </v-row>
    <Loader :isLoading="isLoading" />
</template>

<script lang="ts">
import { defineComponent, ref, inject, Ref, watch, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import informationService from '@/services/information.service';

import Loader from '@/components/loader/loader.vue';
import Pager from '@/components/grid/pager.vue';
import InformationItem from '@/components/information/informationItem.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { Form } from 'vee-validate';
import { GridOptions, GridResponseModel, PageSize } from '@/models/grid';
import { IInformation } from '@/interfaces/information';
import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { uid } from "uid";
import debounce from 'lodash.debounce'

export default defineComponent({
    name: 'InformationAdministration',
    components: {
        Form,
        Loader,
        Pager,
        InformationItem,
        Breadcrumbs
    },
    setup() {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;

        const isLoading = ref(false);
        const search = ref(false);

        const informationData = ref<GridResponseModel<IInformation>>(
            new GridResponseModel<IInformation>({ totalCount: 0, items: [] })
        );

        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.informationBoard'),
                disabled: true,
            },
        ];

        const pagerOptions = ref<GridOptions>({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: PageSize.twenty,
            sortByType: '',
            searchString: '',
            totalPages: 1
        });

        const load = () => {
            isLoading.value = true;
            informationService.list(pagerOptions.value)
            .then((result) => {
                if(result) {
                    informationData.value = result;
                }
            })
            .catch((error: unknown) => {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            })
            .finally(() => {
                isLoading.value = false;
            })
        }

        const changePage = async (pageNumber: number, pageSize: number) => {
            pagerOptions.value.page = pageNumber;
            pagerOptions.value.itemsPerPage = pageSize;
        };

        const onSubmit = async (item: IInformation) => {
            try {
                isLoading.value = true;
                const result = item.id
                    ? await informationService.update(item)
                    : await informationService.create(item);

                if (result.status == 200) {
                    message.value = new Message({
                        text: item.id ? t('common.successfullyEdit') : t('common.successfullyCreated'),
                        display: true,
                        type: 'success',
                        timeout: 5000,
                    });
                }

                item.isEditMode = false;
                load();
            } catch (error) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                isLoading.value = false;
            }
        }

        const onDelete = async (item: IInformation) => {
            try {
                isLoading.value = true;
                const result = await informationService.delete(item.id);

                if (result.status == 200) {
                    message.value = new Message({
                        text: t('common.successfullyEdit'),
                        display: true,
                        type: 'success',
                        timeout: 5000,
                    });
                }
                item.isEditMode = false;
                
                load();
            } catch (error) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                isLoading.value = false;
            }
        }

        const onCancel = (item: IInformation) => {
            item.isEditMode = false;
            load();
        }

        const onAdd = () => {
            informationData.value.items.splice(0,0, { isEditMode: true, uid: uid() } as IInformation)
        }

        watch(
            () => pagerOptions.value, 
            debounce((value: GridOptions) => {
                if(value) {
                  load();
                }
            }, 1000),
            { deep: true }
        );

        onMounted(async () => {
            await load();
        });

        return {
            t,
            isLoading,
            search,
            informationData,
            pagerOptions,
            breadcrumbItems,
            changePage,
            onSubmit,
            onCancel,
            onAdd,
            onDelete
        };
    }
});
</script>