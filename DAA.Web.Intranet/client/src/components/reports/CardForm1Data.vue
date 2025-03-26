<template>
    <v-row class="col-12">
        <v-col>
            <v-btn class="d-print-none" @click="printButton">{{ t('common.print') }} </v-btn>
        </v-col>
    </v-row>
    <h3 class="display-6">{{ t('reports.cardForm1') }}</h3>
    <v-container fluid class="overflowX">
        <div v-show="showReport">
            <table>
                <tr>
                    <td :style="styleBorder">
                        <div>{{ summary.archive }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ summary.archiveCode }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ summary.number }}</div>
                    </td>
                    <td :style="styleBorder" rowspan="2" colspan="4">
                        <div>{{ summary.title }}</div>
                    </td>
                </tr>
                <tr>
                    <td :style="styleBorder">
                        <div>{{ t('reports.parenthesesArchiveName') }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ t('reports.parenthesesArchiveCode') }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ t('reports.parenthesesFundNumber') }}</div>
                    </td>
                </tr>
                <tr>
                    <td :style="styleBorder" colspan="4">
                        <div>{{ summary.creationDate }}</div>
                    </td>
                    <td :style="styleBorder" colspan="3">
                        <div>{{ t('reports.parenthesesFundNameAndEndDates') }}</div>
                    </td>
                </tr>
                <tr>
                    <td :style="styleBorder" colspan="3">
                        <div>{{ t('reports.parenthesesFilingDate') }}</div>
                    </td>
                    <td class="trim1" :style="styleBorder" colspan="3"></td>
                </tr>
                <tr>
                    <td :style="styleBorder">
                        <div>{{ t('reports.type') }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ t('reports.acceptance') }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ t('reports.industry') }}</div>
                    </td>
                    <td :style="styleBorder" colspan="4">
                        <div>{{ t('reports.actualFundAvailability') }}</div>
                    </td>
                </tr>
                <tr>
                    <td :style="styleBorder">
                        <div>{{ summary.type }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ summary.methodOfAcquisition }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ summary.industryIndex }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ t('reports.inventoryCount1') }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ t('reports.archiveEntitiesCount1') }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ t('reports.linearMeters1') }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ t('reports.volumeMB') }}</div>
                    </td>
                </tr>
                <tr>
                    <td class="trim2" :style="styleBorder" colspan="3"></td>
                    <td :style="styleBorder">
                        <div>{{ summary.inventoriesCount }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ summary.archivalEntitiesCount }}</div>
                    </td>
                    <td :style="styleBorder">
                        <div v-html="formatStringOnTwoLines(summary.linearMeters)"></div>
                    </td>
                    <td :style="styleBorder">
                        <div>{{ formatBytesToMB(summary.size) }}</div>
                    </td>
                </tr>
            </table>
            <table>
                <thead>
                    <tr>
                        <!-- <td colspan="1">
                            <div>{{ t('reports.systemIdentifier') }}</div>
                        </td> -->
                        <td colspan="1">
                            <div>{{ t('reports.yearInventoryNumber') }}</div>
                        </td>
                        <td colspan="1">
                            <div>{{ t('reports.endDates') }}</div>
                        </td>
                        <td colspan="1">
                            <div>{{ t('reports.inventorized') }}</div>
                        </td>
                        <td colspan="1">
                            <div>{{ t('reports.uninventorized') }}</div>
                        </td>
                        <td colspan="1">
                            <div>{{ t('reports.deducted') }}</div>
                        </td>
                        <td colspan="1">
                            <div>{{ t('reports.availableInInventory') }}</div>
                        </td>
                        <td>
                            <div>{{ t('reports.availableInInventoryMB') }}</div>
                        </td>
                        <td colspan="1">
                            <div>{{ t('reports.capturedAE') }}</div>
                        </td>
                        <td colspan="1">
                            <div>{{ t('reports.negativeFrames') }}</div>
                        </td>
                        <td colspan="1">
                            <div>{{ t('reports.positiveFrames') }}</div>
                        </td>

                        <td colspan="1">
                            <div>{{ t('reports.phonoDocuments') }}</div>
                        </td>
                        <td colspan="1">
                            <div>{{ t('reports.videoDocuments') }}</div>
                        </td>
                        <td colspan="1">
                            <div>{{ t('reports.digitalDocuments') }}</div>
                        </td>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>1</td>
                        <td>2</td>
                        <td>3</td>
                        <td>4</td>
                        <td>5</td>
                        <td>6</td>
                        <td>7</td>
                        <td>8</td>
                        <td>9</td>
                        <td>10</td>
                        <td>11</td>
                        <td>12</td>
                        <td>13</td>
                        <!-- <td>14</td> -->
                    </tr>
                    <tr v-for="item in gridItems" :key="item">
                        <!-- <td>
                            <div>{{ item.systemIdentifier ? item.systemIdentifier : item.lGid }}</div>
                        </td> -->
                        <td>
                            <div v-html="formatStringOnTwoLines(item.yearCreatedAndInventoryNumber)"></div>
                        </td>
                        <td>
                            <div v-html="formatStringOnTwoLines(item.endDates)"></div>
                        </td>
                        <td>
                            <div v-html="formatStringOnTwoLines(item.inventorizedCount, false)"></div>
                        </td>
                        <td>
                            <div>{{ item.uninventorizedCount }}</div>
                        </td>
                        <td>
                            <div v-html="formatStringOnTwoLines(item.deductedCount)"></div>
                        </td>
                        <td>
                            <div v-if="!item.systemIdentifier">
                                <span
                                    v-html="formatStringOnTwoLines(item.availableArchivalEntitiesCountAndSize)"
                                ></span>
                            </div>
                        </td>
                        <td>
                            <div v-if="item.systemIdentifier">
                                <span
                                    v-html="formatStringOnTwoLines(item.availableArchivalEntitiesCountAndSize, true)"
                                ></span>
                            </div>
                        </td>
                        <td>
                            <div>{{ item.microfilmedArchivalOfEntityCount }}</div>
                        </td>
                        <td>
                            <div>{{ item.negativeFramesCount }}</div>
                        </td>
                        <td>
                            <div>{{ item.positiveFramesCount }}</div>
                        </td>
                        <td>
                            <div>{{ item.phonoDocumentsCount }}</div>
                        </td>
                        <td>
                            <div>{{ item.videoDocumentsCount }}</div>
                        </td>
                        <td>
                            <div v-if="item.systemIdentifier">{{ item.digitalDocumentCount }}</div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </v-container>
