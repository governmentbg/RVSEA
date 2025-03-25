<template>
    <Loader :isLoading="isLoading" />
    <Breadcrumbs :items="breadcrumbItems" />
    <v-card ref="processCard" class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('processes.panels.processInfo') }}</v-card-title>
        <v-container>
            <v-expansion-panels v-model="processPanel" multiple>
                <process-information-panel v-if="showProcessInfoPanel" value="processInfo" :process="activeProcessData">
                    <template #actions>
                        <edit-data-process-actions
                            v-if="
                                activeProcessData.processTypeId == ProcessType.EditData && isUserRelatedToActiveProcess
                            "
                            :process="activeProcessData"
                            @complete="goRefresh(true)"
                            @undochanges="goRefresh(true)"
                        />
                        <edit-fund-data-process-actions
                            v-if="
                                activeProcessData.processTypeId == ProcessType.EditFundData &&
                                isUserRelatedToActiveProcess
                            "
                            :process="activeProcessData"
                            @complete="goRefresh(true)"
                            @undochanges="goRefresh(true)"
                            @createReport="goRefresh"
                            @sendReport="goRefresh"
                            @changesRequired="goRefresh"
                            @addReport="goRefresh"
                            @sendforStandpoint="goRefresh(true)"
                            @sendForComment="goRefresh(true)"
                            @addComment="goRefresh"
                            @sendComment="goRefresh"
                            @setSessionAgenda="goRefresh(true)"
                            @approval="goRefresh"
                            @applyChanges="goEdit"
                            @sendChanges="goRefresh"
                            @revision="goRefresh"
                            @sendRevision="goRefresh"
                            @affirmation="goRefresh(true)"
                        />
                        <refine-data-process-actions
                            v-if="
                                activeProcessData.processTypeId == ProcessType.RefineData &&
                                isUserRelatedToActiveProcess
                            "
                            :process="activeProcessData"
                            @complete="goRefresh(true)"
                            @undochanges="goRefresh(true)"
                            @createReport="goRefresh"
                            @sendReport="goRefresh"
                            @changesRequired="goRefresh"
                            @addReport="goRefresh"
                            @sendforStandpoint="goRefresh(true)"
                            @sendForComment="goRefresh(true)"
                            @addComment="goRefresh"
                            @sendComment="goRefresh"
                            @setSessionAgenda="goRefresh(true)"
                            @approval="goRefresh"
                            @applyChanges="goEdit"
                            @sendChanges="goRefresh"
                            @revision="goRefresh"
                            @sendRevision="goRefresh"
                            @affirmation="goRefresh(true)"
                        />
                        <process-raw-inventories-process-actions
                            v-if="
                                (activeProcessData.processTypeId == ProcessType.ProcessRawFundWithRawInventory ||
                                    activeProcessData.processTypeId == ProcessType.ProcessFundWithRawInventory) &&
                                isUserRelatedToActiveProcess
                            "
                            :process="activeProcessData"
                            @undochanges="goRefresh(true)"
                            @createdInventories="goRefresh(true)"
                            @createReport="goRefresh(true)"
                            @addReport="goRefresh(true)"
                            @changesRequired="goRefresh(true)"
                            @sendforStandpoint="goRefresh(true)"
                            @sendForComment="goRefresh(true)"
                            @addComment="goRefresh(true)"
                            @sendComment="goRefresh(true)"
                            @setSessionAgenda="goRefresh(true)"
                            @applyChanges="goRefresh(true)"
                            @sendChanges="goRefresh"
                            @revision="goRefresh"
                            @sendRevision="goRefresh"
                            @approval="goRefresh(true)"
                            @sendToRegistrar="goRefresh(true)"
                            @complete="goRefresh(true)"
                        />
                        <reconstruct-fund-data-process-actions
                            v-if="
                                activeProcessData.processTypeId == ProcessType.ReconstructFundData &&
                                isUserRelatedToActiveProcess
                            "
                            :process="activeProcessData"
                            @complete="goRefresh(true)"
                            @undochanges="goRefresh(true)"
                            @accessRequest="goRefresh"
                            @accessSuspend="goRefresh(true)"
                            @applyChanges="goRefresh"
                            @createReport="goRefresh(true)"
                            @sendReport="goRefresh"
                            @changesRequired="goRefresh"
                            @addReport="goRefresh"
                            @sendforStandpoint="goRefresh(true)"
                            @sendForComment="goRefresh(true)"
                            @addComment="goRefresh"
                            @sendComment="goRefresh"
                            @setSessionAgenda="goRefresh(true)"
                            @approval="goRefresh"
                            @sendChanges="goRefresh"
                            @revision="goRefresh"
                            @sendRevision="goRefresh"
                            @affirmation="goRefresh(true)"
                            @sendForRegistration="goRefresh"
                            @registration="goRefresh"
                        />
                        <deduction-data-process-actions
                            v-if="
                                activeProcessData &&
                                activeProcessData.processTypeId == ProcessType.DeductData &&
                                isUserRelatedToActiveProcess &&
                                id &&
                                activeProcessData.fundSystemIdentifier
                            "
                            :id="id"
                            :process="activeProcessData"
                            :businessObjectType="processEntityTypes"
                        />
                    </template>
                </process-information-panel>
                <start-process-panel
                    v-if="showStartProcessPanel"
                    value="startProcess"
                    :entityType="entityType"
                    @startProcess="btnStartProcessClickHandler"
                    :entityHasExternalSource="fundData.hasExternalSource"
                    :readOnly="!enableStartProcessPanel"
                />
                <timeline-panel
                    v-if="showProcessInfoPanel && isUserRelatedToActiveProcess"
                    :processId="activeProcessData.id"
                    :showExpanded="false"
                />
            </v-expansion-panels>
            <eDocsProcessPanels
                class="processPanel"
                :process="activeProcessData"
                v-if="isDocsCollectingProcessVisible"
            ></eDocsProcessPanels>
            <DeductionProcessPanel
                v-if="
                    activeProcessData &&
                    activeProcessData.processTypeId == ProcessType.DeductData &&
                    isUserRelatedToActiveProcess &&
                    activeProcessData.fundSystemIdentifier
                "
                :process="activeProcessData"
                :entityType="processEntityTypes[0]"
                class="processPanel"
            />
            <EditFundDataProcessSteps
                v-if="
                    activeProcessData &&
                    isUserRelatedToActiveProcess &&
                    activeProcessData.processTypeId === ProcessType.EditFundData
                "
                ref="editFundDataPanel"
                class="processPanel"
                :process="activeProcessData"
                @approval="goRefresh"
                @affirmation="goRefresh(true)"
            />
            <RefineDataProcessSteps
                v-if="
                    activeProcessData &&
                    isUserRelatedToActiveProcess &&
                    activeProcessData.processTypeId === ProcessType.RefineData
                "
                ref="refineDataPanel"
                class="processPanel"
                :process="activeProcessData"
                @approval="goRefresh"
                @affirmation="goRefresh(true)"
            />
            <ProcessRawInventoriesProcessSteps
                v-if="
                    activeProcessData &&
                    (activeProcessData.processTypeId === ProcessType.ProcessRawFundWithRawInventory ||
                        activeProcessData.processTypeId === ProcessType.ProcessFundWithRawInventory)
                "
                ref="processRawInventoriesPanel"
                class="processPanel"
                :process="activeProcessData"
                @sendReport="goRefresh(true)"
                @approve="goRefresh"
                @affirm="goRefresh(true)"
            />
            <ReconstructFundDataProcessSteps
                v-if="
                    activeProcessData &&
                    isUserRelatedToActiveProcess &&
                    activeProcessData.processTypeId == ProcessType.ReconstructFundData
                "
                ref="reconstructFundDataPanel"
                class="processPanel"
                :process="activeProcessData"
                @approval="goRefresh"
                @affirmation="goRefresh(true)"
            />
        </v-container>
    </v-card>
    <v-row class="mt-1 mb-1" v-if="!editEnabled && fundData.hasExternalSource">
        <v-col class="col-12 col-md-9 col-lg-9 ma-auto">
            <v-alert class="justify-content-center" type="info" variant="tonal" style="font-size: 1.1rem">
                {{ t('funds.externalSourceFund') }}
            </v-alert>
        </v-col>
    </v-row>
    <v-card ref="fundCard" class="mt-3 col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('funds.display') }}</v-card-title>
        <v-container>
            <v-row class="justify-content-end mb-2">
                <v-col class="d-flex justify-content-end">
                    <v-btn @click="viewCardForm1"
                        >{{ t('reports.cardForm1') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('reports.cardForm1') }}
                        </v-tooltip>
                    </v-btn>
                </v-col>
            </v-row>
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel value="generalInfo">
                    <v-expansion-panel-title>{{ t('funds.panels.generalInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldArchive"
                                    :label="t('funds.columns.archive')"
                                    v-model="fundData.archiveName"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldNumber"
                                    :label="t('funds.columns.number')"
                                    v-model="fundData.number"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldSystemIdentifier"
                                    :label="t('funds.columns.systemIdentifier')"
                                    v-model="fundData.systemIdentifier"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldCreatedByDisplayName"
                                    :label="t('funds.columns.author')"
                                    v-model="fundData.createdByDisplayName"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldCreatedOn"
                                    :label="t('funds.columns.creationDate')"
                                    :modelValue="formatDate(fundData.createdOn)"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row v-if="fundData.updatedOn">
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldUpdatedByDisplayName"
                                    :label="t('funds.columns.updatedBy')"
                                    v-model="fundData.updatedByDisplayName"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldCreatedOn"
                                    :label="t('funds.columns.updatedOn')"
                                    :modelValue="formatDate(fundData.updatedOn)"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="fundInfo">
                    <v-expansion-panel-title>{{ t('funds.panels.fundInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldNumber"
                                    :label="t('funds.columns.number')"
                                    v-model="fundData.number"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldNumberArray"
                                    :label="t('funds.columns.numberArray')"
                                    v-model="fundData.numberArray"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldDescriptionLevel"
                                    :label="t('funds.columns.descriptionLevel')"
                                    v-model="fundData.descriptionLevelText"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldStatus"
                                    :label="t('funds.columns.status')"
                                    v-model="fundData.statusText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldTitle"
                                    :label="t('funds.columns.title')"
                                    v-model="fundData.title"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldType"
                                    :label="t('funds.columns.type')"
                                    v-model="fundData.typeText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldAcquisitionMethod"
                                    :label="t('funds.columns.acquisitionMethod')"
                                    v-model="fundData.acquisitionMethodText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldIndustryType"
                                    :label="t('funds.columns.industryType')"
                                    v-model="fundData.industryTypeText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                                <h6>{{ t('funds.panels.chronologicalScope') }}</h6>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <Switch
                                    v-model="fundData.hasNoChronologicalScope"
                                    :label="t('funds.columns.chronologicalScope')"
                                    :large="false"
                                    :showLabel="true"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <label>{{ t('funds.columns.startDate') }}</label>
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateDay"
                                    :label="t('funds.columns.day')"
                                    v-model="fundData.startDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateMonth"
                                    :label="t('funds.columns.month')"
                                    v-model="fundData.startDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateYear"
                                    :label="t('funds.columns.year')"
                                    v-model="fundData.startDateYear"
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
                                    :label="t('funds.columns.day')"
                                    v-model="fundData.endDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateMonth"
                                    :label="t('funds.columns.month')"
                                    v-model="fundData.endDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateYear"
                                    :label="t('funds.columns.year')"
                                    v-model="fundData.endDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldApproxmateChronologicalScope"
                                    :label="t('funds.columns.approxmateChronologicalScope')"
                                    v-model="fundData.approxmateChronologicalScope"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                                <h6>{{ t('funds.panels.storage') }}</h6>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldBytes"
                                    :label="t('funds.columns.bytes')"
                                    v-model="formattedBytes"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldLinearMeters"
                                    :label="t('funds.columns.linearMeters')"
                                    v-model="fundData.linearMeters"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldInventoryCount"
                                    :label="t('funds.columns.inventoryCount')"
                                    v-model="fundData.inventoryCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldArchivalEntityCount"
                                    :label="t('funds.columns.archivalEntityCount')"
                                    v-model="fundData.archivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldDocumentCount"
                                    :label="t('funds.columns.documentCount')"
                                    v-model="fundData.documentCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldFileType"
                                    :label="t('funds.columns.fileType')"
                                    v-model="fundData.fileTypeText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOtherMetrics"
                                    :label="t('funds.columns.otherMetrics')"
                                    v-model="fundData.otherMetrics"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                            </v-col>
                        </v-row>

                        <v-row>
                            <v-col :class="possibleEmptyFields.fundCreatorTitleHistory">
                                <text-area-field
                                    name="fldFundCreatorTitleHistory"
                                    :label="t('funds.columns.fundCreatorTitleHistory')"
                                    v-model="fundData.fundCreatorTitleHistory"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.fundCreatorActivityHistory">
                                <text-area-field
                                    name="fldFundCreatorActivityHistory"
                                    :label="t('funds.columns.fundCreatorActivityHistory')"
                                    v-model="fundData.fundCreatorActivityHistory"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.fundCreatorBiographicalHistory">
                                <text-area-field
                                    name="fldFundCreatorBiographicalHistory"
                                    :label="t('funds.columns.fundCreatorBiographicalHistory')"
                                    v-model="fundData.fundCreatorBiographicalHistory"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.history">
                                <text-area-field
                                    name="fldHistory"
                                    :label="t('funds.columns.history')"
                                    v-model="fundData.history"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.documentsProvider">
                                <text-field
                                    name="fldDocumentsProvider"
                                    :label="t('funds.columns.documentsProvider')"
                                    v-model="fundData.documentsProvider"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.documentsDescription">
                                <text-area-field
                                    name="fldDocumentsDescription"
                                    :label="t('funds.columns.documentsDescription')"
                                    v-model="fundData.documentsDescription"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.languageText">
                                <text-field
                                    name="fldLanguage"
                                    :label="t('funds.columns.language')"
                                    v-model="languageText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.documentsAccessDescription">
                                <text-area-field
                                    name="fldDocumentsAccessDescription"
                                    :label="t('funds.columns.documentsAccessDescription')"
                                    v-model="fundData.documentsAccessDescription"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.relatedFunds">
                                <text-area-field
                                    name="fldRelatedFunds"
                                    :label="t('funds.columns.relatedFunds')"
                                    v-model="fundData.relatedFunds"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.notes">
                                <text-area-field
                                    name="fldNotes"
                                    :label="t('funds.columns.notes')"
                                    v-model="fundData.notes"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>

                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldValuableDocumentsInventoryCount"
                                    :label="t('funds.columns.valuableDocumentsInventoryCount')"
                                    v-model="fundData.valuableDocumentsInventoryCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldInvaluableDocumentsInventoryCount"
                                    :label="t('funds.columns.invaluableDocumentsInventoryCount')"
                                    v-model="fundData.invaluableDocumentsInventoryCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldEnrolledBytes"
                                    :label="t('funds.columns.enrolledBytes')"
                                    v-model="formattedEnrolledBytes"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldDeductedBytes"
                                    :label="t('funds.columns.deductedBytes')"
                                    v-model="formattedDeductedBytes"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldEnrolledInventoryCount"
                                    :label="t('funds.columns.enrolledInventoryCount')"
                                    v-model="fundData.enrolledInventoryCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldDeductedInventoryCount"
                                    :label="t('funds.columns.deductedInventoryCount')"
                                    v-model="fundData.deductedInventoryCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <!-- <v-expansion-panel value="externalSource">
                    <v-expansion-panel-title>{{ t('funds.panels.externalSource') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <Switch
                                    :label="t('funds.columns.hasExternalSource')"
                                    v-model="fundData.hasExternalSource"
                                    :large="false"
                                    :showLabel="true"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12">
                                <text-field
                                    name="fldExternalIdentifier"
                                    :label="t('funds.columns.externalIdentifier')"
                                    v-model="fundData.externalIdentifier"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel> -->
                <v-expansion-panel value="inventoryInfo" v-if="renderComponent">
                    <v-expansion-panel-title>{{ t('funds.panels.inventoryInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text @DOMContentLoaded="getFundData()">
                        <FundInventories
                            ref="fundInventories"
                            v-if="!showProcessRawInventories && !showReconstructionInventories"
                            :fund="fundData"
                            :addEnabled="addInventoryEnabled"
                        />
                        <ProcessRawInventories
                            v-if="showProcessRawInventories"
                            :fund="fundData"
                            :process="activeProcessData"
                            @submit="goRefresh"
                        />
                        <ReconstructionInventories
                            v-if="showReconstructionInventories"
                            :fund="fundData"
                            :process="activeProcessData"
                            @markForDeduction="goRefresh(true)"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <!-- <v-expansion-panel class="v-expansion-panel" value="publicUsersReviews">
                    <v-expansion-panel-title>{{ t('common.reviewsHistory') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <public-user-reviews :systemIdentifier="fundData.systemIdentifier" :type="$t('funds.fund')" />
                    </v-expansion-panel-text>
                </v-expansion-panel> -->
            </v-expansion-panels>

            <v-row class="mt-3" v-if="editEnabled">
                <v-col class="d-flex gap-2 justify-content-center">
                    <v-btn @click="goEdit"
                        >{{ t('common.edit') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('funds.buttons.editTooltip') }}
                        </v-tooltip>
                    </v-btn>
                    <back-btn @click="goBack"
                        >{{ t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('funds.buttons.backTooltip') }}
                        </v-tooltip>
                    </back-btn>
                </v-col>
            </v-row>
            <v-row class="mt-1 mb-1" v-if="!editEnabled && fundData.hasExternalSource">
                <v-col class="col-12 ma-auto">
                    <v-alert class="justify-content-center" type="info" variant="tonal" style="font-size: 1.1rem">
                        {{ t('funds.externalSourceFund') }}
                    </v-alert>
                </v-col>
            </v-row>
            <v-row class="mt-3" v-if="!editEnabled">
                <v-col class="d-flex gap-2 justify-content-center">
                    <back-btn @click="goBack"
                        >{{ t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('funds.buttons.backTooltip') }}
                        </v-tooltip>
                    </back-btn>
                </v-col>
            </v-row>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, Ref, computed } from 'vue';
import { useStore } from '@/store/user';
import { useStore as useAppStore } from '@/store/app';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { validate as isValidGuid } from 'uuid';
import { useRedirectWithId } from '@/helpers/router.helper';
import { formatDate } from '@/helpers/format.helper';
import { formatBytesToMB } from '@/helpers/format.helper';
import { entityObjectType } from '@/helpers/entityObject.helper';
import { isProcessType, isProcessStepType } from '@/helpers/validate.helper';

import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { EntityType } from '@/enums/entity';
import { ProcessStep, ProcessType } from '@/enums/process';
import { BusinessObjectType } from '@/models/grid';
import { Status } from '@/enums/status';
import { IFund } from '@/interfaces/fund';
import { Fund } from '@/models/fund';
import { IProcess } from '@/interfaces/process';
import { ProcessModel } from '@/models/process';
import { RoleNames } from '@/enums/roles';
//import { fundEntityType } from '@/helpers/fund.helper';
import authorization from '@/helpers/authorization.helper';
import fundService from '@/services/fund.service';
import deductionService from '@/services/deductionProcess.service';
import processService from '@/services/process.service';
import editDataProcessService from '@/services/editDataProcess.service';
import editFundDataProcessService from '@/services/editFundDataProcess.service';
import refineDataProcessService from '@/services/refineDataProcess.service';
import reconstructFundDataProcessService from '@/services/reconstructFundData.service';
import processRawInventoriesProcessService from '@/services/processRawInventoriesProcess.service';
import DeductionDataProcessActions from '@/components/deductionProcess/actions.vue';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import DeductionProcessPanel from '@/components/deductionProcess/display.vue';
import StartProcessPanel from '@/components/process/startPanel.vue';
import ProcessInformationPanel from '@/components/process/processInfoPanel.vue';
import TimelinePanel from '@/components/process/timelinePanel.vue';
import EditDataProcessActions from '@/components/editDataProcess/actions.vue';
import EditFundDataProcessActions from '@/components/editFundDataProcess/actions.vue';
import EditFundDataProcessSteps from '@/components/editFundDataProcess/steps.vue';
import RefineDataProcessActions from '@/components/refineDataProcess/actions.vue';
import RefineDataProcessSteps from '@/components/refineDataProcess/steps.vue';
import ReconstructFundDataProcessActions from '@/components/reconstructFundDataProcess/actions.vue';
import ReconstructFundDataProcessSteps from '@/components/reconstructFundDataProcess/steps.vue';
import FundInventories from '@/components/inventory/fundInventories.vue';
import ProcessRawInventoriesProcessActions from '@/components/processRawInventoriesProcess/actions.vue';
import ProcessRawInventoriesProcessSteps from '@/components/processRawInventoriesProcess/steps.vue';
import eDocsProcessPanels from '@/components/eDocsCollection/processProgressPanels.vue';
import ReconstructionInventories from '@/components/reconstructFundDataProcess/inventories.vue';
import ProcessRawInventories from '@/components/processRawInventoriesProcess/inventories.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import { InventoryDescriptionLevel } from '@/enums/inventory';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'DisplayFund',
    components: {
        Loader,
        TextField,
        TextAreaField,
        DeductionDataProcessActions,
        Switch,
        DeductionProcessPanel,
        Breadcrumbs,
        StartProcessPanel,
        ProcessInformationPanel,
        TimelinePanel,
        EditDataProcessActions,
        EditFundDataProcessActions,
        EditFundDataProcessSteps,
        eDocsProcessPanels,
        RefineDataProcessActions,
        RefineDataProcessSteps,
        ReconstructFundDataProcessActions,
        ReconstructFundDataProcessSteps,
        ReconstructionInventories,
        FundInventories,
        ProcessRawInventoriesProcessActions,
        ProcessRawInventories,
        ProcessRawInventoriesProcessSteps,
        //PublicUserReviews,
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
        const breadcrumbItems = computed(() => [
            {
                title: fundData.value.archiveName,
                disabled: false,
                to: { name: 'Home' },
            },
            // {
            //     title: t('funds.title'),
            //     disabled: false,
            //     to: { name: 'Funds' },
            // },
            {
                title: t('funds.fund'),
                disabled: true,
            },
        ]);
        const processEntityTypes = [BusinessObjectType.fund];
        const panel = ref(['generalInfo', 'fundInfo', 'inventoryInfo']);
        const processPanel = ref(['processInfo', 'startProcess']);
        const showStartProcessPanel = ref(false);
        const showProcessInfoPanel = ref(false);
        const renderComponent = ref(false);
        const fundInventories = ref();
        const userStore = useStore();
        const isUserRelatedToActiveProcess = ref(false);
        const appStore = useAppStore();
        const undoDeductionChanges = ref(false);
        const possibleEmptyFields = {
            fundCreatorTitleHistory: '',
            fundCreatorActivityHistory: '',
            fundCreatorBiographicalHistory: '',
            history: '',
            documentsProvider: '',
            documentsDescription: '',
            languageText: '',
            documentsAccessDescription: '',
            relatedFunds: '',
            notes: '',
        };

        const lowClass = 'low';
        const isLoading = ref(false);

        const hasRoleB = computed(() => userStore.getters.hasRole(RoleNames.GroupB));

        const entityType = computed(() => {
            return entityObjectType(EntityType.fund, fundData.value.descriptionLevelCode);
            // const levelCode = fundData.value.descriptionLevelCode;
            // if (levelCode) {
            //     return fundEntityType(levelCode);
            // } else {
            //     return ['fund', 'raw-fund'];
            // }
        });

        const allowInventoriesSelection = computed(
            () =>
                activeProcessData.value &&
                (activeProcessData.value.processTypeId === ProcessType.ProcessRawFundWithRawInventory ||
                    activeProcessData.value.processTypeId === ProcessType.ReconstructFundData)
        );
        const languageText = computed(() => fundData?.value?.languageText);
        const editEnabled = computed(
            () =>
                (!fundData.value.hasExternalSource ||
                    (fundData.value.statusCode !== Status.Deducted && fundData.value.statusCode !== Status.Deleted)) &&
                activeProcessData.value &&
                (isProcessType(activeProcessData.value, ProcessType.EditData) ||
                    (activeProcessData.value?.processTypeId === ProcessType.EditFundData &&
                        (activeProcessData.value.activeProcessStepTypeId === ProcessStep.EditFundData_EditData ||
                            activeProcessData.value.activeProcessStepTypeId ===
                                ProcessStep.EditFundData_ReportModifications)) ||
                    (activeProcessData.value?.processTypeId === ProcessType.RefineData &&
                        (activeProcessData.value.activeProcessStepTypeId === ProcessStep.RefineData_EditData ||
                            activeProcessData.value.activeProcessStepTypeId ===
                                ProcessStep.RefineData_ReportModifications)) ||
                    (isProcessType(
                        activeProcessData.value,
                        // ProcessType.AddInventory,
                        // ProcessType.AddRawInventory,
                        // ProcessType.AddRawInventoryRaw,
                        ProcessType.AddFundAndInventory,
                        ProcessType.AddRawFundAndRawInventory
                    ) &&
                        isProcessStepType(
                            activeProcessData.value,
                            ProcessStep.ProcessInitialization,
                            ProcessStep.AddPackages,
                            ProcessStep.CommissionReport,
                            ProcessStep.CommissionReportEdit,
                            ProcessStep.CommissionCorrections,
                            ProcessStep.Registration
                        )) ||
                    (activeProcessData.value?.processTypeId === ProcessType.ProcessRawFundWithRawInventory &&
                        hasRoleB.value == true &&
                        (activeProcessData.value.activeProcessStepTypeId ===
                            ProcessStep.ProcessRawFundWithRawInventory_ChooseRawInventories ||
                            activeProcessData.value.activeProcessStepTypeId ===
                                ProcessStep.ProcessRawFundWithRawInventory_CreateInventories ||
                            activeProcessData.value.activeProcessStepTypeId ===
                                ProcessStep.ProcessRawFundWithRawInventory_CreateReport)) ||
                    (activeProcessData.value?.processTypeId === ProcessType.ProcessFundWithRawInventory &&
                        hasRoleB.value == true &&
                        (activeProcessData.value.activeProcessStepTypeId ===
                            ProcessStep.ProcessFundWithRawInventory_ChooseRawInventories ||
                            activeProcessData.value.activeProcessStepTypeId ===
                                ProcessStep.ProcessFundWithRawInventory_CreateInventories ||
                            activeProcessData.value.activeProcessStepTypeId ===
                                ProcessStep.ProcessFundWithRawInventory_CreateReport)))
        );

        const addInventoryEnabled = computed(
            () =>
                activeProcessData.value &&
                isProcessType(
                    activeProcessData.value,
                    ProcessType.AddFundAndInventory,
                    ProcessType.AddRawFundAndRawInventory
                ) &&
                isProcessStepType(
                    activeProcessData.value,
                    ProcessStep.ProcessInitialization,
                    ProcessStep.AddPackages,
                    ProcessStep.CommissionReport,
                    ProcessStep.CommissionReportEdit,
                    ProcessStep.CommissionCorrections
                ) &&
                fundInventories.value &&
                fundInventories.value.itemCount <= 0
        );

        const showReconstructionInventories = computed(
            () =>
                activeProcessData.value &&
                activeProcessData.value.processTypeId === ProcessType.ReconstructFundData &&
                (activeProcessData.value.activeProcessStepTypeId === ProcessStep.ReconstructFundData_EditData ||
                    activeProcessData.value.activeProcessStepTypeId ===
                        ProcessStep.ReconstructFundData_DataModifications ||
                    activeProcessData.value.activeProcessStepTypeId ===
                        ProcessStep.ReconstructFundData_ReportModifications)
        );

        const showProcessRawInventories = computed(
            () =>
                activeProcessData.value &&
                (activeProcessData.value.processTypeId === ProcessType.ProcessRawFundWithRawInventory ||
                    activeProcessData.value.processTypeId === ProcessType.ProcessFundWithRawInventory)
        );

        const enableStartProcessPanel = computed(
            () =>
                fundData.value &&
                fundData.value.statusCode !== Status.Deducted &&
                fundData.value.statusCode !== Status.Deleted
        );

        const router = useRouter();
        const goEdit = () => {
            if (fundData.value.systemIdentifier && isValidGuid(fundData.value.systemIdentifier) && !fundData.value.hasExternalSource) {
                useRedirectWithId(router, 'EditFund', fundData.value.systemIdentifier);
            } else {
                message.value = new Message({
                    text: t('error.cannotEditExternalFund'),
                    display: true,
                });
            }
        };
        const goBack = () => {
            router.go(-1);
        };
        const goRefresh = async (refreshPage?: boolean) => {
            if (refreshPage) {
                router.go(0);
            } else {
                await getActiveProcessData();
            }
            window.scrollTo(0, 0);
        };

        const fundData = ref<IFund>(new Fund());
        const activeProcessData = ref<IProcess>();

        const formattedBytes = computed(() => {
            return formatBytesToMB(fundData.value.bytes || 0);
        });
        const formattedEnrolledBytes = computed(() => {
            return formatBytesToMB(fundData.value.enrolledBytes || 0);
        });
        const formattedDeductedBytes = computed(() => {
            return formatBytesToMB(fundData.value.deductedBytes || 0);
        });

        let isdaDataCannotBeDisplayed = false;

        const getFundData = async () => {
            try {
                isLoading.value = true;
                console.log(props);

                if (props.id || props.externalIdentifier) {
                    const result = await fundService.displayFund(
                        props.id,
                        props.hasExternalSource,
                        props.externalIdentifier
                    );

                    if (result) {
                        fundData.value = result;
                    }

                    if (!fundData.value.fundCreatorTitleHistory) {
                        possibleEmptyFields.fundCreatorTitleHistory = lowClass;
                    }
                    if (!fundData.value.fundCreatorActivityHistory) {
                        possibleEmptyFields.fundCreatorActivityHistory = lowClass;
                    }
                    if (!fundData.value.fundCreatorBiographicalHistory) {
                        possibleEmptyFields.fundCreatorBiographicalHistory = lowClass;
                    }
                    if (!fundData.value.history) {
                        possibleEmptyFields.history = lowClass;
                    }
                    if (!fundData.value.documentsProvider) {
                        possibleEmptyFields.documentsProvider = lowClass;
                    }
                    if (!fundData.value.documentsDescription) {
                        possibleEmptyFields.documentsDescription = lowClass;
                    }
                    if (!fundData.value.languageText) {
                        possibleEmptyFields.languageText = lowClass;
                    }
                    if (!fundData.value.documentsAccessDescription) {
                        possibleEmptyFields.documentsAccessDescription = lowClass;
                    }
                    if (!fundData.value.relatedFunds) {
                        possibleEmptyFields.relatedFunds = lowClass;
                    }
                    if (!fundData.value.notes) {
                        possibleEmptyFields.notes = lowClass;
                    }

                    if (fundData.value.resultMessage && fundData.value.resultMessage === 'ISDADataCannotBeDisplayed') {
                        message.value = new Message({
                            text: t('warnings.ISDADataCannotBeDisplayed'),
                            display: true,
                            type: 'warning',
                        });

                        isdaDataCannotBeDisplayed = true;
                    }
                } else {
                    message.value = new Message({
                        text: t('error.operationError'),
                        display: true,
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

        const getActiveProcessData = async () => {
            try {
                isLoading.value = true;
                if (props.id || props.externalIdentifier) {
                    const process = await processService.getCurrentActiveProcess(
                        BusinessObjectType.fund,
                        props.id,
                        undefined,
                        props.externalIdentifier
                    );

                    if (process) {
                        activeProcessData.value = process;
                    }

                    if (activeProcessData.value?.id) {
                        isUserRelatedToActiveProcess.value = await processService.getIsCurrentUserInProcess(
                            activeProcessData.value.id
                        );

                        if (breadcrumbItems.value.length > 2) {
                            breadcrumbItems.value[breadcrumbItems.value.length - 1].title =
                                activeProcessData.value.activeProcessStepName!;
                            breadcrumbItems.value[breadcrumbItems.value.length - 2].title =
                                activeProcessData.value.processTypeTitle!;
                        } else {
                            breadcrumbItems.value.push(
                                {
                                    title: activeProcessData.value.processTypeTitle!,
                                    disabled: true,
                                },
                                {
                                    title: activeProcessData.value.activeProcessStepName!,
                                    disabled: true,
                                }
                            );
                        }

                        showProcessInfoPanel.value = true;
                    } else {
                        showStartProcessPanel.value = true;
                    }
                } else {
                    showStartProcessPanel.value = true;
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

        const btnStartProcessClickHandler = async (processType?: number) => {
            try {
                const process = new ProcessModel({
                    processTypeId: processType,
                    archiveId: fundData.value.archiveId,
                    fundSystemIdentifier: fundData.value.systemIdentifier,
                });

                let result = null;

                const hasSystemIdentifier = () => {
                    if (process.fundSystemIdentifier == undefined) {
                        throw new Error('CantStart');
                    }
                };

                switch (processType) {
                    case ProcessType.EditData:
                        //if (authorization.isAdmin(AdminType.Admin)) {
                        if (authorization.hasRole(RoleNames.GroupB1, fundData.value.archiveId!)) {
                            hasSystemIdentifier();
                            if (fundData.value.hasExternalSource) {
                                throw new Error('CantStart');
                            }
                            await editDataProcessService.startProcess(process);
                            goEdit();
                        } else {
                            throw new Error('NoPermissions');
                        }
                        break;
                    case ProcessType.RefineData:
                        if (authorization.hasRole(RoleNames.GroupB, fundData.value.archiveId!)) {
                            hasSystemIdentifier();
                            if (fundData.value.hasExternalSource) {
                                result = await refineDataProcessService.hasEntitiesInCEA(process);
                                if (!result.succeeded) {
                                    throw new Error('NoDataInCEA');
                                }
                            }
                            await refineDataProcessService.startProcess(process);
                            if (fundData.value.hasExternalSource) {
                                goRefresh(true);
                            } else {
                                goEdit();
                            }
                        } else {
                            throw new Error('NoPermissions');
                        }
                        break;
                    case ProcessType.EditFundData:
                        if (authorization.hasRole(RoleNames.GroupB, fundData.value.archiveId!)) {
                            hasSystemIdentifier();
                            if (fundData.value.hasExternalSource) {
                                throw new Error('CantStart');
                            }
                            await editFundDataProcessService.startProcess(process);
                            goEdit();
                        } else {
                            throw new Error('NoPermissions');
                        }
                        break;
                    case ProcessType.ReconstructFundData:
                        if (authorization.hasRole(RoleNames.GroupB, fundData.value.archiveId!)) {
                            hasSystemIdentifier();
                            await reconstructFundDataProcessService.startProcess(process);
                            goRefresh(true);
                        } else {
                            throw new Error('NoPermissions');
                        }
                        break;
                    case ProcessType.DeductData:
                        hasSystemIdentifier();
                        if (fundData.value.hasExternalSource) {
                            throw new Error('CantStart');
                        }
                        if (authorization.hasRole(RoleNames.GroupB)) {
                            if (fundData.value.isDraft == false) {
                                await deductionService.start(
                                    props.id!,
                                    props.externalIdentifier!,
                                    BusinessObjectType.fund,
                                    fundData.value.archiveId!
                                );
                                router.go(0);
                            } else throw new Error('isDraft');
                        } else throw new Error('NoPermissions');
                        break;
                    case ProcessType.AddInventory:
                        router.push({
                            name: 'CreateInventory',
                            query: {
                                fundSystemIdentifier: fundData.value.systemIdentifier,
                                fundHasExternalSource: (fundData.value.hasExternalSource || false).toString(),
                                fundExternalIdentifier: fundData.value.externalIdentifier,
                                descriptionLevel: InventoryDescriptionLevel.inventory,
                                startProcess: true.toString(),
                            },
                        });
                        break;
                    case ProcessType.AddRawInventoryRaw:
                    case ProcessType.AddRawInventory:
                        router.push({
                            name: 'CreateInventory',
                            query: {
                                fundSystemIdentifier: fundData.value.systemIdentifier,
                                fundHasExternalSource: (fundData.value.hasExternalSource || false).toString(),
                                fundExternalIdentifier: fundData.value.externalIdentifier,
                                descriptionLevel: InventoryDescriptionLevel.rawInventory,
                                startProcess: true.toString(),
                            },
                        });
                        break;
                    case ProcessType.AddSystemInventory:
                        router.push({
                            name: 'CreateInventory',
                            query: {
                                fundSystemIdentifier: fundData.value.systemIdentifier,
                                fundHasExternalSource: (fundData.value.hasExternalSource || false).toString(),
                                fundExternalIdentifier: fundData.value.externalIdentifier,
                                descriptionLevel: InventoryDescriptionLevel.systemInventory,
                                startProcess: true.toString(),
                            },
                        });
                        break;
                    case ProcessType.ProcessRawFundWithRawInventory:
                    case ProcessType.ProcessFundWithRawInventory:
                        hasSystemIdentifier();
                        // if (fundData.value.hasExternalSource) {
                        //     throw new Error('CantStart');
                        // }
                        if (fundData.value.hasExternalSource) {
                            result = await processRawInventoriesProcessService.fundHasRawInventoriesInSEA(process.fundSystemIdentifier!);
                            console.log(result);
                            if (!result) {
                                throw new Error('NoRawInventoriesInCEA');
                            }
                        }
                        await processRawInventoriesProcessService.startProcess(process);
                        goRefresh(true);
                        break;

                    default:
                        throw new Error('InvalidProcess');
                }
            } catch (error) {
                let messageText = t('error.basic');

                if (error.message == 'CantStart') {
                    messageText = t('error.cantStartProcess')
                    // message.value = new Message({
                    //     text: t('error.cantStartProcess'),
                    //     display: true,
                    // });
                } else if (error.message == 'NoDataInCEA') {
                    messageText = t('error.noDataInCEA', { entity: t('funds.fund') });
                    // message.value = new Message({
                    //     text: t('error.noDataInCEA', { entity: t('funds.fund') }),
                    //     display: true,
                    // });
                } else if (error.message == 'NoRawInventoriesInCEA') {
                    messageText = t('error.noRawInventoriesInCEA', { number: fundData.value.number })
                } else if (error.message == 'NoPermissions') {
                    messageText = t('error.noPermissions');
                    // message.value = new Message({
                    //     text: t('error.noPermissions'),
                    //     display: true,
                    // });
                } else if (error.message == 'InvalidProcess') {
                    messageText = t('error.invalidProcess')
                    // message.value = new Message({
                    //     text: t('error.invalidProcess'),
                    //     display: true,
                    // });
                } else {
                    const errorResult = error as ResponseResult;
                    messageText = errorResult.showMessage ? errorResult.message! : t('error.basic');
                    // message.value = new Message({
                    //     text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    //     display: true,
                    // });
                }

                message.value = new Message({
                    text: messageText,
                    display: true,
                });
            }
        };

        onMounted(async () => {
            window.scrollTo(0, 0);
            await getFundData();
            await getActiveProcessData();
            renderComponent.value = true;
            window.scrollTo(0, 0);
        });

        const isDocsCollectingProcessVisible = computed(() => {
            if (!activeProcessData.value) {
                return false;
            }

            return (
                showProcessInfoPanel.value &&
                isUserRelatedToActiveProcess.value &&
                (activeProcessData.value.processTypeId === ProcessType.AddInventory ||
                    activeProcessData.value.processTypeId === ProcessType.AddRawInventoryRaw ||
                    activeProcessData.value.processTypeId === ProcessType.AddFundAndInventory ||
                    activeProcessData.value.processTypeId === ProcessType.AddRawFundAndRawInventory)
            );
        });

        const viewCardForm1 = () => {
            try {
                const { href } = router.resolve({
                    name: 'BaseReport',
                    params: {
                        componentName: 'CardForm1Data',
                        id: fundData.value.systemIdentifier,
                    },
                    query: {
                        hasExternalSource: String(fundData.value.hasExternalSource),
                        externalIdentifier: fundData.value.externalIdentifier,
                    },
                });
                window.open(href, '_blank');
            } catch (error: unknown) {
                message.value = new Message({
                    text: t('error.operationError'),
                    display: true,
                });
            }
        };

        const redirectToEntityInIsda = () =>
            window.open(
                `${appStore.state.externalSourceDisplayEntityBaseUrl}Fund&agid=${fundData.value.archiveCode}&flgid=${fundData.value.externalIdentifier}`,
                '_blank'
            );

        return {
            activeProcessData,
            addInventoryEnabled,
            btnStartProcessClickHandler,
            editEnabled,
            entityType,
            fundData,
            goBack,
            goEdit,
            goRefresh,
            formatDate,
            message,
            panel,
            processPanel,
            fundInventories,
            enableStartProcessPanel,
            showProcessInfoPanel,
            showStartProcessPanel,
            showReconstructionInventories,
            showProcessRawInventories,
            isUserRelatedToActiveProcess,
            t,
            ProcessType,
            ProcessStep,
            allowInventoriesSelection,
            breadcrumbItems,
            renderComponent,
            possibleEmptyFields,
            isDocsCollectingProcessVisible,
            formattedBytes,
            viewCardForm1,
            languageText,
            undoDeductionChanges,
            formattedEnrolledBytes,
            formattedDeductedBytes,
            redirectToEntityInIsda,
            isdaDataCannotBeDisplayed,
            processEntityTypes,
            isLoading,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/index-1.scss';
@import '@/assets/styles/breadcrumbs-fund.scss';

.processPanel {
    margin-top: 16px;
}

.low,
:deep(.low div),
:deep(.low textarea) {
    height: 50px;
    margin-bottom: 25px;
}
a {
    cursor: pointer;
}
</style>
