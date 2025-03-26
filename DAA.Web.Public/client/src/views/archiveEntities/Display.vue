<template>
<Loader :isLoading="isLoading" />
    <Breadcrumbs :items="breadcrumbItems" />

    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('archiveEntities.display') }}</v-card-title>
        <v-container>
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel value="archivalEntityBasicInfo">
                    <v-expansion-panel-title>{{
                        t('archiveEntities.panels.archivalEntityBasicInfo')
                    }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldArchive"
                                    :label="t('archiveEntities.archive')"
                                    v-model="archivalEntityData.archiveName"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldFundNumber"
                                    :label="t('archiveEntities.fund')"
                                    v-model="archivalEntityData.fundNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldInventoryNumber"
                                    :label="t('archiveEntities.inventory')"
                                    v-model="archivalEntityData.inventoryNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldNumber"
                                    :label="t('archiveEntities.columns.number')"
                                    v-model="archivalEntityData.number"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="elementsOfDescriptionOnArchiveEntityLevel" v-if="loadClass">
                    <v-expansion-panel-title>{{
                        t('archiveEntities.panels.elementsOfDescriptionOnArchiveEntityLevel')
                    }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDescriptionLevel"
                                    :label="t('archiveEntities.columns.descriptionLevel')"
                                    v-model="archivalEntityData.descriptionLevelText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col :class="possibleEmptyFields.title">
                                <text-area-field
                                    name="fldTitle"
                                    :label="t('archiveEntities.columns.title')"
                                    v-model="archivalEntityData.title"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="datePlaceOfCreation">
                    <v-expansion-panel-title>{{
                        t('archiveEntities.panels.datePlaceOfCreation')
                    }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <v-col class="col-12">
                                    <Switch
                                        v-model="archivalEntityData.hasNoChronologicalScope"
                                        :label="t('funds.columns.chronologicalScope')"
                                        :large="false"
                                        :showLabel="true"
                                        :disabled="true"
                                    />
                                </v-col>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <label>{{ t('funds.columns.startDate') }}</label>
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateDay"
                                    :label="t('common.day')"
                                    v-model="archivalEntityData.startDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateMonth"
                                    :label="t('common.month')"
                                    v-model="archivalEntityData.startDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateYear"
                                    :label="t('common.year')"
                                    v-model="archivalEntityData.startDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <label>{{ t('funds.columns.endDate') }}</label>
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateDay"
                                    :label="t('common.day')"
                                    v-model="archivalEntityData.endDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateMonth"
                                    :label="t('common.month')"
                                    v-model="archivalEntityData.endDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateYear"
                                    :label="t('common.year')"
                                    v-model="archivalEntityData.endDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldApproximateChronologicalScope"
                                    :label="t('archiveEntities.columns.approximateChronologicalScope')"
                                    v-model="archivalEntityData.approximateChronologicalScope"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-8" :class="possibleEmptyFields.location">
                                <text-area-field
                                    name="fldLocation"
                                    :label="t('archiveEntities.columns.placeOfCreation')"
                                    v-model="archivalEntityData.location"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="storage" v-if="loadClass">
                    <v-expansion-panel-title>{{ t('archiveEntities.panels.storage') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldBytes"
                                    :label="t('archiveEntities.columns.bytes')"
                                    v-model="formattedBytes"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldDocumentCount"
                                    :label="t('archiveEntities.columns.documentCount')"
                                    v-model="archivalEntityData.documentCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-6">
                                <text-field
                                    name="fldFramesCount"
                                    :label="t('archiveEntities.columns.framesCount')"
                                    v-model="archivalEntityData.frameCount"
                                    :readonly="true"
                                />
                            </v-col>                            
                            <v-col class="col-6">
                                <text-field
                                    name="fldSheetsCount"
                                    :label="t('archiveEntities.columns.sheetsCount')"
                                    v-model="archivalEntityData.sheetCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-6">
                                <text-field
                                    name="fldMagneticTapesCount"
                                    :label="t('archiveEntities.columns.magneticTapesQuantity')"
                                    v-model="archivalEntityData.tapeCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-6">
                                <text-field
                                    name="fldMicrofilmsQuantity"
                                    :label="t('archiveEntities.columns.microfilmsQuantity')"
                                    v-model="archivalEntityData.microfilmCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-6">
                                <text-field
                                    name="fldVideoTapesCount"
                                    :label="t('archiveEntities.columns.videoTapesQuantity')"
                                    v-model="archivalEntityData.videoTapeCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-6">
                                <text-field
                                    name="fldDigitalDevicesCount"
                                    :label="t('archiveEntities.columns.digitalDevicesQuantity')"
                                    v-model="archivalEntityData.digitalDeviceCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>                        
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldFileType"
                                    :label="t('archiveEntities.columns.fileType')"
                                    v-model="archivalEntityData.fileTypeText"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOther"
                                    :label="t('archiveEntities.columns.other')"
                                    v-model="archivalEntityData.otherMetrics"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldSizeCm"
                                    :label="t('archiveEntities.columns.sizeCm')"
                                    v-model="archivalEntityData.sizeCm"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldScale"
                                    :label="t('archiveEntities.columns.scale')"
                                    v-model="archivalEntityData.scaling"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.extendedDescription">
                                <text-area-field
                                    name="fldExtendedDescription"
                                    :label="t('archiveEntities.columns.extendedDescription')"
                                    v-model="archivalEntityData.description"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOriginality"
                                    :label="t('archiveEntities.columns.originality')"
                                    v-model="archivalEntityData.originalityText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldCreationMethod"
                                    :label="t('archiveEntities.columns.creationMethod')"
                                    v-model="archivalEntityData.creationMethodText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldLanguage"
                                    :label="t('archiveEntities.columns.language')"
                                    v-model="archivalEntityData.languageText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.specifics">
                                <text-area-field
                                    name="fldSpecifics"
                                    :label="t('archiveEntities.columns.specifics')"
                                    v-model="archivalEntityData.features"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="copiesEligibility">
                    <v-expansion-panel-title>{{
                        t('archiveEntities.panels.copiesEligibility')
                    }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldMicrofilmedCopiesCount"
                                    :label="t('archiveEntities.columns.microfilm')"
                                    v-model="archivalEntityData.microfilmedCopyCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDigitalCopy"
                                    :label="t('archiveEntities.columns.digitalCopy')"
                                    v-model="archivalEntityData.digitizedCopyCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldXeroxCopy"
                                    :label="t('archiveEntities.columns.xeroxCopy')"
                                    v-model="archivalEntityData.paperCopyCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldNegativeFramesCount"
                                    :label="t('archiveEntities.columns.negativeFrames')"
                                    v-model="archivalEntityData.negativeFrameCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldPositiveFramesCount"
                                    :label="t('archiveEntities.columns.positiveFrames')"
                                    v-model="archivalEntityData.positiveFrameCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="eligibilityChange">
                    <v-expansion-panel-title>{{
                        t('archiveEntities.panels.eligibilityChange')
                    }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldEnrolledLinearMeters"
                                    :label="t('archiveEntities.columns.enrolledLinearMeters')"
                                    v-model="archivalEntityData.enrolledLinearMeters"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldEnrolledDocumentCount"
                                    :label="t('archiveEntities.columns.enrolledDocumentsCount')"
                                    v-model="archivalEntityData.enrolledDocumentCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDeductedLinearMeters"
                                    :label="t('archiveEntities.columns.deductedLinearMeters')"
                                    v-model="archivalEntityData.deductedLinearMeters"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDeductedDocumentsCount"
                                    :label="t('archiveEntities.columns.deductedDocumentsCount')"
                                    v-model="archivalEntityData.deductedDocumentCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDeductedMB"
                                    :label="t('archiveEntities.columns.deductedMB')"
                                    v-model="archivalEntityData.deductedBytes"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="history">
                    <v-expansion-panel-title>{{ t('archiveEntities.panels.history') }}</v-expansion-panel-title>
                    <v-row>
                        <v-col class="col-12">
                            <text-field
                                name="fldStatus"
                                :label="t('archiveEntities.columns.status')"
                                v-model="archivalEntityData.status"
                                :readonly="true"
                            />
                        </v-col>
                    </v-row>
                    <v-expansion-panel-text> </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="documentsInInventory">
                    <v-expansion-panel-title>{{ t('archiveEntities.panels.documents') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row align="center">
                            <v-col class="col-12 col-md-6 col-lg-6">
                                <text-field
                                    onkeypress="return event.charCode >= 48"
                                    :label="t('documents.columns.pageFrom')"
                                    v-model="searchStartSheetNumber"
                                    validation="numeric"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6 col-lg-6">
                                <text-field
                                    onkeypress="return event.charCode >= 48"
                                    :label="t('documents.columns.pageTo')"
                                    v-model="searchEndSheetNumber"
                                    validation="numeric"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field :label="t('archiveEntities.keyWords')" v-model="searchKeyword" />
                            </v-col>
                            <v-col class="col-12 col-lg-6 d-flex gap-2 justify-content-start">
                                <v-btn @click="searchDocuments" variant="flat"
                                    >{{ t('common.search') }}
                                    <v-tooltip activator="parent" location="bottom">
                                        {{ t('common.searchTooltip') }}
                                    </v-tooltip>
                                </v-btn>
                                <v-btn class="cancel" @click="clearAllSearchCriteria" variant="flat"
                                    >{{ t('common.clear') }}
                                    <v-tooltip activator="parent" location="bottom">
                                        {{ t('common.clearTooltip') }}
                                    </v-tooltip>
                                </v-btn>
                            </v-col>
                        </v-row>
                        <v-row v-if="documentData.totalCount > 0">
                            <v-col>
                                <v-list variant="text">
                                    <v-list-item
                                        v-for="item in documentData.items"
                                        :key="item"
                                        :title="
                                            t('documents.listTemplate', {
                                                descriptionLevel: item.descriptionLevelText,
                                                number: item.number,
                                                title: trimText(item.title, 100),
                                                chronologicalScope: item.approximateChronologicalScope,
                                            })
                                        "
                                        :subtitle="item.statusText + (item.hasDigitizedDigitalObjects === true ? ' / ' + t('documents.activeDigitalObject') : '')"
                                        :to="{
                                            name: 'DisplayDocument',
                                            params: { id: item.systemIdentifier },
                                            query: {
                                                hasExternalSource: item.hasExternalSource,
                                                externalIdentifier: item.externalIdentifier,
                                            },
                                        }"
                                    >
                                    </v-list-item>
                                </v-list>
                            </v-col>
                        </v-row>
                        <v-row v-else>
                            <v-col>
                                {{ t('search.emptyResult') }}
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col>
                                <Pager
                                    v-if="documentData.totalCount > pagerOptions.itemsPerPage"
                                    :initialPage="pagerOptions.pageNumber"
                                    :initialPageSize="pagerOptions.itemsPerPage"
                                    :totalPages="pagerOptions.totalPages"
                                    @change="changePage"
                                    ref="pager"
                                ></Pager>
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, Ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { trimText, formatBytesToMB  } from '@/helpers/format.helper';
import { Message } from '@/models/notification';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { IArchivalEntity } from '@/interfaces/archivalEntity';
import { ArchivalEntity } from '@/models/archivalEntity';
import { IDocument } from '@/interfaces/document';
import { PageSize, GridResponseModel, GridOptions } from '@/models/grid';
import archiveEntityService from '@/services/archivalEntity.service';
import documentService from '@/services/document.service';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import Pager from '@/components/grid/pager.vue';
import { useRouter } from 'vue-router';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'DisplayArchiveEntity',
    components: {
        Loader,
        TextField,
        Switch,
        Pager,
        TextAreaField,
        Breadcrumbs,
    },
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
    setup(props) {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;

        const panel = ref([
            'archivalEntityBasicInfo',
            'elementsOfDescriptionOnArchiveEntityLevel',
            'datePlaceOfCreation',
            'storage',
            'copiesEligibility',
            'eligibilityChange',
            'history',
            'chronologicalScope',
            'externalSource',
            'documentsInInventory',
        ]);

        const possibleEmptyFields = {
            title: '',
            location: '',
            extendedDescription: '',
            specifics: '',
        };

        const lowClass = 'low';
        const loadClass = ref(false);
        const isLoading = ref(false);

        const formattedBytes = computed(() => {
            return formatBytesToMB(archivalEntityData.value.bytes || 0);
        });

        const router = useRouter();

        const goBack = () => {
            router.go(-1);
        };

        const archivalEntityData = ref<IArchivalEntity>(new ArchivalEntity());
        const getArchivalEntityData = async () => {
            try {
                isLoading.value = true;
                archivalEntityData.value = await archiveEntityService.displayArchivalEntity(
                    props.id,
                    props.hasExternalSource,
                    props.externalIdentifier
                );

                if (!archivalEntityData.value.title) {
                    possibleEmptyFields.title = lowClass;
                }
                if (!archivalEntityData.value.location) {
                    possibleEmptyFields.location = lowClass;
                }
                if (!archivalEntityData.value.description) {
                    possibleEmptyFields.extendedDescription = lowClass;
                }
                if (!archivalEntityData.value.features) {
                    possibleEmptyFields.specifics = lowClass;
                }

                if (archivalEntityData.value.resultMessage && archivalEntityData.value.resultMessage === 'ISDADataCannotBeDisplayed') {
                    message.value = new Message({
                        text: t('warnings.ISDADataCannotBeDisplayed'),
                        display: true,
                        type: 'warning',
                    });
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

        const breadcrumbItems = computed(() => [
            {
                title: archivalEntityData.value.archiveName,
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('funds.fund'),
                disabled: false,
                to: {
                    name: 'DisplayFund',
                    params: { id: archivalEntityData.value.fundSystemIdentifier },
                    query: {
                        hasExternalSource: archivalEntityData.value.fundHasExternalSource,
                        externalIdentifier: archivalEntityData.value.fundExternalIdentifier,
                    },
                },
            },
            {
                title: t('inventories.inventory'),
                disabled: false,
                to: {
                    name: 'DisplayInventory',
                    params: { id: archivalEntityData.value.inventorySystemIdentifier },
                    query: {
                        hasExternalSource: archivalEntityData.value.inventoryHasExternalSource,
                        externalIdentifier: archivalEntityData.value.inventoryExternalIdentifier,
                    },
                },
            },
            {
                title: t('archiveEntities.archiveEntity'),
                disabled: true,
            },
        ]);
        const pagerOptions = ref<GridOptions>({
            sortBy: '',
            sortDesc: false,
            page: 1,
            itemsPerPage: PageSize.twenty,
            sortByType: '',
            totalPages: 1
        });

        const initPagerOptions = () => {
            pagerOptions.value = new GridOptions({
                sortBy: '',
                sortDesc: false,
                page: 1,
                itemsPerPage: PageSize.twenty,
                sortByType: '',
                searchString: '',
                totalPages: 1
            });
        };

        const changePage = async (pageNumber: number, pageSize: number) => {
            pagerOptions.value.page = pageNumber;
            pagerOptions.value.itemsPerPage = pageSize;

            await getDocumentData();
        };

        const documentData = ref<GridResponseModel<IDocument>>(
            new GridResponseModel<IDocument>({ totalCount: 0, items: [] })
        );
        const getDocumentData = async (
            keywords?: string,
            number?: string,
            startSheetNumber?: number,
            endSheetNumber?: number
        ) => {
            try {
                isLoading.value = true;
                if (keywords || number) {
                    initPagerOptions();
                }
                if (keywords) {
                    pagerOptions.value.searchString = keywords;
                }
                const result = await documentService.getArchivalEntityDocuments(
                    pagerOptions.value,
                    archivalEntityData.value.systemIdentifier,
                    props.hasExternalSource,
                    props.externalIdentifier,
                    number,
                    startSheetNumber,
                    endSheetNumber
                );

                if(result){
                    documentData.value = result;
                    documentData.value.items.sort((a, b) =>
                        a.number != undefined && b.number != undefined 
                        ? a.number - b.number
                        : 0
                    );
                    pagerOptions.value.totalPages = documentData.value.totalCount < pagerOptions.value.itemsPerPage
                            ? 1
                            : Math.ceil(documentData.value.totalCount / pagerOptions.value.itemsPerPage)
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

        const searchKeyword = ref('');
        const searchNumber = ref('');
        const searchStartSheetNumber = ref();
        const searchEndSheetNumber = ref();

        const searchDocuments = async () => {
            await getDocumentData(
                searchKeyword.value,
                searchNumber.value,
                searchStartSheetNumber.value,
                searchEndSheetNumber.value
            );
        };

        const clearAllSearchCriteria = async () => {
            searchKeyword.value = '';
            searchNumber.value = '';
            initPagerOptions();
            await getDocumentData();
        };

        onMounted(async () => {
            window.scrollTo(0, 0);
            await getArchivalEntityData();
            await getDocumentData();
            loadClass.value = true;
        });

        return {
            t,
            goBack,
            searchDocuments,
            changePage,
            clearAllSearchCriteria,
            trimText,
            breadcrumbItems,
            panel,
            archivalEntityData,
            documentData,
            message,
            pagerOptions,
            searchNumber,
            searchKeyword,
            searchStartSheetNumber,
            searchEndSheetNumber,
            possibleEmptyFields,
            loadClass,
            formattedBytes,
            isLoading,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/index.scss';
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs-ae.scss';

:deep(.v-container),
.v-container,
:deep(.v-expansion-panels),
:deep(.v-expansion-panel-text),
:deep(.v-expansion-panel-title) {
    margin: 0px !important;
}
:deep(.float-right button) {
    margin: 0px;
}

.low,
:deep(.low div),
:deep(.low textarea) {
    height: 50px;
    margin-bottom: 25px;
}
</style>
