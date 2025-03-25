<template>
    <v-carousel
        v-if="informationData && informationData.items.length > 0"
        height="320"
        show-arrows="hover"
        hide-delimiter-background
        cycle
    >

        <v-carousel-item
            v-for="item in informationData.items"
            :key="item.uid"
            cover
        >
            <v-sheet height="100%" tile>
                <div class="d-flex fill-height justify-center align-center">
                    <v-card variant="text" density="compact">
                        <v-card-title dense>
                            {{ item.title }}
                        </v-card-title>
                        <v-card-subtitle v-if="item.startDate">
                            {{ formatDate(item.startDate) }}
                        </v-card-subtitle>
                        <v-card-item density="compact">
                            <div v-html="item.content" class="four-lines" />
                        </v-card-item>
                        <v-card-actions>
                            <v-spacer />
                            <v-btn
                                density="compact"
                                variant="plain"
                                :to="{ name: 'InformationItemDisplay', params: { id: item.id }}"
                            >

                                {{ $t('common.display') }}
                            </v-btn>
                        </v-card-actions>
                    </v-card>
                </div>
            </v-sheet>
        </v-carousel-item>
    </v-carousel>
    <Loader :isLoading="isLoading" />
</template>

<script lang="ts">
import { defineComponent, ref, onMounted } from 'vue';
import Loader from '@/components/loader/loader.vue';
import informationService from '@/services/information.service';
import { GridOptions, GridResponseModel, PageSize } from '@/models/grid';
import { IInformation } from '@/interfaces/information';
import { formatDate } from '@/helpers/format.helper';

export default defineComponent({
    name: 'InformationCarousel',
    components: {
        Loader
    },
    setup() {
        const isLoading = ref(false);
        const pagerOptions = ref<GridOptions>({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: PageSize.ten,
            sortByType: '',
            searchString: '',
            totalPages: 1
        });
        const informationData = ref<GridResponseModel<IInformation>>(
            new GridResponseModel<IInformation>({ totalCount: 0, items: [] })
        );

        const load = () => {
            isLoading.value = true;
            informationService.listCarouselItems(pagerOptions.value)
            .then((result) => {
                if(result) {
                    informationData.value = result;
                }
            })
            .catch((error: unknown) => {
               console.log(error);
            })
            .finally(() => {
                isLoading.value = false;
            })
        };

        onMounted(async () => {
            await load();
        });

        return {
            isLoading,
            informationData,
            formatDate,
        }
    }
});
</script>