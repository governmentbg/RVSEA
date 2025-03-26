<template>
    <v-container fluid>
        <Loader :isLoading="isLoading" :showCancel="true" @cancel="onCancleClick" />
        <component :is="component" @loadingChange="loadingChange" :isCanceled="cancel" />
    </v-container>
</template>
<script lang="ts">
import { defineComponent, ref, shallowRef } from 'vue';
import Funds from '@/components/reports/Funds.vue';
import FundsData from '@/components/reports/FundsData.vue';
import FundMemories from '@/components/reports/FundMemories.vue';
import RegisterOfDigitalObjects from '@/components/reports/RegisterOfDigitalObjectsPublic.vue';
import PartialReceipts from '@/components/reports/PartialReceiptsPublic.vue';
import FundsList from '@/components/reports/FundsList.vue';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'BaseReport',
    components: { Loader },
    props: {
        componentName: {
            type: String,
            required: true,
        },
    },
    setup(props) {
        const component = shallowRef();
        const isLoading = ref(false);
        const cancel = ref(false);

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
            case 'fundsData':
                component.value = FundsData;
                break;
            case 'fundMemories':
                component.value = FundMemories;
                break;
            case 'registerOfDigitalObjects':
                component.value = RegisterOfDigitalObjects;
                break;
            case 'partialReceipts':
                component.value = PartialReceipts;
                break;
            case 'fundsList':
                component.value = FundsList;
                break;
        }

        return { component, isLoading, loadingChange, onCancleClick, cancel };
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
    text-align: center;
}

:deep(.thead-light span) {
    text-align: center !important;
}

:deep(.text-left) {
    background-color: var(--ISDA-main-color2) !important;
    color: var(--ISDA-main-color1) !important;
}

:deep(.text-undefined) {
    background-color: white !important;
}

:deep(.page-link) {
    color: var(--ISDA-main-color4) !important;
}

:deep(.active a) {
    color: var(--ISDA-main-color1) !important;
    background-color: var(--ISDA-main-color4) !important;
    border-color: var(--ISDA-main-color4) !important;
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

:deep(li.v-breadcrumbs-item--disabled) {
    padding: 5px 8px;
    border-radius: 10px;
    background-color: var(--ISDA-main-color2) !important;
    color: var(--ISDA-main-color4) !important;
}

:deep(.mx-3),
:deep(#btnExportGrid),
:deep(div:has(.form-control) > .btn) {
    box-shadow: none !important;
    border: 1px solid lightgray !important;
    background-color: white !important;
}

:deep(.form-select) {
    border: none;
}

:deep(.pagination a) {
    color: var(--ISDA-main-color1) !important;
}

:deep(.table-responsive) {
    position: relative !important;
    max-height: 600px;
    width: 100%;
    overflow-y: auto !important;
    overflow-x: auto !important;
}

:deep(thead) {
    position: sticky !important;
    position: -webkit-sticky !important;
    top: 0px !important;
}
</style>
