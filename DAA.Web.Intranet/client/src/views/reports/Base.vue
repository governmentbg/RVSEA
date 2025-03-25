<template>
    <v-container fluid>
        <Loader @cancel="onCancleClick" :showCancel="true" :isLoading="isLoading" />
        <component
            :is="component"
            @loadingChange="loadingChange"
            :isCanceled="cancel"
            :id="id"
            :hasExternalSource="hasExternalSource"
            :externalIdentifier="externalIdentifier"
        />
    </v-container>
</template>
<script lang="ts">
import { defineComponent, ref, shallowRef } from 'vue';
import Funds from '@/components/reports/Funds.vue';
import FundsAvailability from '@/components/reports/FundsAvailability.vue';
import FundsList from '@/components/reports/FundsList.vue';
import FundMemoriesListInternalReport from '@/components/reports/FundMemoriesListInternalReport.vue';
import FundMemoriesList from '@/components/reports/FundMemoriesList.vue';
import PartialReceiptsList from '@/components/reports/PartialReceiptsList.vue';
import ReceiptsList from '@/components/reports/ReceiptsList.vue';
import WorkListForPriorityRestoration from '@/components/reports/WorkListForPriorityRestoration.vue';
import InventoryBook from '@/components/reports/InventoryBook.vue';
import AccountAndDescriptionOfFilmDocumentsBook from '@/components/reports/AccountAndDescriptionOfFilmDocumentsBook.vue';
import InsuranceFundOfCopiesOfForeignArchives from '@/components/reports/InsuranceFundOfCopiesOfForeignArchives.vue';
import inventoryBookOfCopiesFromForeignArchives from '@/components/reports/InventoryBookOfCopiesFromForeignArchives.vue';
import compilationAndNTOOfEDocuments from '@/components/reports/CompilationAndNTOOfEDocuments.vue';
import RegisterOfDigitizedDocumentsReport from '@/components/reports/RegisterOfDigitizedDocumentsReport.vue';
import CountOfUsedCopiesOfDocumentsFromForeignArchivesReport from '@/components/reports/CountOfUsedCopiesOfDocumentsFromForeignArchives.vue';
import WorkDoneOnDigitalObjectsCombinedReport from '@/components/reports/WorkDoneOnDigitalObjectsCombined.vue';
import SpecialRegistrationListReport from '@/components/reports/SpecialRegistrationList.vue';
import NumberOfDocumentsOrderedByReaderReport from '@/components/reports/NumberOfDocumentsOrderedByReader.vue';
import NumberOfDocumentsOrderedByEmployeeReport from '@/components/reports/NumberOfDocumentsOrderedByEmployee.vue';
import MostUsedRequestEntitiesReport from '@/components/reports/MostUsedRequestEntitiesReport.vue';
import ActiveProcessesReport from '@/components/reports/ActiveProcessesReport.vue';
import InventoryReport from '@/components/reports/Inventory.vue';
import ListOfRoughDocuments from '@/components/reports/ListOfRoughDocuments.vue';
import DigitalDocumentsUsageReport from '@/components/reports/DigitalDocumentsUsageReport.vue';
import ListOfPartialReceiptsInArchiveReport from '@/components/reports/ListOfPartialReceiptsInArchive.vue';
import UserActionsJournalReport from '@/components/reports/UserActionsJournal.vue';
import NumberOfArchiveEntitiesOrderedByReaderReport from '@/components/reports/NumberOfArchiveEntitiesOrderedByReaderReport.vue';
import NumberOfArchiveEntitiesOrderedByEmployeeReport from '@/components/reports/NumberOfArchiveEntitiesOrderedByEmployeeReport.vue';
import CardForm1Data from '@/components/reports/CardForm1Data.vue';
import CardForm1AData from '@/components/reports/CardForm1AData.vue';
import FundsData from '@/components/reports/FundsData.vue';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    components: { Loader },
    name: 'BaseReport',
    props: {
        componentName: {
            type: String,
            required: true,
        },
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
    setup(props) {
        const component = shallowRef();
        const cancel = ref(false);
        const isLoading = ref(false);
        const loadingChange = (loading: boolean) => {
            isLoading.value = loading;
            if (!loading) {
                cancel.value = false;
            }
        };

        const onCancleClick = () => {
            isLoading.value = false;
            cancel.value = true;
        };

        switch (props.componentName) {
            case 'funds':
                component.value = Funds;
                break;
            case 'fundsAvailability':
                component.value = FundsAvailability;
                break;
            case 'fundsList':
                component.value = FundsList;
                break;
            case 'fundMemoriesListInternalReport':
                component.value = FundMemoriesListInternalReport;
                break;
            case 'fundMemoriesList':
                component.value = FundMemoriesList;
                break;
            case 'partialReceiptsList':
                component.value = PartialReceiptsList;
                break;
            case 'receiptsList':
                component.value = ReceiptsList;
                break;
            case 'workListForPriorityRestoration':
                component.value = WorkListForPriorityRestoration;
                break;
            case 'inventoryBook':
                component.value = InventoryBook;
                break;
            case 'accountAndDescriptionOfFilmDocumentsBook':
                component.value = AccountAndDescriptionOfFilmDocumentsBook;
                break;
            case 'insuranceFundOfCopiesOfForeignArchives':
                component.value = InsuranceFundOfCopiesOfForeignArchives;
                break;
            case 'inventoryBookOfCopiesFromForeignArchives':
                component.value = inventoryBookOfCopiesFromForeignArchives;
                break;
            case 'compilationAndNTOOfEDocuments':
                component.value = compilationAndNTOOfEDocuments;
                break;
            case 'registerOfDigitizedDocumentsReport':
                component.value = RegisterOfDigitizedDocumentsReport;
                break;
            case 'countOfUsedCopiesOfDocumentsFromForeignArchivesReport':
                component.value = CountOfUsedCopiesOfDocumentsFromForeignArchivesReport;
                break;
            case 'workDoneOnDigitalObjectsCombinedReport':
                component.value = WorkDoneOnDigitalObjectsCombinedReport;
                break;
            case 'specialRegistrationListReport':
                component.value = SpecialRegistrationListReport;
                break;
            case 'numberOfArchiveEntitiesOrderedByReaderReport':
                component.value = NumberOfArchiveEntitiesOrderedByReaderReport;
                break;
            case 'numberOfArchiveEntitiesOrderedByEmployeeReport':
                component.value = NumberOfArchiveEntitiesOrderedByEmployeeReport;
                break;
            case 'mostUsedRequestEntitiesReport':
                component.value = MostUsedRequestEntitiesReport;
                break;
            case 'numberOfDocumentsOrderedByReaderReport':
                component.value = NumberOfDocumentsOrderedByReaderReport;
                break;
            case 'numberOfDocumentsOrderedByEmployeeReport':
                component.value = NumberOfDocumentsOrderedByEmployeeReport;
                break;
            case 'activeProcessesReport':
                component.value = ActiveProcessesReport;
                break;
            case 'inventoryReport':
                component.value = InventoryReport;
                break;
            case 'listOfRoughDocuments':
                component.value = ListOfRoughDocuments;
                break;
            case 'digitalDocumentsUsageReport':
                component.value = DigitalDocumentsUsageReport;
                break;
            case 'listOfPartialReceiptsInArchiveReport':
                component.value = ListOfPartialReceiptsInArchiveReport;
                break;
            case 'userActionsJournalReport':
                component.value = UserActionsJournalReport;
                break;
            case 'CardForm1Data':
                component.value = CardForm1Data;
                break;
            case 'CardForm1AData':
                component.value = CardForm1AData;
                break;
            case 'fundsData':
                component.value = FundsData;
                break;
            // case 'workDoneOnDigitalObjectsReport':
            //     component.value = WorkDoneOnDigitalObjects;
            //     break;
        }

        return { onCancleClick, cancel, component, isLoading, loadingChange };
    },
});
</script>

