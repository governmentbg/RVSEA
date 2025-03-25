<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid>
        <v-row>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('funds')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.fundReport') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('fundsAvailability')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.fundsAvailability') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('fundsList')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.fundsList') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('fundMemoriesListInternalReport')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.fundMemoriesListInArchive') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('fundMemoriesList')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.memoriesList') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('partialReceiptsList')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.partialReceiptsList') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('receiptsList')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.receiptsList') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('workListForPriorityRestoration')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.workListForPriorityRestoration') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('inventoryBook')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.inventoryBook') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('accountAndDescriptionOfFilmDocumentsBook')"
                    ><i class="fas fa-file-circle-check" />{{
                        t('reports.AccountAndDescriptionOfFilmDocumentsBook')
                    }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('insuranceFundOfCopiesOfForeignArchives')"
                    ><i class="fas fa-file-circle-check" />{{
                        t('reports.insuranceFundOfCopiesOfForeignArchives')
                    }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('inventoryBookOfCopiesFromForeignArchives')"
                    ><i class="fas fa-file-circle-check" />{{
                        t('reports.inventoryBookOfCopiesFromForeignArchives')
                    }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('compilationAndNTOOfEDocuments')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.compilationAndNTOOfEDocuments') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('registerOfDigitizedDocumentsReport')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.registerOfDigitizedDocumentsReport') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('countOfUsedCopiesOfDocumentsFromForeignArchivesReport')"
                    ><i class="fas fa-file-circle-check" />{{
                        t('reports.countOfUsedCopiesOfDocumentsFromForeignArchivesReport')
                    }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('workDoneOnDigitalObjectsCombinedReport')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.workDoneOnDigitalObjectsCombinedReport') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('specialRegistrationListReport')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.specialRegistrationList') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('numberOfDocumentsOrderedByReaderReport')"
                    ><i class="fas fa-file-circle-check" />{{
                        t('reports.numberOfDocumentsOrderedByReaderReport')
                    }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('numberOfDocumentsOrderedByEmployeeReport')"
                    ><i class="fas fa-file-circle-check" />{{
                        t('reports.numberOfDocumentsOrderedByEmployeeReport')
                    }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('mostUsedRequestEntitiesReport')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.mostUsedRequestEntitiesReport') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('activeProcessesReport')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.activeProcessesReport') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('inventoryReport')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.inventoryReport') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('listOfRoughDocuments')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.listOfRoughDocuments') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('digitalDocumentsUsageReport')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.digitalDocumentsUsageReport') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('listOfPartialReceiptsInArchiveReport')"
                    ><i class="fas fa-file-circle-check" />{{
                        t('reports.listOfPartialReceiptsInArchiveReport')
                    }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('userActionsJournalReport')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.userActionsJournalReport') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('fundsData')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.fundDataReport') }}</v-btn
                >
            </v-col>
            <!-- <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('workDoneOnDigitalObjectsReport')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.workDoneOnDigitalObjectsReport') }}</v-btn
                >
            </v-col> -->
        </v-row>
    </v-container>
</template>
<script lang="ts">
import { defineComponent } from 'vue';
import { useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import { useI18n } from 'vue-i18n';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
export default defineComponent({
    name: 'Reports',
    components: { Breadcrumbs },
    props: {
        componentName: {
            type: String,
            required: true,
            default: '',
        },
    },
    setup() {
        const { t } = useI18n();
        const router = useRouter();
        const redirect = (componentName: string) => {
            useRedirect(router, 'BaseReport', { componentName });
        };
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('reports.reports'),
                disabled: true,
            },
        ];
        return { t, redirect, breadcrumbItems };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/breadcrumbs.scss';
button {
    height: fit-content !important;
}

button.btn-cust {
    display: inline-block;
    background-color: var(--ISDA-main-color2) !important;
    color: var(--ISDA-main-color1) !important;
    font-size: 14px;
    height: 50px !important;
    width: 100rem !important;
    overflow-wrap: break-word !important;
}

@media (max-width: 1600px) {
    button.btn-cust {
        font-size: 12px;
    }
}

i.fa-file-circle-check {
    position: absolute;
    left: 10px;
}

:deep(li.v-breadcrumbs-item:last-of-type) {
    padding: 5px 8px;
    border-radius: 10px;
    background-color: var(--ISDA-main-color2) !important;
    color: var(--ISDA-main-color4) !important;
}

.v-container {
    margin-top: 30px !important;
}
</style>
