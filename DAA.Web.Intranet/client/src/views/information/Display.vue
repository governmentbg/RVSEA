<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <Loader :isLoading="isLoading" />
    <v-container>
        <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
            <v-card-title>
                {{ data.title }}
            </v-card-title>
            <v-card-subtitle v-if="data.startDate">
                {{ formatDate(data.startDate) }}
            </v-card-subtitle>
            <v-card-item>
                <div v-html="data.content"/>
            </v-card-item>
        </v-card>
    </v-container>
</template>

<script lang="ts">
import { defineComponent, ref, onMounted, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import Loader from '@/components/loader/loader.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import informationService from '@/services/information.service';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { IInformation } from '@/interfaces/information';
import { ResponseResult } from '@/models/responseResult';
import { formatDate } from '@/helpers/format.helper';


export default defineComponent({
    components:{
        Loader,
        Breadcrumbs
    },
    props: {
        id: {
            type: Number,
            required: true
        },
    },
    setup(props) {
        const { t } = useI18n();
        const isLoading = ref(false);
        const message = inject('notificationMessage') as Ref<IMessage>;
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
        const data = ref<IInformation>({} as IInformation);

        const load = () => {
            isLoading.value = true;
            informationService.get(props.id)
            .then((result) => {
                if(result) {
                    data.value = result
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

        onMounted(() => {
            load();
        });

        return {
            isLoading,
            breadcrumbItems,
            data,
            formatDate
        }
    }
});
</script>