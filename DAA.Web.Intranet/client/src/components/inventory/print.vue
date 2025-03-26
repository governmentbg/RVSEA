<template>
    <Loader :isLoading="isLoading" />
    <div>
        <v-row class="col-12 d-print-none">
            <v-col cols="6">
                <v-menu class="d-print-none">
                    <template v-slot:activator="{ props }">
                        <v-btn v-bind="props">{{ t('common.exportTo') }}</v-btn>
                    </template>
                    <v-list>
                        <v-list-item class="col-12 cursor">
                            <v-list-item-title class="d-print-none button" @click="exportHTMLtoWord"
                                >{{ t('common.exportToWord') }}
                            </v-list-item-title>
                        </v-list-item>
                        <v-list-item class="col-12 cursor">
                            <v-list-item-title class="d-print-none button" @click="printButton"
                                >{{ t('common.exportToPdf') }}
                            </v-list-item-title></v-list-item
                        >
                    </v-list>
                </v-menu>
            </v-col>
            <v-col>
                <back-btn class="d-print-none" style="float: right" @click="goBack"
                    >{{ t('common.back') }}
                    <v-tooltip activator="parent" location="bottom">
                        {{ t('common.back') }}
                    </v-tooltip>
                </back-btn>
            </v-col>
        </v-row>
        <div id="div" style="margin: auto; width: 20.5cm">
            <h4 style="text-align: center; font-family: 'Times New Roman '">ИСТОРИЧЕСКА СПРАВКА</h4>
            <h4 style="text-align: start; font-family: 'Times New Roman '">I. ИСТОРИЯ НА ФОНДООБРАЗУВАТЕЛЯ</h4>
            <p style="text-align: start">
                {{ inventoryData.fundCreatorBiographicalHistory }}
            </p>
            <h4 style="text-align: start; font-family: 'Times New Roman '">II. ИСТОРИЯ НА ФОНДА</h4>
            <p style="text-align: start; page-break-after: always">{{ fundHistory }}</p>
            <h4 style="text-align: center; font-family: 'Times New Roman '">КЛАСИФИКАЦИОННА СХЕМА</h4>
            <p style="text-align: start; page-break-after: always">{{ inventoryData.classificationScheme }}</p>
            <h4 style="text-align: center; font-family: 'Times New Roman '">СПИСЪК НА СЪКРАЩЕНИЯТА</h4>
            <p style="text-align: start; page-break-after: always">{{ inventoryData.abbreviationList }}</p>
            <div>
                <InventoryPrintHeader v-if="!headerComponent" />
                <component
                    v-if="headerComponent && directorName"
                    :is="headerComponent"
                    :directorName="'..............'"
                    :documentsProvider="'..............'"
                ></component>
                <br />
                <h4 style="text-align: center; font-family: 'Times New Roman '">
                    {{ inventoryData.archiveName }}
                    <br />
                    {{ fundTitle ?? '....................................' }}
                </h4>
                <br />
                <p
                    style="text-align: start; font-family: 'Times New Roman'; text-align: start"
                    class="ml-3"
                    v-for="(title, index) in splitTitles()"
                    :key="index"
                >
                    {{ index + 1 }}. {{ title }}
                </p>
                <br />
                <h4 style="text-align: center">ФОНД № {{ inventoryData.fundNumber ?? '' }}</h4>
                <h4 style="text-align: center">
                    ИНВЕНТАРЕН ОПИС № {{ inventoryData.number ?? '....' }}
                    {{ numberContainsArrayIndex(inventoryData.number) ? '' : componentName }}
                </h4>
                <h4 style="text-align: center">{{ inventorContentTypeText ?? '' }}</h4>
                <p style="text-align: center; font-family: 'Times New Roman'; text-justify: auto">
                    Описът включва електронни документи от {{ inventoryData.startDateYear ?? '' }} г. до
                    {{ inventoryData.endDateYear ?? '' }} г.
                </p>

                <br />
                <component v-if="archivalEntityData.items" :is="component" :items="archivalEntityData.items" />
                <p style="text-align: start; font-family: 'Times New Roman'; text-justify: auto">
                    РЕКАПИТУЛАЦИЯ: {{ archivalEntityData.totalCount }}
                    {{ archivalEntityData.totalCountInWords }} архивни единици.
                </p>
                <div v-if="isAssemblyProvess">
                    <p style="font-family: 'Times New Roman'; text-justify: auto; text-align: start">
                        <b>Постоянно действаща експертна комисия:</b>
                    </p>
                </div>
                <p v-if="isAssemblyProvess" style="font-family: 'Times New Roman'">
                    Председател:....................<br />
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;(.............)
                </p>
                <p v-if="isAssemblyProvess" style="font-family: 'Times New Roman'">
                    Членове:<br />
                    1.......................<br />
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(.............)<br />
                    2.......................<br />
                    &nbsp;&nbsp;&nbsp;&nbsp; (.............)<br />
                </p>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent, inject, onMounted, ref, Ref, shallowRef } from 'vue';
