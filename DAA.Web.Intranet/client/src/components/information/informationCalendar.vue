<template>
    <v-calendar
        ref="calendar"
        color="primary"
        view-mode="month"
        disabled
        :text="$t('common.today')"
        :events="data"
        :intervals="1"
        :weekdays="[0, 1, 2, 3, 4, 5, 6]"
        :show-adjacent-months="false"
        @update:modelValue="onCalendarUpdate"
        class="mb-4"
        >
        <template v-slot:event="{ event }">
            <router-link :to="`/tasks/display/${event.id}`">
            <v-chip
                class="ma-2"
                :color="event.color"
                label
                large
            >
                <v-icon icon="mdi-label" start></v-icon>
                    {{  event.status }}
                    {{ event.title }}
                </v-chip>
            </router-link>
        </template>
    </v-calendar>
    <Loader :isLoading="isLoading" />
</template>

<script lang="ts">
import { defineComponent, ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import informationService from '@/services/information.service';
import { ICalendarEvent } from '@/interfaces/calendarEvent.';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    components: {
        Loader
    },
    setup() {
        const { t } = useI18n();
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const calendar = ref<any>(null);
        const data = ref<Array<ICalendarEvent>>([]);
        const isLoading = ref(false);

        const load = () => {
            const dates = calendar?.value?.daysInMonth?.map((x: { isoDate: string; }) => x.isoDate)
            isLoading.value = true;
            informationService.listCalendarItems(dates)
                .then((result) => {
                    if (result && result.length > 0) {
                        const events = [];
                        const itemsCount = result.length;
                        for (let i = 0; i < itemsCount; i++) {
                            const startDate = new Date(result[i].startDate);
                            let endDate = result[i].endDate
                                ? new Date(result[i].endDate)
                                : null;

                            if (endDate == null) {
                                const d = new Date(result[i].startDate)
                                d.setDate(d.getDate());
                                endDate = d;
                            }

                            const diffTime = Math.abs(startDate.getTime() - endDate.getTime());
                            const diff = Math.ceil(diffTime / (1000 * 3600 * 24)) + 1;

                            for (let j = 0; j < diff; j++) {
                                events.push({
                                    id: result[i].id,
                                    title: result[i].title,
                                    start: new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() + j),
                                    end: new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() + j),
                                    color: result[i].status === 'Pending' ? 'primary' : 'info',
                                    allDay: true,
                                } as ICalendarEvent);
                            }
                        }

                        data.value = events;
                    }
                })
                .catch((error: unknown) => {
                    console.log(error);
                })
                .finally(() => {
                    isLoading.value = false;
                })
        };

        onMounted(() => {
            load();
        });

        const onCalendarUpdate = () => {
            load();
        }

        return {
            t,
            data,
            isLoading,
            calendar,
            onCalendarUpdate
        };
    }
});
</script>

<style scoped lang="scss">
:deep(.v-calendar-weekly__day-label .v-btn) {
    background-color: rgb(255, 255, 255) !important;
    color: rgb(77, 77, 77) !important;
}

:deep(.v-calendar-weekly__day-label .v-calendar-weekly__day-label__today) {
    background-color: #00B300 !important;
    color: rgb(255, 255, 255) !important;
}
:deep(.v-chip) {
  height: auto !important;
}

:deep(.v-chip .v-chip__content) {
  max-width: 100%;
  height: auto;
  min-height: 32px;
  white-space: pre-wrap;
}
</style>