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
                                activeProcessData?.processTypeId == ProcessType.EditData && isUserRelatedToActiveProcess
                            "
                            :process="activeProcessData"
                            @complete="goRefresh(true)"
                            @undochanges="goRefresh(true)"
                        />
                        <refine-data-process-actions
                            v-if="
                                activeProcessData?.processTypeId == ProcessType.RefineData &&
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
                        <reconstruct-fund-data-process-actions
                            v-if="
                                activeProcessData?.processTypeId == ProcessType.ReconstructFundData &&
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
                                activeProcessData.inventorySystemIdentifier
                            "
                            :id="id"
                            :process="activeProcessData"
                            :businessObjectType="processEntityTypes[0]"
                        />
                    </template>
                </process-information-panel>
                <start-process-panel
                    v-if="showStartProcessPanel"
                    value="startProcess"
                    :entityType="entityType"
                    :entityHasExternalSource="inventoryData.hasExternalSource"
                    @startProcess="btnStartProcessClickHandler"
                    :readOnly="!enableStartProcessPanel"
                />
                <timeline-panel
                    v-if="showProcessInfoPanel && isUserRelatedToActiveProcess"
                    :processId="activeProcessData!.id!"
                    :showExpanded="false"
                />
            </v-expansion-panels>
            <eDocsProcessPanels
                :process="activeProcessData!"
                v-if="isCollectiongProcedurePanelVisible"
                class="processPanel"
            ></eDocsProcessPanels>
            <DeductionProcessPanel
                v-if="
                    activeProcessData &&
                    activeProcessData.processTypeId == ProcessType.DeductData &&
                    isUserRelatedToActiveProcess &&
                    activeProcessData.inventorySystemIdentifier
                "
                :process="activeProcessData"
                :entityType="processEntityTypes[0]"
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
                @affirmation="goRefresh"
            />
        </v-container>
    </v-card>
    <v-row class="mt-1 mb-1" v-if="!editEnabled && inventoryData.hasExternalSource">
        <v-col class="col-12 col-md-9 col-lg-9 ma-auto">
            <v-alert class="justify-content-center" type="info" variant="tonal" style="font-size: 1.1rem">
                {{ t('inventories.externalSourceInventory') }}
            </v-alert>
        </v-col>
    </v-row>
    <v-card ref="inventoryCard" class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('inventories.display') }}</v-card-title>
        <v-container>
            <v-row class="justify-content-end mb-1">
                <v-col class="d-flex gap-2 justify-content-end">
                    <v-btn
                        v-if="
                            inventoryData.descriptionLevelCode === InventoryDescriptionLevel.inventory &&
                            enablePrintInventory
                        "
                        @click="goPrintInventory"
                    >
                        {{ t('inventories.buttons.printInventory') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('inventories.buttons.printInventory') }}
                        </v-tooltip>
                    </v-btn>

                    <v-btn @click="viewCardForm1A"
                        >{{ t('reports.cardForm1A') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('reports.cardForm1A') }}
                        </v-tooltip>
                    </v-btn>
                </v-col>
            </v-row>
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel value="generalInfo">
                    <v-expansion-panel-title>{{ t('inventories.panels.generalInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldArchive"
                                    :label="t('funds.columns.archive')"
                                    v-model="inventoryData.archiveName"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldFund"
                                    :label="t('inventories.columns.fund')"
                                    v-model="inventoryData.fundNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldNumber"
                                    :label="t('inventories.columns.number')"
                                    v-model="inventoryData.number"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldSystemIdentifier"
                                    :label="t('inventories.columns.systemIdentifier')"
                                    v-model="inventoryData.systemIdentifier"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <a :style="applicationPointer" @click="goToApplication">
                                    <text-field
                                        style="text-decoration-line: underline"
                                        name="fldApplication"
                                        :label="t('inventories.columns.application')"
                                        v-model="applicationTitle"
                                        :readonly="true"
                                    />
                                </a>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldCreatedByDisplayName"
                                    :label="t('inventories.columns.author')"
                                    v-model="inventoryData.createdByDisplayName"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldCreatedOn"
                                    :label="t('inventories.columns.creationDate')"
                                    :modelValue="formatDate(inventoryData.createdOn!)"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row v-if="inventoryData.updatedOn">
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldUpdatedByDisplayName"
                                    :label="t('inventories.columns.updatedBy')"
                                    v-model="inventoryData.updatedByDisplayName"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldUpdatedOn"
                                    :label="t('inventories.columns.updatedOn')"
                                    :modelValue="formatDate(inventoryData.updatedOn)"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="inventoryInfo">
                    <v-expansion-panel-title>{{ t('inventories.panels.inventoryInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldNumber"
                                    :label="t('inventories.columns.number')"
                                    v-model="inventoryData.number"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldNumberArray"
                                    :label="t('inventories.columns.numberArray')"
                                    v-model="inventoryData.numberArray"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDescriptionLevel"
                                    :label="t('inventories.columns.descriptionLevel')"
                                    v-model="inventoryData.descriptionLevelText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldAvailabilityStatus"
                                    :label="t('inventories.columns.availabilityStatus')"
                                    v-model="inventoryData.availabilityStatusText"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldStatus"
                                    :label="t('inventories.columns.status')"
                                    v-model="inventoryData.statusText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldAcquisitionMethod"
                                    :label="t('inventories.columns.acquisitionMethod')"
                                    v-model="inventoryData.acquisitionMethodText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                                <h6>{{ t('inventories.panels.chronologicalScope') }}</h6>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <Switch
                                    v-model="inventoryData.hasNoChronologicalScope"
                                    :label="t('inventories.columns.chronologicalScope')"
                                    :large="false"
                                    :showLabel="true"
                                    :disabled="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <label>{{ t('inventories.columns.startDate') }}</label>
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateDay"
                                    :label="t('inventories.columns.day')"
                                    v-model="inventoryData.startDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateMonth"
                                    :label="t('inventories.columns.month')"
                                    v-model="inventoryData.startDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateYear"
                                    :label="t('inventories.columns.year')"
                                    v-model="inventoryData.startDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <label>{{ t('inventories.columns.endDate') }}</label>
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateDay"
                                    :label="t('inventories.columns.day')"
                                    v-model="inventoryData.endDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateMonth"
                                    :label="t('inventories.columns.month')"
                                    v-model="inventoryData.endDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateYear"
                                    :label="t('inventories.columns.year')"
                                    v-model="inventoryData.endDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldApproxmateChronologicalScope"
                                    :label="t('inventories.columns.approxmateChronologicalScope')"
                                    v-model="inventoryData.approxmateChronologicalScope"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>

                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                                <h6>{{ t('inventories.panels.storage') }}</h6>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldBytes"
                                    :label="t('inventories.columns.bytes')"
                                    v-model="formattedBytes"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldLinearMeters"
                                    :label="t('inventories.columns.linearMeters')"
                                    v-model="inventoryData.linearMeters"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldArchiffvalEntityCount"
                                    :label="t('documents.columns.enrolledLinearMeters')"
                                    v-model="inventoryData.enrolledLinearMeters"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="asdasd"
                                    :label="t('documents.columns.deductedLinearMeters')"
                                    v-model="inventoryData.deductedLinearMeters"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldArchiffvalEntityCount"
                                    :label="t('archiveEntities.columns.enrolledMB')"
                                    v-model="formattedEnrolledBytes"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="asdasd"
                                    :label="t('archiveEntities.columns.deductedMB')"
                                    v-model="formattedDeductedBytes"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldArchiffvalEntityCount"
                                    :label="t('inventories.columns.enrolledAECount')"
                                    v-model="inventoryData.enrolledAECount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="asdasd"
                                    :label="t('inventories.columns.deductedAECount')"
                                    v-model="inventoryData.deductedAECount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldArchivalEntityCount"
                                    :label="t('inventories.columns.archivalEntityCount')"
                                    v-model="inventoryData.archivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldDocumentCount"
                                    :label="t('inventories.columns.documentCount')"
                                    v-model="inventoryData.documentCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>

                        <v-row v-if="!inventoryData.isInPersonalFund && inventoryData.numberArray != inventoryArray.E">
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldTextDocsCount"
                                    :label="t('inventories.columns.textDocsCount')"
                                    v-model="inventoryData.textDocsCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldGraphicalDocsCount"
                                    :label="t('inventories.columns.graphicalDocsCount')"
                                    v-model="inventoryData.graphicalDocsCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldBoxCount"
                                    :label="t('inventories.columns.boxCount')"
                                    v-model="inventoryData.boxCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldRollCount"
                                    :label="t('inventories.columns.rollCount')"
                                    v-model="inventoryData.rollCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldAudioDocumentArchivalEntityCount"
                                    :label="t('inventories.columns.audioDocumentArchivalEntityCount')"
                                    v-model="inventoryData.audioDocumentArchivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldPhotoDocumentArchivalEntityCount"
                                    :label="t('inventories.columns.photoDocumentArchivalEntityCount')"
                                    v-model="inventoryData.photoDocumentArchivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldVideoDocumentArchivalEntityCount"
                                    :label="t('inventories.columns.videoDocumentArchivalEntityCount')"
                                    v-model="inventoryData.videoDocumentArchivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldDigitalDocumentArchivalEntityCount"
                                    :label="t('inventories.columns.digitalDocumentArchivalEntityCount')"
                                    v-model="inventoryData.digitalDocumentArchivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldFileType"
                                    :label="t('inventories.columns.fileType')"
                                    v-model="inventoryData.fileTypeText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOtherMetrics"
                                    :label="t('inventories.columns.otherMetrics')"
                                    v-model="inventoryData.otherMetrics"
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
                                    :label="t('inventories.columns.fundCreatorTitleHistory')"
                                    v-model="inventoryData.fundCreatorTitleHistory"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.fundCreatorBiographicalHistory">
                                <text-area-field
                                    name="fldFundCreatorBiographicalHistory"
                                    :label="t('inventories.columns.fundCreatorBiographicalHistory')"
                                    v-model="inventoryData.fundCreatorBiographicalHistory"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.history">
                                <text-area-field
                                    name="fldHistory"
                                    :label="t('inventories.columns.history')"
                                    v-model="inventoryData.history"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDocumentsProvider"
                                    :label="t('inventories.columns.documentsProvider')"
                                    v-model="inventoryData.documentsProvider"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.documentsDescription">
                                <text-area-field
                                    name="fldDocumentsDescription"
                                    :label="t('inventories.columns.documentsDescription')"
                                    v-model="inventoryData.documentsDescription"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOriginality"
                                    :label="t('inventories.columns.originality')"
                                    v-model="inventoryData.originalityText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldCreationMethod"
                                    :label="t('inventories.columns.creationMethod')"
                                    v-model="inventoryData.creationMethodText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldLanguage"
                                    :label="t('inventories.columns.language')"
                                    v-model="languageText"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldOtherLanguage"
                                    :label="t('inventories.columns.otherLanguage')"
                                    v-model="inventoryData.otherLanguage"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.documentsAccessDescription">
                                <text-area-field
                                    name="fldDocumentsAccessDescription"
                                    :label="t('inventories.columns.documentsAccessDescription')"
                                    v-model="inventoryData.documentsAccessDescription"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.classificationScheme">
                                <text-area-field
                                    name="fldClassificationScheme"
                                    :label="t('inventories.columns.classificationScheme')"
                                    v-model="inventoryData.classificationScheme"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.abbreviationList">
                                <text-area-field
                                    name="fldAbbreviationList"
                                    :label="t('inventories.columns.abbreviationList')"
                                    v-model="inventoryData.abbreviationList"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.notes">
                                <text-area-field
                                    name="fldNotes"
                                    :label="t('inventories.columns.notes')"
                                    v-model="inventoryData.notes"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                                <h6>{{ t('inventories.panels.copies') }}</h6>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldMicrofilmedArchivalEntityCount"
                                    :label="t('inventories.columns.microfilmedArchivalEntityCount')"
                                    v-model="inventoryData.microfilmedArchivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldDigitizedArchivalEntityCount"
                                    :label="t('inventories.columns.digitizedArchivalEntityCount')"
                                    v-model="inventoryData.digitizedArchivalEntityCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldPositiveFrameCount"
                                    :label="t('inventories.columns.positiveFrameCount')"
                                    v-model="inventoryData.positiveFrameCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldNegativeFrameCount"
                                    :label="t('inventories.columns.negativeFrameCount')"
                                    v-model="inventoryData.negativeFrameCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="externalSource">
                    <v-expansion-panel-title>{{ t('inventories.panels.externalSource') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <Switch
                                    :label="t('inventories.columns.hasExternalSource')"
                                    v-model="inventoryData.hasExternalSource"
                                    :large="false"
                                    :showLabel="true"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12">
                                <text-field
                                    name="fldExternalIdentifier"
                                    :label="t('inventories.columns.externalIdentifier')"
                                    v-model="inventoryData.externalIdentifier"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel
                    value="archivalEntities"
                    v-if="renderComponent && inventoryData.descriptionLevelCode === InventoryDescriptionLevel.inventory"
                >
                    <v-expansion-panel-title>{{
                        t('inventories.panels.archivalEntitiesInInventory')
                    }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <InventoryArchivalEntities
                            v-if="!showReconstructionArchivalEntities"
                            :inventory="inventoryData"
                            :addEnabled="addArchivalEntityEnabled"
                            :addFromPackageEnabled="addFromPackageEnabled"
                            :searchEnabled="true"
                            :deleteEnabled="deleteArchivalEntityEnabled"
                        />
                        <ReconstructionArchivalEntities
                            v-if="showReconstructionArchivalEntities"
                            :process="activeProcessData"
                            :inventory="inventoryData"
                            @markForDeduction="goRefresh(true)"
                            @enrollment="goRefresh(true)"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel
                    value="digitalObjects"
                    v-if="
                        renderComponent &&
                        !activeProcessData?.id &&
                        inventoryData.descriptionLevelCode === InventoryDescriptionLevel.systemInventory
                    "
                >
                    <v-expansion-panel-title>{{ t('inventories.panels.digitalFiles') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <InventoryDigitalObjects :inventory="inventoryData" />
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="packageA" v-if="inventoryData.packageAId">
                    <v-expansion-panel-title>{{ t('packages.packageA') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <PackageA
                            :showAdd="
                                editPackageАEnabled &&
                                (!inventoryData.applicationId || inventoryData.hasSystemApplication == true)
                            "
                            :packageId="inventoryData.packageAId"
                            :packageType="'A'"
                            :inventoryId="inventoryData.systemIdentifier!"
                            :readonly="!editPackageАEnabled"
                            :processId="activeProcessData?.id || 0"
                        ></PackageA>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel
                    value="packageB"
                    v-if="
                        inventoryData.packageBId &&
                        !(
                            inventoryData.descriptionLevelCode === InventoryDescriptionLevel.inventory &&
                            !activeProcessData?.id
                        )
                    "
                >
                    <v-expansion-panel-title>{{ t('packages.packageB') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <PackageA
                            v-if="!useImportFile"
                            :showAdd="
                                editPackageBEnabled &&
                                (!inventoryData.applicationId || inventoryData.hasSystemApplication == true)
                            "
                            :packageId="inventoryData.packageBId"
                            :packageType="'B'"
                            :showGenerate="true"
                            :inventoryId="inventoryData.systemIdentifier!"
                            :readonly="!editPackageBEnabled"
                            :processId="activeProcessData?.id || 0"
                        ></PackageA>
                        <PackageBWithImport
                            v-if="useImportFile"
                            :readonly="!editPackageBEnabled || !!inventoryData.applicationId"
                            :inventoryIdentifier="inventoryData.systemIdentifier!"
                            :packageId="inventoryData.packageBId"
                            @refresh="goRefresh(true)"
                        ></PackageBWithImport>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel class="v-expansion-panel" value="publicUsersReviews">
                    <v-expansion-panel-title>{{ t('common.reviewsHistory') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <public-user-reviews
                            :systemIdentifier="inventoryData.systemIdentifier"
                            :type="$t('inventories.inventory')"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
            <v-row class="mt-3" v-if="editEnabled">
                <v-col class="d-flex gap-2 justify-content-center">
                    <v-btn @click="goEdit"
                        >{{ t('common.edit') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('inventories.buttons.editTooltip') }}
                        </v-tooltip>
                    </v-btn>
                    <back-btn @click="goBack"
                        >{{ t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('inventories.buttons.backTooltip') }}
                        </v-tooltip>
                    </back-btn>
                </v-col>
            </v-row>
            <v-row class="mt-1 mb-1" v-if="!editEnabled && inventoryData.hasExternalSource">
                <v-col class="col-12 ma-auto">
                    <v-alert class="justify-content-center" type="info" variant="tonal" style="font-size: 1.1rem">
                        {{ t('inventories.externalSourceInventory') }}
                    </v-alert>
                </v-col>
            </v-row>
            <v-row class="mt-3" v-if="!editEnabled">
                <v-col class="d-flex gap-2 justify-content-center">
                    <back-btn class="cancel" @click="goBack"
                        >{{ t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('inventories.buttons.backTooltip') }}
                        </v-tooltip>
                    </back-btn>
                </v-col>
            </v-row>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, computed, watch, Ref } from 'vue';
import { useStore } from '@/store/user';
import { LocationQueryRaw, useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { validate as isValidGuid } from 'uuid';
import { useStore as useAppStore } from '@/store/app';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { formatBytesToMB, formatDate, defaultGuidString } from '@/helpers/format.helper';
import { isProcessStepType, isProcessType } from '@/helpers/validate.helper';
import { entityObjectType } from '@/helpers/entityObject.helper';
import DeductionProcessPanel from '@/components/deductionProcess/display.vue';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { InventoryArray } from '@/enums/inventory';
import { EntityType } from '@/enums/entity';
import { BusinessObjectType } from '@/models/grid';
import { IInventory } from '@/interfaces/inventory';
import { Inventory } from '@/models/inventory';
import { IProcess } from '@/interfaces/process';
import { ProcessStep, ProcessType } from '@/enums/process';
import { ProcessModel } from '@/models/process';
import { RoleNames } from '@/enums/roles';
import { Status, AvailabilityStatus } from '@/enums/status';
import { InventoryDescriptionLevel } from '@/enums/inventory';
import { IApplicationDisplay } from '@/models/applications';
import authorization from '@/helpers/authorization.helper';
import inventoryService from '@/services/inventory.service';
import processService from '@/services/process.service';
import editDataProcessService from '@/services/editDataProcess.service';
import refineDataProcessService from '@/services/refineDataProcess.service';
import deductionService from '@/services/deductionProcess.service';
import DeductionDataProcessActions from '@/components/deductionProcess/actions.vue';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import StartProcessPanel from '@/components/process/startPanel.vue';
import ProcessInformationPanel from '@/components/process/processInfoPanel.vue';
import TimelinePanel from '@/components/process/timelinePanel.vue';
import EditDataProcessActions from '@/components/editDataProcess/actions.vue';
import PackageA from '@/components/packageA/packageA.inventory.vue';
import RefineDataProcessActions from '@/components/refineDataProcess/actions.vue';
import RefineDataProcessSteps from '@/components/refineDataProcess/steps.vue';
import ReconstructFundDataProcessActions from '@/components/reconstructFundDataProcess/actions.vue';
import ReconstructFundDataProcessSteps from '@/components/reconstructFundDataProcess/steps.vue';
import ReconstructionArchivalEntities from '@/components/reconstructFundDataProcess/archivalEntities.vue';
import InventoryArchivalEntities from '@/components/archivalEntity/inventoryArchivalEntities.vue';
import InventoryDigitalObjects from '@/components/digitalObject/inventoryDigitalObjects.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import eDocsProcessPanels from '@/components/eDocsCollection/processProgressPanels.vue';
import PublicUserReviews from '@/components/reviews/publicUserReviews.vue';
import applicationService from '@/services/applications.service';
import PackageBWithImport from '@/components/packageB/packageBWithImport.vue';
import Loader from '@/components/loader/loader.vue';
//import ConfirmDialog from '@/components/confirm/confirmDialog.vue';

export default defineComponent({
    name: 'DisplayInventory',
    components: {
        Loader,
        TextField,
        TextAreaField,
        Switch,
        PackageA,
        InventoryArchivalEntities,
        InventoryDigitalObjects,
        StartProcessPanel,
        //ConfirmDialog,
        ProcessInformationPanel,
        TimelinePanel,
        EditDataProcessActions,
        RefineDataProcessActions,
        RefineDataProcessSteps,
        DeductionProcessPanel,
        ReconstructFundDataProcessActions,
        ReconstructFundDataProcessSteps,
        ReconstructionArchivalEntities,
        Breadcrumbs,
        eDocsProcessPanels,
        PublicUserReviews,
        PackageBWithImport,
        DeductionDataProcessActions,
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
        const showViewCardButtons = ref(false);
        const processEntityTypes = [BusinessObjectType.inventory];
        const message = inject('notificationMessage') as Ref<IMessage>;
        const panel = ref([
            'generalInfo',
            'inventoryInfo',
            'additional',
            'chronologicalScope',
            'storage',
            'copies',
            'archivalEntities',
        ]);
        const processPanel = ref(['processInfo', 'startProcess']);

        const showStartProcessPanel = ref(false);
        const showProcessInfoPanel = ref(false);
        const appStore = useAppStore();
        const userStore = useStore();
        const isUserRelatedToActiveProcess = ref(false);
        const renderComponent = ref(false);
        const undoDeductionChanges = ref(false);
        const hasRoleB = computed(() => userStore.getters.hasRole(RoleNames.GroupB));
        const possibleEmptyFields = {
            fundCreatorTitleHistory: '',
            fundCreatorBiographicalHistory: '',
            history: '',
            documentsDescription: '',
            documentsAccessDescription: '',
            classificationScheme: '',
            abbreviationList: '',
            notes: '',
        };
        const enablePrintInventory = computed(() =>
            // activeProcessData.value &&
            // (activeProcessData.value.processTypeId == ProcessType.AddInventory ||
            //     activeProcessData.value.processTypeId == ProcessType.AddRawInventory ||
            //     activeProcessData.value.processTypeId == ProcessType.AddFundAndInventory ||
            //     activeProcessData.value.processTypeId == ProcessType.AddRawFundAndRawInventory ||
            //     activeProcessData.value.processTypeId == ProcessType.RefineData ||
            //     activeProcessData.value.processTypeId == ProcessType.ReconstructFundData)
            {
                return true;
            }
        );

        const lowClass = 'low';
        const isLoading = ref(false);

        const enableStartProcessPanel = computed(
            () =>
                inventoryData.value &&
                inventoryData.value.statusCode !== Status.Deducted &&
                inventoryData.value.statusCode !== Status.Deleted
        );

        //TODO трябва да се разбие на по-малки и ясни условия
        const editEnabled = computed(
            () =>
                (!inventoryData.value.hasExternalSource ||
                    (inventoryData.value.statusCode !== Status.Deducted &&
                        inventoryData.value.statusCode !== Status.Deleted)) &&
                activeProcessData.value &&
                (activeProcessData.value?.processTypeId === ProcessType.EditData ||
                    activeProcessData.value?.processTypeId === ProcessType.RefineData ||
                    (isProcessType(
                        activeProcessData.value,
                        ProcessType.AddInventory,
                        ProcessType.AddRawInventory,
                        ProcessType.AddRawInventoryRaw,
                        ProcessType.AddFundAndInventory,
                        ProcessType.AddRawFundAndRawInventory,
                        ProcessType.AddSystemInventory
                    ) &&
                        isProcessStepType(
                            activeProcessData.value,
                            ProcessStep.AddPackages,
                            ProcessStep.CommissionReport,
                            ProcessStep.CommissionReportEdit,
                            ProcessStep.CommissionCorrections,
                            ProcessStep.Registration
                        )) ||
                    (activeProcessData.value?.processTypeId === ProcessType.ProcessRawFundWithRawInventory &&
                        hasRoleB.value == true &&
                        (activeProcessData.value?.activeProcessStepTypeId ===
                            ProcessStep.ProcessRawFundWithRawInventory_CreateInventories ||
                            activeProcessData.value?.activeProcessStepTypeId ===
                                ProcessStep.ProcessRawFundWithRawInventory_RegisterInventories ||
                            activeProcessData.value?.activeProcessStepTypeId ===
                                ProcessStep.ProcessRawFundWithRawInventory_DataModifications ||
                            activeProcessData.value?.activeProcessStepTypeId ===
                                ProcessStep.ProcessRawFundWithRawInventory_ReportModifications)) ||
                    (activeProcessData.value?.processTypeId === ProcessType.ProcessFundWithRawInventory &&
                        hasRoleB.value == true &&
                        (activeProcessData.value?.activeProcessStepTypeId ===
                            ProcessStep.ProcessFundWithRawInventory_CreateInventories ||
                            activeProcessData.value?.activeProcessStepTypeId ===
                                ProcessStep.ProcessFundWithRawInventory_RegisterInventories ||
                            activeProcessData.value?.activeProcessStepTypeId ===
                                ProcessStep.ProcessFundWithRawInventory_DataModifications ||
                            activeProcessData.value?.activeProcessStepTypeId ===
                                ProcessStep.ProcessFundWithRawInventory_ReportModifications)) ||
                    (activeProcessData.value.processTypeId === ProcessType.ReconstructFundData &&
                        activeProcessData.value.activeProcessStepTypeId ===
                            ProcessStep.ReconstructFundData_Registration))
        );

        const archivalEntitySelectionEnabled = computed(
            () => activeProcessData.value && activeProcessData.value.processTypeId === ProcessType.ReconstructFundData
        );
        const isdaDataCannotBeDisplayed = ref(false);
        const addArchivalEntityEnabled = computed(
            () =>
                activeProcessData.value &&
                isProcessType(
                    activeProcessData.value,
                    ProcessType.AddInventory,
                    ProcessType.AddRawInventory,
                    ProcessType.AddRawInventoryRaw,
                    ProcessType.AddFundAndInventory,
                    ProcessType.AddRawFundAndRawInventory
                ) &&
                isProcessStepType(
                    activeProcessData.value,
                    ProcessStep.AddPackages,
                    ProcessStep.CommissionReport,
                    ProcessStep.CommissionReportEdit,
                    ProcessStep.CommissionCorrections
                )
        );

        const deleteArchivalEntityEnabled = computed(
            () =>
                activeProcessData.value &&
                ((activeProcessData.value?.processTypeId === ProcessType.ProcessRawFundWithRawInventory &&
                    (activeProcessData.value?.activeProcessStepTypeId ===
                        ProcessStep.ProcessRawFundWithRawInventory_CreateInventories ||
                        activeProcessData.value?.activeProcessStepTypeId ===
                            ProcessStep.ProcessRawFundWithRawInventory_ReportModifications ||
                        activeProcessData.value?.activeProcessStepTypeId ===
                            ProcessStep.ProcessRawFundWithRawInventory_DataModifications)) ||
                    (activeProcessData.value?.processTypeId === ProcessType.ProcessFundWithRawInventory &&
                        (activeProcessData.value?.activeProcessStepTypeId ===
                            ProcessStep.ProcessFundWithRawInventory_CreateInventories ||
                            activeProcessData.value?.activeProcessStepTypeId ===
                                ProcessStep.ProcessFundWithRawInventory_ReportModifications ||
                            activeProcessData.value?.activeProcessStepTypeId ===
                                ProcessStep.ProcessFundWithRawInventory_DataModifications)))
        );

        const showReconstructionArchivalEntities = computed(
            () =>
                activeProcessData.value &&
                activeProcessData.value.processTypeId === ProcessType.ReconstructFundData &&
                (activeProcessData.value.activeProcessStepTypeId === ProcessStep.ReconstructFundData_EditData ||
                    activeProcessData.value.activeProcessStepTypeId ===
                        ProcessStep.ReconstructFundData_DataModifications ||
                    activeProcessData.value.activeProcessStepTypeId ===
                        ProcessStep.ReconstructFundData_ReportModifications) &&
                inventoryData.value &&
                inventoryData.value.availabilityStatusCode !== AvailabilityStatus.DisposalDeduction &&
                inventoryData.value.availabilityStatusCode !== AvailabilityStatus.RelocationDeduction
        );

        const applicationTitle = computed(() => {
            if (inventoryData.value.applicationId) {
                return `${applicationData.value.number} / ${formatDate(applicationData.value.applicationDate)} ${
                    applicationData.value.applicantFullName
                }`;
            }
            return '';
        });
        const router = useRouter();

        const goBack = () => {
            if (inventoryData.value.fundSystemIdentifier != undefined || inventoryData.value.fundHasExternalSource) {
                useRedirect(
                    router,
                    'DisplayFund',
                    {
                        id:
                            inventoryData.value.fundSystemIdentifier != undefined
                                ? inventoryData.value.fundSystemIdentifier
                                : defaultGuidString(),
                    },
                    {
                        hasExternalSource: String(inventoryData.value.fundHasExternalSource),
                        externalIdentifier: inventoryData.value.fundHasExternalSource
                            ? inventoryData.value.fundExternalIdentifier?.toString()
                            : '',
                    }
                );
            } else {
                useRedirect(router, 'Inventories');
            }
        };

        const goEdit = () => {
            if (inventoryData.value.systemIdentifier && !inventoryData.value.hasExternalSource) {
                useRedirectWithId(router, 'EditInventory', inventoryData.value.systemIdentifier);
            } else {
                message.value = new Message({
                    text: t('error.operationError'),
                    display: true,
                });
            }
        };

        const goRefresh = async (refreshPage?: boolean) => {
            if (refreshPage) {
                router.go(0);
            } else {
                await getActiveProcessData();
            }
        };

        const entityType = computed(() => {
            return entityObjectType(EntityType.inventory, inventoryData.value.descriptionLevelCode);
        });

        const addFromPackageEnabled = computed(
            () =>
                activeProcessData.value != null &&
                ((activeProcessData.value?.processTypeId === ProcessType.ProcessRawFundWithRawInventory &&
                    (activeProcessData.value?.activeProcessStepTypeId ===
                        ProcessStep.ProcessRawFundWithRawInventory_CreateInventories ||
                        activeProcessData.value?.activeProcessStepTypeId ===
                            ProcessStep.ProcessRawFundWithRawInventory_ReportModifications ||
                        activeProcessData.value?.activeProcessStepTypeId ===
                            ProcessStep.ProcessRawFundWithRawInventory_DataModifications)) ||
                    (activeProcessData.value?.processTypeId === ProcessType.ProcessFundWithRawInventory &&
                        (activeProcessData.value?.activeProcessStepTypeId ===
                            ProcessStep.ProcessFundWithRawInventory_CreateInventories ||
                            activeProcessData.value?.activeProcessStepTypeId ===
                                ProcessStep.ProcessFundWithRawInventory_ReportModifications ||
                            activeProcessData.value?.activeProcessStepTypeId ===
                                ProcessStep.ProcessFundWithRawInventory_DataModifications))) &&
                inventoryData.value != null &&
                inventoryData.value.packageBId != null
        );

        const editPackageАEnabled = computed(
            () =>
                activeProcessData.value &&
                inventoryData.value &&
                inventoryData.value.packageAId &&
                isProcessType(
                    activeProcessData.value,
                    ProcessType.AddRawInventory,
                    ProcessType.AddRawInventoryRaw,
                    ProcessType.AddRawFundAndRawInventory,
                    ProcessType.AddInventory,
                    ProcessType.AddFundAndInventory,
                    ProcessType.AddSystemInventory
                ) &&
                isProcessStepType(
                    activeProcessData.value,
                    ProcessStep.AddPackages,
                    ProcessStep.CommissionReport,
                    ProcessStep.CommissionReportEdit,
                    ProcessStep.CommissionCorrections,
                    ProcessStep.CommissionCorrections_PackagesEdit
                )
        );

        const editPackageBEnabled = computed(
            () =>
                activeProcessData.value != null &&
                inventoryData.value != null &&
                inventoryData.value.packageBId != null &&
                isProcessType(
                    activeProcessData.value,
                    ProcessType.AddRawInventory,
                    ProcessType.AddRawInventoryRaw,
                    ProcessType.AddRawFundAndRawInventory,
                    ProcessType.AddInventory,
                    ProcessType.AddFundAndInventory,
                    ProcessType.AddSystemInventory
                ) &&
                isProcessStepType(
                    activeProcessData.value,
                    ProcessStep.AddPackages,
                    ProcessStep.CommissionReport,
                    ProcessStep.CommissionReportEdit,
                    ProcessStep.CommissionCorrections,
                    ProcessStep.CommissionCorrections_PackagesEdit
                )
        );

        const inventoryData = ref<IInventory>(new Inventory());
        const inventoryArray = InventoryArray;
        const applicationData = ref({} as IApplicationDisplay);
        const applicationPointer = computed(() => {
            return inventoryData.value.applicationId ? 'cursor: pointer;' : 'cursor: auto;';
        });
        const activeProcessData = ref<IProcess>();
        const formattedBytes = computed(() => {
            return formatBytesToMB(inventoryData.value.bytes || 0);
        });

        const formattedEnrolledBytes = computed(() => {
            return formatBytesToMB(inventoryData.value.enrolledBytes || 0);
        });
        const formattedDeductedBytes = computed(() => {
            return formatBytesToMB(inventoryData.value.deductedBytes || 0);
        });
        const getInventoryData = async () => {
            try {
                isLoading.value = true;
                const result = await inventoryService.displayInventory(
                    props.id,
                    props.hasExternalSource,
                    props.externalIdentifier
                );

                if (result) {
                    inventoryData.value = result;
                }

                if (!inventoryData.value.fundCreatorTitleHistory) {
                    possibleEmptyFields.fundCreatorTitleHistory = lowClass;
                }
                if (!inventoryData.value.fundCreatorBiographicalHistory) {
                    possibleEmptyFields.fundCreatorBiographicalHistory = lowClass;
                }
                if (!inventoryData.value.history) {
                    possibleEmptyFields.history = lowClass;
                }
                if (!inventoryData.value.documentsDescription) {
                    possibleEmptyFields.documentsDescription = lowClass;
                }
                if (!inventoryData.value.documentsAccessDescription) {
                    possibleEmptyFields.documentsAccessDescription = lowClass;
                }
                if (!inventoryData.value.classificationScheme) {
                    possibleEmptyFields.classificationScheme = lowClass;
                }
                if (!inventoryData.value.abbreviationList) {
                    possibleEmptyFields.abbreviationList = lowClass;
                }
                if (!inventoryData.value.notes) {
                    possibleEmptyFields.notes = lowClass;
                }
                if (inventoryData.value.applicationId) await getApplicationData();

                if (
                    inventoryData.value.resultMessage &&
                    inventoryData.value.resultMessage === 'ISDADataCannotBeDisplayed'
                ) {
                    message.value = new Message({
                        text: t('warnings.ISDADataCannotBeDisplayed'),
                        display: true,
                        type: 'warning',
                    });
                    isdaDataCannotBeDisplayed.value = true;
                }

                showViewCardButtons.value = inventoryData.value.isDraft != undefined && !inventoryData.value.isDraft;
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
                    activeProcessData.value = await processService.getCurrentActiveProcess(
                        BusinessObjectType.inventory,
                        props.id,
                        true,
                        props.externalIdentifier
                    );

                    if (activeProcessData.value?.id) {
                        isUserRelatedToActiveProcess.value = await processService.getIsCurrentUserInProcess(
                            activeProcessData.value.id!
                        );
                        if (breadcrumbItems.value.length > 3) {
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

        const getApplicationData = async () => {
            try {
                if (inventoryData.value.applicationId) {
                    applicationService
                        .get(inventoryData.value.applicationId)
                        .then((data) => {
                            applicationData.value = data;
                        })
                        .catch((error) => console.log(error));
                }
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        const goToApplication = async () => {
            if (inventoryData.value.applicationId)
                router.push('/edocscollection/applications/display/' + inventoryData.value.applicationId);
        };

        const btnStartProcessClickHandler = async (processType?: number) => {
            try {
                const process = new ProcessModel({
                    processTypeId: processType,
                    archiveId: inventoryData.value.archiveId,
                    inventorySystemIdentifier: inventoryData.value.systemIdentifier,
                });

                let result = null;

                const hasSystemIdentifier = () => {
                    if (process.inventorySystemIdentifier == undefined) {
                        throw new Error('CantStart');
                    }
                };

                switch (processType) {
                    case ProcessType.EditData:
                        //if (authorization.isAdmin(AdminType.Admin)) {
                        if (authorization.hasRole(RoleNames.GroupB1, inventoryData.value.archiveId!)) {
                            hasSystemIdentifier();
                            if (inventoryData.value.hasExternalSource) {
                                throw new Error('CantStart');
                            }
                            await editDataProcessService.startProcess(process);
                            goEdit();
                        } else {
                            throw new Error('NoPermissions');
                        }
                        break;
                    case ProcessType.RefineData:
                        if (authorization.hasRole(RoleNames.GroupB, inventoryData.value.archiveId)) {
                            hasSystemIdentifier();
                            if (inventoryData.value.hasExternalSource) {
                                result = await refineDataProcessService.hasEntitiesInCEA(process);
                                if (!result.succeeded) {
                                    throw new Error('NoDataInCEA');
                                }
                            }

                            await refineDataProcessService.startProcess(process);
                            if (!inventoryData.value.hasExternalSource) goEdit();
                            else throw new Error('startedOnLowerEntities');
                        } else {
                            throw new Error('NoPermissions');
                        }
                        break;
                    case ProcessType.DeductData: {
                        hasSystemIdentifier();
                        if (inventoryData.value.hasExternalSource) {
                            throw new Error('CantStart');
                        }
                        if (authorization.hasRole(RoleNames.GroupB)) {
                            if (inventoryData.value.isDraft == false) {
                                await deductionService.start(
                                    props.id!,
                                    props.externalIdentifier!,
                                    BusinessObjectType.inventory,
                                    inventoryData.value.archiveId!
                                );
                                router.go(0);
                            } else {
                                throw new Error('isDraft');
                            }
                        } else {
                            throw new Error('NoPermissions');
                        }
                        break;
                    }
                    case ProcessType.AddInventory:
                        console.log('Dobawqne na poreden opis');
                        break;
                    default:
                        break;
                }
            } catch (error) {
                if (error.message == 'CantStart') {
                    message.value = new Message({
                        text: t('error.cantStartProcess'),
                        display: true,
                    });
                } else if (error.message == 'NoDataInCEA') {
                    message.value = new Message({
                        text: t('error.noDataInCEA', { entity: t('inventories.inventory') }),
                        display: true,
                    });
                } else if (error.message == 'NoPermissions') {
                    message.value = new Message({
                        text: t('error.noPermissions'),
                        display: true,
                    });
                } else if (error.message == 'startedOnLowerEntities') {
                    message.value = new Message({
                        text: t('warnings.processStartedOnLowerEntities'),
                        type: 'warning',
                        display: true,
                    });
                } else {
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                }
            }
        };
        const redirectToEntityInIsda = () =>
            window.open(
                `${appStore.state.externalSourceDisplayEntityBaseUrl}Inventory&agid=${inventoryData.value.archiveCode}&flgid=${inventoryData.value.fundExternalIdentifier}&ilgid=${inventoryData.value.externalIdentifier}`,
                '_blank'
            );
        const languageText = computed(() => inventoryData?.value?.languageText);
        const breadcrumbItems = computed(() => [
            {
                title: inventoryData.value.archiveName,
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('funds.fund'),
                disabled: false,
                to: {
                    name: 'DisplayFund',
                    params: {
                        id: inventoryData.value.fundSystemIdentifier,
                    },
                    query: {
                        hasExternalSource: inventoryData.value.fundHasExternalSource,
                        externalIdentifier: inventoryData.value.fundExternalIdentifier,
                    },
                },
            },
            {
                title: t('inventories.inventory'),
                disabled: true,
            },
        ]);

        watch(
            () => props.id,
            async (newVal, oldVal) => {
                if (newVal && newVal !== oldVal && isValidGuid(newVal)) {
                    await getInventoryData();
                    await getActiveProcessData();
                }
            }
        );

        const viewCardForm1A = () => {
            try {
                const { href } = router.resolve({
                    name: 'BaseReport',
                    params: {
                        componentName: 'CardForm1AData',
                        id: inventoryData.value.systemIdentifier,
                    },
                    query: {
                        hasExternalSource: String(inventoryData.value.hasExternalSource),
                        externalIdentifier: inventoryData.value.externalIdentifier,
                    },
                });
                window.open(href, '_blank');
            } catch (err: unknown) {
                message.value = new Message({
                    text: t('error.operationError'),
                    display: true,
                });
            }
        };
        onMounted(async () => {
            window.scrollTo(0, 0);
            await getInventoryData();
            await getActiveProcessData();
            renderComponent.value = true;
        });

        const isCollectiongProcedurePanelVisible = computed(() => {
            let visible = false;
            if (activeProcessData.value) {
                visible =
                    showProcessInfoPanel.value &&
                    activeProcessData.value.inventorySystemIdentifier === inventoryData.value.systemIdentifier &&
                    isUserRelatedToActiveProcess &&
                    (activeProcessData.value.processTypeId === ProcessType.AddInventory ||
                        activeProcessData.value.processTypeId === ProcessType.AddSystemInventory ||
                        activeProcessData.value.processTypeId === ProcessType.AddRawInventoryRaw ||
                        activeProcessData.value.processTypeId === ProcessType.AddFundAndInventory ||
                        activeProcessData.value.processTypeId === ProcessType.AddRawFundAndRawInventory);
            }

            return visible;
        });

        const goPrintInventory = async () => {
            let result;
            if (activeProcessData.value?.processTypeId == null) {
                result = await processService.getLastProcessType(props.id);
            }

            const routeQuery: LocationQueryRaw = {
                hasExternalSource: String(inventoryData.value?.hasExternalSource),
                externalIdentifier: inventoryData.value?.externalIdentifier,
                processTypeId: activeProcessData.value?.processTypeId
                    ? activeProcessData.value?.processTypeId
                    : (result as number),
            };
            useRedirect(
                router,
                'PrintInventory',
                {
                    componentName: inventoryData.value.numberArray ?? InventoryArray.E,
                    id: inventoryData.value?.systemIdentifier,
                },
                routeQuery
            );
        };

        const useImportFile = computed(() => {
            let visible = false;
            if (activeProcessData.value) {
                visible =
                    !inventoryData.value.applicationId &&
                    (activeProcessData.value.processTypeId === ProcessType.AddInventory ||
                        activeProcessData.value.processTypeId === ProcessType.AddFundAndInventory);
            }
            console.log('useImportFile', visible);
            console.log('application', inventoryData.value.applicationId);
            console.log('process', activeProcessData.value?.processTypeId);
            return visible;
        });

        return {
            t,
            processEntityTypes,
            formattedEnrolledBytes,
            formattedDeductedBytes,
            undoDeductionChanges,
            panel,
            processPanel,
            editEnabled,
            showViewCardButtons,
            entityType,
            inventoryData,
            activeProcessData,
            enableStartProcessPanel,
            showStartProcessPanel,
            showProcessInfoPanel,
            showReconstructionArchivalEntities,
            archivalEntitySelectionEnabled,
            addArchivalEntityEnabled,
            redirectToEntityInIsda,
            formatDate,
            goEdit,
            viewCardForm1A,
            goBack,
            goRefresh,
            btnStartProcessClickHandler,
            message,
            ProcessType,
            ProcessStep,

            isUserRelatedToActiveProcess,
            breadcrumbItems,
            renderComponent,
            isCollectiongProcedurePanelVisible,
            possibleEmptyFields,
            InventoryDescriptionLevel,
            addFromPackageEnabled,
            formattedBytes,
            applicationData,
            getApplicationData,
            goToApplication,
            applicationPointer,
            applicationTitle,
            deleteArchivalEntityEnabled,
            editPackageАEnabled,
            editPackageBEnabled,
            useImportFile,
            inventoryArray,
            goPrintInventory,
            languageText,
            isLoading,
            enablePrintInventory,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/index-1.scss';
@import '@/assets/styles/breadcrumbs-inv.scss';

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