import { useI18n } from 'vue-i18n';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import archiveEntityService from '@/services/archivalEntity.service';
import { IMessage } from '@/interfaces/notification';
import { IArchivalEntity } from '@/interfaces/archivalEntity';
import { GridOptions, GridResponseModel, PageSize } from '@/models/grid';
import inventoryService from '@/services/inventory.service';
import { IInventory } from '@/interfaces/inventory';
import { Inventory } from '@/models/inventory';
import { formatDate, getArchiveCityName } from '@/helpers/format.helper';
import router from '@/router';
import IndexE from '@/components/inventory/printInventoryTemplates/indexE.vue';
import IndexK from '@/components/inventory/printInventoryTemplates/indexK.vue';
import IndexN from '@/components/inventory/printInventoryTemplates/indexN.vue';
import IndexP from '@/components/inventory/printInventoryTemplates/indexP.vue';
import ExtendedHeader from '@/components/inventory/printInventoryTemplates/extendedHeader.vue';
import BasicHeader from '@/components/inventory/printInventoryTemplates/basicHeader.vue';
import { returnWordFromHtml } from '@/helpers/word.helper';
import { InventoryArray, InventoryExternalArray } from '@/enums/inventory';
import archiveService from '@/services/archive.service';
import { ProcessType } from '@/enums/process';
import Loader from '@/components/loader/loader.vue';
import InventoryPrintHeader from '@/components/inventory/printInventoryTemplates/inventoryPrintHeader.vue';
import fundService from '@/services/fund.service';
export default defineComponent({
    name: 'PrintInventoryTemplate',
    components: {
        Loader,
        InventoryPrintHeader,
    },
    props: {
        componentName: {
            type: String,
            required: true,
        },
        processTypeId: {
            type: Number,
            requred: true,
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
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const archivalEntityData = ref<GridResponseModel<IArchivalEntity>>(
            new GridResponseModel<IArchivalEntity>({ totalCount: 0, items: [] })
        );
        const inventoryData = ref<IInventory>(new Inventory());
        const pagerOptions = ref<GridOptions>({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: PageSize.fiveTousand,
            sortByType: '',
        });
        const component = shallowRef();
        const headerComponent = shallowRef();
        const directorName = ref<string>();
        const inventorContentTypeText = ref<string>();
        const isAssemblyProvess = ref<boolean>(false);
        const fundTitle = ref<string>();
        const fundHistory = ref('');
        const isLoading = ref(false);

        const numberContainsArrayIndex = (val: string = '') =>
            val != '' && val != null ? /^[\wА-Я]+$/.test(val) : false;

        const splitTitles = () => {
            let arr = [];
            if (inventoryData.value.externalIdentifier != null && inventoryData.value.hasExternalSource) {
                arr = inventoryData.value.fundCreatorTitleHistory?.split('\r\n') ?? [];
                fundTitle.value = arr[0];
            } else {
                arr = inventoryData.value.fundCreatorTitleHistory?.split(';') ?? [];
                fundTitle.value = arr[0];
            }
            return arr;
        };
        const getInventoryArchivalEntityData = async () => {
            try {
                const result = await archiveEntityService.getInventoryArchivalEntities(
                    pagerOptions.value,
                    props.id,
                    props.hasExternalSource,
                    props.externalIdentifier
                );
                if (result) {
                    archivalEntityData.value = result;
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };
        const getInventoryData = async () => {
            isLoading.value = true;
            try {
                inventoryData.value = await inventoryService.displayInventory(
                    props.id,
                    props.hasExternalSource,
                    props.externalIdentifier
                );
                directorName.value = await archiveService.getDiroctorNameByArchiveId(inventoryData.value.archiveId!);
                await getInventoryArchivalEntityData();
                await getFundData();
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                isLoading.value = false;
            }
        };
        const goBack = () => {
            router.go(-1);
        };
        const printButton = () => {
            window.print();
        };
        const exportHTMLtoWord = () => {
            returnWordFromHtml(document.getElementById('div')!.innerHTML);
        };
        const getFundData = async () => {
            try {
                const result = await fundService.displayFund(
                    inventoryData.value.fundSystemIdentifier,
                    inventoryData.value.fundHasExternalSource,
                    inventoryData.value.fundExternalIdentifier
                );
                if (result.history) {
                    fundHistory.value = result.history;
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            } finally {
                isLoading.value = false;
            }
        };
        switch (props.processTypeId) {
            case ProcessType.AddInventory:
            case ProcessType.AddRawInventory:
            case ProcessType.AddRawInventoryRaw:
            case ProcessType.AddFundAndInventory:
            case ProcessType.AddRawFundAndRawInventory:
            case ProcessType.ProcessFundWithRawInventory:
                isAssemblyProvess.value = true;
                headerComponent.value = ExtendedHeader;
                break;
            case ProcessType.RefineData:
            case ProcessType.ReconstructFundData:
            case ProcessType.ProcessRawFundWithRawInventory:
            case ProcessType.FilmRegisterCard:
                headerComponent.value = BasicHeader;
                break;
            default:
                isAssemblyProvess.value = false;
                headerComponent.value = undefined;
                break;
        }
        switch (props.componentName) {
            case InventoryArray.E:
            case InventoryExternalArray.E:
            default:
                inventorContentTypeText.value = 'НА ЕЛЕКТРОННИ ДОКУМЕНТИ ЗА ПОСТОЯННО ЗАПАЗВАНЕ';
                component.value = IndexE;
                break;
            case InventoryArray.KE:
            case InventoryExternalArray.KE:
                inventorContentTypeText.value = ' НА ПРОЕКТИ НА ИЗДЕЛИЯ ЗА ПОСТОЯННО ЗАПАЗВАНЕ';
                component.value = IndexK;
                break;
            case InventoryExternalArray.TE:
            case InventoryArray.TE:
                inventorContentTypeText.value = 'НА ТЕХНОЛОГИЧНИ РАЗРАБОТКИ ЗА ПОСТОЯННО ЗАПАЗВАНЕ';
                component.value = IndexK;
                break;
            case InventoryExternalArray.NE:
            case InventoryArray.NE:
                inventorContentTypeText.value = 'НА ОТЧЕТИ ПО ТЕМИ ЗА ПОСТОЯННО ЗАПАЗВАНЕ';
                component.value = IndexN;
                break;
            case InventoryExternalArray.PE:
            case InventoryArray.PE:
                inventorContentTypeText.value = 'НА ПРОЕКТИ НА ОБЕКТИ ЗА ПОСТОЯННО ЗАПАЗВАНЕ';
                component.value = IndexP;
                break;
        }

        onMounted(async () => {
            getInventoryData();
        });

        return {
            t,
            splitTitles,
            isAssemblyProvess,
            fundHistory,
            printButton,
            formatDate,
            getArchiveCityName,
            exportHTMLtoWord,
            goBack,
            directorName,
            component,
            archivalEntityData,
            inventoryData,
            headerComponent,
            inventorContentTypeText,

            fundTitle,
            numberContainsArrayIndex,
            isLoading,
        };
    },
});
</script>
<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/index.scss';
.cursor {
    cursor: pointer;
}
</style>