</template>
<script lang="ts">
import { defineComponent, ref, inject, Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import {
    ReportGridWithSummaryGridResponseModel,
    CardForm1Data,
    CardForm1SummaryExternalData,
    CardForm1DataFiltersModel,
    ReportGridRequestModel,
} from '@/models/reports';
import reportService from '@/services/report.service';
import { Message } from '@/models/notification';
import { IMessage } from '../../interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { formatStringOnTwoLines, formatBytesToMB } from '@/helpers/format.helper';
export default defineComponent({
    name: 'CardForm1Data',
    emits: ['loadingChange'],
    props: {
        id: {
            type: String,
        },
        hasExternalSource: {
            type: Boolean,
        },
        externalIdentifier: {
            type: Number,
        },
    },
    setup(props, { emit }) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const inputModel = new CardForm1DataFiltersModel();
        const gridItems = ref([] as CardForm1Data[]);
        const loading = ref(false);
        const showReport = ref(false);
        const summary = ref([] as CardForm1SummaryExternalData[]);
        const styleBorder = 'border:1px solid black';

        const viewReport = () => {
            emit('loadingChange', true);
            inputModel.externalIdentifier = props.externalIdentifier as number;
            inputModel.hasExternalSource = props.hasExternalSource;
            inputModel.systemIdentifier = props.id as string;
            const gridInputModel = new ReportGridRequestModel<CardForm1DataFiltersModel>({
                Page: 1,
                ItemsPerPage: 5000,
                Filters: inputModel,
            });
            reportService
                .getCardForm1Data(gridInputModel)
                .then((result: ReportGridWithSummaryGridResponseModel<CardForm1SummaryExternalData, CardForm1Data>) => {
                    gridItems.value = [];

                    //gridItems.value = [...result.items];
                    result.items.forEach((item) => {
                        if (item.availableArchivalEntitiesCountAndSize) {
                            const firstPArt = item.availableArchivalEntitiesCountAndSize?.toString().split(';').shift();
                            const lastPArt = Number.parseFloat(
                                item.availableArchivalEntitiesCountAndSize.toString().split(';').pop() as string
                            );
                            item.availableArchivalEntitiesCountAndSize = `${firstPArt}<br/>${lastPArt.toFixed(2)}MB`;
                        }
                        gridItems.value.push(item);
                    });

                    if (result.summary?.archiveCode) {
                        summary.value = Object.assign(result.summary!);
                    }

                    showReport.value = true;
                })
                .catch((error: unknown) => {
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                })
                .finally(() => emit('loadingChange', false));
        };

        viewReport();

        const printButton = () => {
            window.print();
        };

        return {
            t,
            formatStringOnTwoLines,
            printButton,
            formatBytesToMB,
            loading,
            gridItems,
            showReport,
            styleBorder,
            summary,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/report.scss';
@import '@/assets/styles/breadcrumbs.scss';

.trim2 {
    border-bottom: none !important;
    border-left: none !important;
}

.trim1 {
    border-right: none !important;
}

td {
    text-align: center;
    padding: 5px;
}

table {
    font-weight: bold;
    margin-top: 100px;
}
td {
    text-align: center;
    padding: 5px;
}

thead {
    font-weight: bold;
}

td {
    border: 1px solid black;
}

.empty {
    border: 0px;
}

tr:has(.three) {
    vertical-align: middle;
    margin-left: auto;
    margin-right: auto;
}
</style>
