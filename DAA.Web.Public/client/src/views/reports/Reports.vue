<template>
    <Breadcrumbs :items="breadcrumbItems" />

    <v-container fluid>
        <v-row class="row">
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('funds')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.fundReport') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('fundsData')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.fundDataReport') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('fundMemories')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.fundMemoryReport') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('registerOfDigitalObjects')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.registerOfDigitalObjects') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('partialReceipts')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.partialReceiptsReportInArchive') }}</v-btn
                >
            </v-col>
            <v-col class="col-sm-12 col-xl-6">
                <v-btn class="btn btn-cust" @click="redirect('fundsList')"
                    ><i class="fas fa-file-circle-check" />{{ t('reports.fundsList') }}</v-btn
                >
            </v-col>
        </v-row>
    </v-container>
</template>
<script lang="ts">
import { defineComponent, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import { useI18n } from 'vue-i18n';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
export default defineComponent({
    name: 'Reports',
    components: { Breadcrumbs },

    setup() {
        const { t } = useI18n();
        const router = useRouter();
        const redirect = (componentName: string) => {
            useRedirect(router, 'BaseReport', { componentName });
        };

        const breadcrumbItems = computed(() => [
            {
                title: t('navigation.left.home'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('navigation.left.reports'),
                disabled: true,
                to: { name: 'Reports' },
            },
        ]);
        return { t, redirect, breadcrumbItems };
    },
});
</script>

<style lang="scss" scoped>
button {
    height: fit-content !important;
}

// .row {
//     display: flex;
//     justify-content: center;
//     gap: 5px;
//   }

button.btn-cust {
    display: inline-block !important;
    background-color: var(--ISDA-main-color2) !important;
    color: var(--ISDA-main-color1) !important;
    font-size: 18px;
    height: 50px !important;
    width: 100% !important;
    margin: 0% !important;
}

i.fa-file-circle-check {
    position: absolute;
    left: 10px;
}

:deep(div:has(.v-breadcrumbs)),
:deep(.v-breadcrumbs) {
    position: fixed !important;
    z-index: 5;
    top: 60px !important;
    width: 98.5%;
    background-color: rgba(255, 255, 255, 0.8);
    border-bottom: 1px solid var(--ISDA-main-color4);
    height: 50px;
    padding-top: 20px;
}

:deep(.v-breadcrumbs-item--disabled) {
    padding: 5px 8px;
    border-radius: 10px;
    background-color: var(--ISDA-main-color2) !important;
    color: var(--ISDA-main-color4) !important;
}

.v-container {
    margin-top: 30px !important;
}
</style>