<style lang="scss" scoped>
// :deep(.multiselect) {
//     min-height: 38px;
// }

:deep(.reportFieldHeight) {
    height: 96px;
}

:deep(.reportFieldwithCheckbox) {
    display: flex;
    align-items: center;
}

:deep(.width100Percent) {
    width: 100%;
}

:deep(.v-checkbox) {
    padding-top: 5px;
}

:deep(.flexStart) {
    align-self: flex-start;
}

:deep(.table-responsive) {
    border: 1px solid var(--ISDA-main-color1);
}

:deep(.text-left) {
    background-color: var(--ISDA-main-color2) !important;
    color: var(--ISDA-main-color1) !important;
}

:deep(.text-undefined) {
    background-color: white !important;
}

:deep(.page-link) {
    color: rgb(var(--v-theme-on-surface));
}

:deep(.active a) {
    color: rgb(var(--v-theme-on-primary));
    background-color: rgb(var(--v-theme-primary));
    border-color: rgba(var(--v-border-color));
}

:deep(.col-md-5) {
    padding: 1px;
}

:deep(.align-items-baseline) {
    height: 40px !important;
    padding-right: 15px;
    border-radius: 6px;
    box-shadow: gray 0px 1px 3px 0px;
}

:deep(.col-md-12 > div:nth-of-type(2)) {
    margin-top: 20px;
}

:deep(.mx-3) {
    background-color: var(--ISDA-main-color4) !important;
    color: var(--ISDA-main-color1) !important;
}

:deep(#btnExportGrid) {
    color: var(--ISDA-main-color1) !important;
    background-color: var(--ISDA-main-color4) !important;
}

:deep(.multiselect-tag) {
    background-color: var(--ISDA-main-color4) !important;
}

:deep(.firstCol) {
    background-color: var(--ISDA-main-color2) !important;
    color: var(--ISDA-main-color1) !important;
    font-weight: bold;
}

:deep(li.is-selected) {
    background-color: var(--ISDA-main-color4) !important;
}

:deep(.mx-3),
:deep(#btnExportGrid) {
    box-shadow: none !important;
    border: 1px solid lightgray !important;
    background-color: white !important;
}

:deep(.form-select) {
    border: none;
}

:deep(a) {
    color: var(--ISDA-main-color1) !important;
}

:deep(.table-responsive) {
    //position: relative !important;
    max-height: 600px;
    width: 100%;
    overflow-y: auto !important;
    overflow-x: auto !important;
    margin-right: 10px !important;
}

:deep(thead) {
    position: sticky !important;
    position: -webkit-sticky !important;
    top: 0px !important;
}
</style>
