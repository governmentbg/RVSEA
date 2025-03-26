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
                                activeProcessData?.processTypeId === ProcessType.ReconstructFundData &&
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
                                activeProcessData.documentSystemIdentifier
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
                    :entityType="processEntityTypes"
                    @startProcess="btnStartProcessClickHandler"
                    :readOnly="!enableStartProcessPanel"
                />
                <timeline-panel
                    v-if="showProcessInfoPanel && isUserRelatedToActiveProcess"
                    :processId="activeProcessData!.id!"
                    :showExpanded="false"
                />
            </v-expansion-panels>
            <DigObJProcesesPanel
                v-if="
                    activeProcessData &&
                    isUserRelatedToActiveProcess &&
                    (activeProcessData.processTypeId == ProcessType.AddDocument ||
                        activeProcessData.processTypeId == ProcessType.PreparationOfADigitalObject ||
                        activeProcessData.processTypeId == ProcessType.ImportDigitalObject)
                "
                :documentSystemIdentifier="id"
                :hasExternalSource="hasExternalSource"
                class="processPanel"
            />
            <StartDigObJProcesesPanel
                :documentSystemIdentifier="id"
                :archiveId="documentData.archiveId"
                :hasExternalSource="hasExternalSource"
                ref="digObJProcesesPanel"
                v-if="!activeProcessData"
            />
            <DeductionProcessPanel
                v-if="
                    activeProcessData &&
                    activeProcessData.processTypeId == ProcessType.DeductData &&
                    isUserRelatedToActiveProcess &&
                    activeProcessData.documentSystemIdentifier
                "
                :process="activeProcessData"
                :entityType="processEntityTypes"
                ref="deductionProcessPanel"
                class="processPanel"
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
    <v-row v-if="!editEnabled && documentData.hasExternalSource" class="mb-1 mt-1">
        <v-col class="col-12 col-md-9 col-lg-9 ma-auto">
            <v-alert class="justify-content-center" type="info" variant="tonal" style="font-size: 1.1rem">
                {{ t('documents.externalSourceDocument') }}
            </v-alert>
        </v-col>
    </v-row>
    <v-card ref="documentCard" class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('documents.display') }}</v-card-title>
        <v-container>
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel value="generalInfo">
                    <v-expansion-panel-title>{{ t('documents.panels.generalInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldArchive"
                                    :label="t('documents.columns.archive')"
                                    v-model="documentData.archiveName"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldFundNumber"
                                    :label="t('documents.columns.fund')"
                                    v-model="documentData.fundNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldInventoryNumber"
                                    :label="t('documents.columns.inventory')"
                                    v-model="documentData.inventoryNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldArchiveEntityNumber"
                                    :label="t('documents.columns.archivalEntity')"
                                    v-model="documentData.archivalEntityNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldNumber"
                                    :label="t('documents.columns.number')"
                                    v-model="documentData.number"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldSystemIdentifier"
                                    :label="t('documents.columns.systemIdentifier')"
                                    v-model="documentData.systemIdentifier"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldCreatedByDisplayName"
                                    :label="t('documents.columns.author')"
                                    v-model="documentData.createdByDisplayName"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldCreatedOn"
                                    :label="t('documents.columns.creationDate')"
                                    :modelValue="formatDate(documentData.createdOn)"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row v-if="documentData.updatedOn">
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldUpdatedByDisplayName"
                                    :label="t('documents.columns.updatedBy')"
                                    v-model="documentData.updatedByDisplayName"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldUpdatedOn"
                                    :label="t('documents.columns.updatedOn')"
                                    :modelValue="formatDate(documentData.updatedOn)"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="documentInfo">
                    <v-expansion-panel-title>{{ t('documents.panels.documentInfo') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col :class="possibleEmptyFields.title">
                                <text-area-field
                                    name="fldTitle"
                                    :label="t('documents.columns.title')"
                                    v-model="documentData.title"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldNumber"
                                    :label="t('documents.columns.number')"
                                    v-model="documentData.number"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDescriptionLevel"
                                    :label="t('documents.columns.descriptionLevel')"
                                    v-model="documentData.descriptionLevelText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldStatus"
                                    :label="t('documents.columns.status')"
                                    v-model="documentData.statusText"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldAvailabilityStatus"
                                    :label="t('documents.columns.availabilityStatus')"
                                    v-model="documentData.availabilityStatusText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldFileFormat"
                                    :label="t('documents.columns.fileFormat')"
                                    v-model="documentData.fileTypeText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-6" v-if="documentData.inventoryNumberArray !== inventoryArray.E">
                                <text-field
                                    name="fldCypher"
                                    :label="t('documents.columns.cypher')"
                                    v-model="documentData.cypher"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-6">
                                <text-field
                                    name="fldDescriptionAuthor"
                                    :label="t('documents.columns.descriptionAuthor')"
                                    v-model="documentData.descriptionAuthor"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="general">
                    <v-expansion-panel-title>{{ t('documents.panels.sheetsNumbers') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldStartSheetNumber"
                                    :label="t('documents.columns.from')"
                                    v-model="documentData.startSheetNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldEndSheetNumber"
                                    :label="t('documents.columns.to')"
                                    v-model="documentData.endSheetNumber"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="chronologicalScope">
                    <v-expansion-panel-title>{{ t('documents.panels.datePlaceOfCreation') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <v-col class="col-12">
                                    <Switch
                                        v-model="documentData.hasNoChronologicalScope"
                                        :label="t('documents.columns.chronologicalScope')"
                                        :large="false"
                                        :showLabel="true"
                                        :disabled="true"
                                    />
                                </v-col>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <label>{{ t('documents.startDate') }}</label>
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateDay"
                                    :label="t('common.day')"
                                    v-model="documentData.startDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateMonth"
                                    :label="t('common.month')"
                                    v-model="documentData.startDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldStartDateYear"
                                    :label="t('common.year')"
                                    v-model="documentData.startDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <label>{{ t('documents.endDate') }}</label>
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateDay"
                                    :label="t('common.day')"
                                    v-model="documentData.endDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateMonth"
                                    :label="t('common.month')"
                                    v-model="documentData.endDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-4">
                                <text-field
                                    name="fldEndDateYear"
                                    :label="t('common.year')"
                                    v-model="documentData.endDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldApproximateChronologicalScope"
                                    :label="t('documents.columns.approximateChronologicalScope')"
                                    v-model="documentData.approximateChronologicalScope"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.location">
                                <text-area-field
                                    name="fldLocation"
                                    :label="t('documents.columns.placeOfCreation')"
                                    v-model="documentData.location"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldAuthor"
                                    :label="t('documents.columns.creator')"
                                    v-model="documentData.author"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-6">
                                <text-field
                                    name="fldTextDocsCount"
                                    :label="t('documents.columns.textDocsCount')"
                                    v-model="documentData.textDocsCount"
                                    :readOnly="true"
                                />
                            </v-col>
                            <v-col class="col-6">
                                <text-field
                                    name="fldGraphicalDocsCount"
                                    :label="t('documents.columns.graphicalDocsCount')"
                                    v-model="documentData.graphicalDocsCount"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="storage">
                    <v-expansion-panel-title>{{ t('documents.panels.storage') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldSheetsCount"
                                    :label="t('documents.columns.sheetsCount')"
                                    v-model="documentData.sheetCount"
                                    validation="numeric"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDigitalDevice"
                                    :label="t('documents.columns.nonPaperCarrier')"
                                    v-model="documentData.digitalDevice"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOther"
                                    :label="t('documents.columns.other')"
                                    v-model="documentData.otherMetrics"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldSizeCm"
                                    :label="t('documents.columns.sizeCm')"
                                    v-model="documentData.sizeCm"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-6">
                                <text-field
                                    name="fldScale"
                                    :label="t('documents.columns.scale')"
                                    v-model="documentData.scaling"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-6">
                                <text-field
                                    name="fldStage"
                                    :label="t('documents.columns.stage')"
                                    v-model="documentData.stage"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDuration"
                                    :label="t('documents.columns.duration')"
                                    v-model="formattedDuration"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldBytes"
                                    :label="t('documents.columns.bytes')"
                                    v-model="formattedBytes"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.extendedDescription">
                                <text-area-field
                                    name="fldExtendedDescription"
                                    :label="t('documents.columns.extendedDescription')"
                                    v-model="documentData.description"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOriginality"
                                    :label="t('documents.columns.originality')"
                                    v-model="documentData.originalityText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldCreationMethod"
                                    :label="t('documents.columns.creationMethod')"
                                    v-model="documentData.creationMethodText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-6">
                                <text-field
                                    name="fldLanguage"
                                    :label="t('documents.columns.language')"
                                    v-model="languageText"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-6">
                                <text-field
                                    name="fldOtherLanguage"
                                    :label="t('documents.columns.otherLanguage')"
                                    v-model="documentData.otherLanguage"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.documentsAccessDescription">
                                <text-area-field
                                    name="fldAccessConditions"
                                    :label="t('documents.columns.accessConditions')"
                                    v-model="documentData.documentsAccessDescription"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.specifics">
                                <text-area-field
                                    name="fldSpecifics"
                                    :label="t('documents.columns.specifics')"
                                    v-model="documentData.features"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="copies">
                    <v-expansion-panel-title>{{ t('documents.panels.copiesEligibility') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldMicrofilmedCopiesCount"
                                    :label="t('documents.columns.microfilm')"
                                    v-model="documentData.microfilmedCopyCount"
                                    validation="numeric"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDigitalCopy"
                                    :label="t('documents.columns.digitalCopy')"
                                    v-model="documentData.digitizedCopyCount"
                                    validation="numeric"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldXeroxCopy"
                                    :label="t('documents.columns.xeroxCopy')"
                                    v-model="documentData.paperCopyCount"
                                    validation="numeric"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldNegativeFramesCount"
                                    :label="t('documents.columns.negativeFrames')"
                                    v-model="documentData.negativeFrameCount"
                                    validation="numeric"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldPositiveFramesCount"
                                    :label="t('documents.columns.positiveFrames')"
                                    v-model="documentData.positiveFrameCount"
                                    validation="numeric"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldOtherCopyCount"
                                    :label="t('documents.columns.otherCopyCount')"
                                    v-model="documentData.otherCopyCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.notes">
                                <text-area-field
                                    name="fldNotes"
                                    :label="t('documents.columns.note')"
                                    v-model="documentData.notes"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-6">
                                <text-field
                                    name="fldPhase"
                                    :label="t('documents.columns.phase')"
                                    v-model="documentData.phase"
                                    :readOnly="true"
                                />
                            </v-col>
                            <v-col class="col-6">
                                <text-field
                                    name="fldPart"
                                    :label="t('documents.columns.part')"
                                    v-model="documentData.part"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <!-- <v-expansion-panel value="externalSource">
                    <v-expansion-panel-title>{{ t('documents.panels.externalSource') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <Switch
                                    :label="t('documents.columns.hasExternalSource')"
                                    v-model="documentData.hasExternalSource"
                                    :large="false"
                                    :showLabel="true"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12">
                                <text-field
                                    name="fldExternalIdentifier"
                                    :label="t('documents.columns.externalIdentifier')"
                                    v-model="documentData.externalIdentifier"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel> -->
                <v-expansion-panel value="textTranscription">
                    <v-expansion-panel-title>{{ t('documents.columns.textTranscription') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <text-area-field
                                    name="fldTranscription"
                                    :label="t('documents.columns.textTranscription')"
                                    v-model="documentData.transcription"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel class="v-expansion-panel" value="digitalObjects" v-if="renderComponent">
                    <v-expansion-panel-title>{{ t('documents.panels.digitalObjects') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <document-digital-objects
                            :document="documentData"
                            :fileUploadEnabled="addDigitalObjectEnabled"
                            :deleteEnabled="deleteDigitalObjectEnabled"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="digitizedDigitalObjects" v-if="renderComponent">
                    <v-expansion-panel-title>{{
                        t('documents.panels.digitizedDigitalObjects')
                    }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <document-digitized-digital-objects
                            :document="documentData"
                            :deleteEnabled="deleteDigitizedDigitalObjectEnabled"
                            :appendEnabled="appendDigitizedDigitalObjectEnabled"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel class="v-expansion-panel" value="publicUsersReviews">
                    <v-expansion-panel-title>{{ t('common.reviewsHistory') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <public-user-reviews
                            :systemIdentifier="documentData.systemIdentifier"
                            :type="$t('documents.document')"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
            <v-row class="mt-3" v-if="editEnabled">
                <v-col class="d-flex gap-2 justify-content-center">
                    <v-btn @click="goEdit"
                        >{{ t('common.edit') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('documents.buttons.editTooltip') }}
                        </v-tooltip>
                    </v-btn>
                    <back-btn @click="goBack"
                        >{{ t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('documents.buttons.backTooltip') }}
                        </v-tooltip>
                    </back-btn>
                </v-col>
            </v-row>
            <v-row class="mt-1 mb-1" v-if="!editEnabled && documentData.hasExternalSource">
                <v-col class="col-12 ma-auto">
                    <v-alert class="justify-content-center" type="info" variant="tonal" style="font-size: 1.1rem">
                        {{ t('documents.externalSourceDocument') }}
                    </v-alert>
                </v-col>
            </v-row>
            <v-row class="mt-3" v-if="!editEnabled">
                <v-col class="d-flex justify-content-center">
                    <back-btn @click="goBack"
                        >{{ t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('documents.buttons.backTooltip') }}
                        </v-tooltip>
                    </back-btn>
                </v-col>
            </v-row>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, Ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { formatDate, formatBytesToMB, formatDuration, defaultGuidString } from '@/helpers/format.helper';
import { isProcessStepType, isProcessType } from '@/helpers/validate.helper';
import { Message } from '@/models/notification';
//import ConfirmDialog from '@/components/confirm/confirmDialog.vue';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { IDocument } from '@/interfaces/document';
import { Document } from '@/models/document';

import { ProcessModel } from '@/models/process';
import { ProcessStep, ProcessType } from '@/enums/process';
import { BusinessObjectType } from '@/models/grid';
import { Status } from '@/enums/status';
import { IProcess } from '@/interfaces/process';
import { RoleNames } from '@/enums/roles';

import { useStore as useAppStore } from '@/store/app';
import authorization from '@/helpers/authorization.helper';

import documentService from '@/services/document.service';
import processService from '@/services/process.service';
import editDataProcessService from '@/services/editDataProcess.service';
import refineDataProcessService from '@/services/refineDataProcess.service';
import deductionService from '@/services/deductionProcess.service';

import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import StartProcessPanel from '@/components/process/startPanel.vue';
import ProcessInformationPanel from '@/components/process/processInfoPanel.vue';
import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import DigObJProcesesPanel from '@/components/documentCeatingProcedure/display.vue';
import DocumentDigitalObjects from '@/components/digitalObject/documentDigitalObjects.vue';
import DocumentDigitizedDigitalObjects from '@/components/digitalObject/documentDigitizedDigitalObjects.vue';
import TimelinePanel from '@/components/process/timelinePanel.vue';
import EditDataProcessActions from '@/components/editDataProcess/actions.vue';
import RefineDataProcessActions from '@/components/refineDataProcess/actions.vue';
import RefineDataProcessSteps from '@/components/refineDataProcess/steps.vue';
import DeductionProcessPanel from '@/components/deductionProcess/display.vue';
import ReconstructFundDataProcessActions from '@/components/reconstructFundDataProcess/actions.vue';
import ReconstructFundDataProcessSteps from '@/components/reconstructFundDataProcess/steps.vue';
import PublicUserReviews from '@/components/reviews/publicUserReviews.vue';
import DeductionDataProcessActions from '@/components/deductionProcess/actions.vue';
import { InventoryArray } from '@/enums/inventory';
import StartDigObJProcesesPanel from '@/components/documentCeatingProcedure/startDigObJProcesesPanel.vue';
import Loader from '@/components/loader/loader.vue';
export default defineComponent({
    name: 'DisplayDocument',
    components: {
        Loader,
        TextField,
        TextAreaField,
        DeductionProcessPanel,
        Switch,
        DigObJProcesesPanel,
        StartProcessPanel,
        DeductionDataProcessActions,
        StartDigObJProcesesPanel,
        ProcessInformationPanel,
        DocumentDigitalObjects,
        DocumentDigitizedDigitalObjects,
        TimelinePanel,
        EditDataProcessActions,
        RefineDataProcessActions,
        RefineDataProcessSteps,
        ReconstructFundDataProcessActions,
        ReconstructFundDataProcessSteps,
        Breadcrumbs,
        PublicUserReviews,
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
        const dialog = ref(false);
        const showStartProcessPanel = ref(false);
        const showProcessInfoPanel = ref(false);
        const renderComponent = ref(false);
        const appStore = useAppStore();
        const router = useRouter();
        const isUserRelatedToActiveProcess = ref(false);
        const undoDeductionChanges = ref(false);
        const activeProcessData = ref<IProcess>();
        const processEntityTypes = BusinessObjectType.document;
        const documentData = ref<IDocument>(new Document());
        const inventoryArray = InventoryArray;
        const digObJProcesesPanel = ref();
        const possibleEmptyFields = {
            title: '',
            extendedDescription: '',
            specifics: '',
            notes: '',
            location: '',
            documentsAccessDescription: '',
        };
        const formattedDuration = computed(() =>
            documentData.value.duration ? formatDuration(documentData.value.duration) : ''
        );

        const lowClass = 'low';
        const isLoading = ref(false);

        const enableStartProcessPanel = computed(
            () =>
                documentData.value &&
                documentData.value.statusCode !== Status.Deducted &&
                documentData.value.statusCode !== Status.Deleted
        );

        const redirectToEntityInIsda = () =>
            window.open(
                `${appStore.state.externalSourceDisplayEntityBaseUrl}Document&agid=${documentData.value.archiveCode}&flgid=${documentData.value.fundExternalIdentifier}&ilgid=${documentData.value.inventoryExternalIdentifier}&aelgid=${documentData.value.archivalEntityExternalIdentifier}&dlgid=${documentData.value.externalIdentifier}
               `,
                '_blank'
            );
        const editEnabled = computed(
            () =>
                (!documentData.value.hasExternalSource ||
                    (documentData.value.statusCode !== Status.Deducted &&
                        documentData.value.statusCode !== Status.Deleted)) &&
                activeProcessData.value &&
                (isProcessType(activeProcessData.value, ProcessType.EditData, ProcessType.RefineData) ||
                    (isProcessType(
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
                            ProcessStep.CommissionCorrections,
                            ProcessStep.Registration
                        )) ||
                    (isProcessType(activeProcessData.value, ProcessType.ProcessRawFundWithRawInventory) &&
                        isProcessStepType(
                            activeProcessData.value,
                            ProcessStep.ProcessRawFundWithRawInventory_CreateInventories,
                            ProcessStep.ProcessRawFundWithRawInventory_ReportModifications,
                            ProcessStep.ProcessRawFundWithRawInventory_DataModifications
                        )) ||
                    (isProcessType(activeProcessData.value, ProcessType.ProcessFundWithRawInventory) &&
                        isProcessStepType(
                            activeProcessData.value,
                            ProcessStep.ProcessFundWithRawInventory_CreateInventories,
                            ProcessStep.ProcessFundWithRawInventory_ReportModifications,
                            ProcessStep.ProcessFundWithRawInventory_DataModifications
                        )))
        );
        const languageText = computed(() => documentData?.value?.languageText);
        const addDigitalObjectEnabled = computed(
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
                ) &&
                isUserRelatedToActiveProcess.value
        );

        const deleteDigitalObjectEnabled = computed(
            () =>
                activeProcessData.value &&
                ((isProcessType(
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
                    )) ||
                    (isProcessType(activeProcessData.value, ProcessType.ProcessRawFundWithRawInventory) &&
                        isProcessStepType(
                            activeProcessData.value,
                            ProcessStep.ProcessRawFundWithRawInventory_CreateInventories,
                            ProcessStep.ProcessRawFundWithRawInventory_ReportModifications,
                            ProcessStep.ProcessRawFundWithRawInventory_DataModifications
                        )) ||
                    (isProcessType(activeProcessData.value, ProcessType.ProcessFundWithRawInventory) &&
                        isProcessStepType(
                            activeProcessData.value,
                            ProcessStep.ProcessFundWithRawInventory_CreateInventories,
                            ProcessStep.ProcessFundWithRawInventory_ReportModifications,
                            ProcessStep.ProcessFundWithRawInventory_DataModifications
                        ))) &&
                isUserRelatedToActiveProcess.value
        );

        const deleteDigitizedDigitalObjectEnabled = computed(
            () =>
                activeProcessData.value &&
                isProcessType(
                    activeProcessData.value,
                    ProcessType.ImportDigitalObject,
                    ProcessType.PreparationOfADigitalObject,
                    ProcessType.AddDocument
                ) &&
                isProcessStepType(
                    activeProcessData.value,
                    ProcessStep.Document_ReturnedForEditingDigitalData,
                    ProcessStep.Documentt_ReturnedForEditingDigitalData,
                    ProcessStep.Document_PreparationOfADigitalObject,
                    ProcessStep.Documentt_PreparationOfADigitalObject
                ) &&
                isUserRelatedToActiveProcess.value
        );

        const appendDigitizedDigitalObjectEnabled = computed(
            () =>
                activeProcessData.value &&
                isProcessType(
                    activeProcessData.value,
                    ProcessType.ImportDigitalObject,
                    ProcessType.PreparationOfADigitalObject,
                    ProcessType.AddDocument
                ) &&
                isProcessStepType(
                    activeProcessData.value,
                    ProcessStep.Document_ReturnedForEditingDigitalData,
                    ProcessStep.Documentt_ReturnedForEditingDigitalData,
                    ProcessStep.Document_PreparationOfADigitalObject,
                    ProcessStep.Documentt_PreparationOfADigitalObject
                ) &&
                isUserRelatedToActiveProcess.value
        );

        const goEdit = () => {
            if (documentData.value.systemIdentifier && !documentData.value.hasExternalSource) {
                useRedirectWithId(router, 'EditDocument', documentData.value.systemIdentifier);
            } else {
                message.value = new Message({
                    text: t('error.operationError'),
                    display: true,
                });
            }
        };
        const goBack = () => {
            if(documentData.value.archivalEntitySystemIdentifier != undefined || documentData.value.archivalEntityHasExternalSource)
            {
                 useRedirect(
                    router,
                    'DisplayFund',
                    { id: documentData.value.archivalEntitySystemIdentifier != undefined ? documentData.value.archivalEntitySystemIdentifier : defaultGuidString() },
                    {
                        hasExternalSource: String(documentData.value.archivalEntityHasExternalSource),
                        externalIdentifier: documentData.value.archivalEntityHasExternalSource ? documentData.value.archivalEntityExternalIdentifier?.toString() : "",
                    }
                );
            }
            else
            {
                useRedirect(router, "Documents");
            }
        };

        const goRefresh = async (refreshPage?: boolean) => {
            if (refreshPage) {
                router.go(0);
            } else {
                await getActiveProcessData();
            }
        };

        const panel = ref([
            'generalInfo',
            'documentInfo',
            'chronologicalScope',
            'storage',
            'digitalObjects',
            'digitizedDigitalObjects',
        ]);

        const processPanel = ref(['processInfo', 'startProcess']);

        const formattedBytes = computed(() => {
            return formatBytesToMB(documentData.value.bytes || 0);
        });

        const getDocumentData = async () => {
            try {
                isLoading.value = true;
                const result = await documentService.displayDocument(
                    props.id,
                    props.hasExternalSource,
                    props.externalIdentifier
                );

                if (result) {
                    documentData.value = result;
                }

                if (!documentData.value.title) {
                    possibleEmptyFields.title = lowClass;
                }
                if (!documentData.value.description) {
                    possibleEmptyFields.extendedDescription = lowClass;
                }
                if (!documentData.value.features) {
                    possibleEmptyFields.specifics = lowClass;
                }
                if (!documentData.value.notes) {
                    possibleEmptyFields.notes = lowClass;
                }

                if (
                    documentData.value.resultMessage &&
                    documentData.value.resultMessage === 'ISDADataCannotBeDisplayed'
                ) {
                    message.value = new Message({
                        text: t('warnings.ISDADataCannotBeDisplayed'),
                        display: true,
                        type: 'warning',
                    });
                }
                
                if (documentData.value != null && documentData.value.startSheetNumber == null && documentData.value.endSheetNumber == null && documentData.value.sheetCount) {
                    documentData.value.startSheetNumber = 1;
                    documentData.value.endSheetNumber = documentData.value.sheetCount;
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
                    activeProcessData.value = await processService.getCurrentActiveProcess(
                        BusinessObjectType.document,
                        props.id,
                        true,
                        props.externalIdentifier
                    );

                    if (activeProcessData.value?.id) {
                        isUserRelatedToActiveProcess.value = await processService.getIsCurrentUserInProcess(
                            activeProcessData.value.id
                        );
                        if (breadcrumbItems.value.length > 5) {
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
                    archiveId: documentData.value.archiveId,
                    documentSystemIdentifier: documentData.value.systemIdentifier,
                });

                let result = null;

                const hasSystemIdentifier = () => {
                    if (process.documentSystemIdentifier == undefined) {
                        throw new Error('CantStart');
                    }
                };

                switch (processType) {
                    case ProcessType.EditData:
                        //if (authorization.isAdmin(AdminType.Admin)) {
                        if (authorization.hasRole(RoleNames.GroupB1, documentData.value.archiveId!)) {
                            hasSystemIdentifier();
                            if (documentData.value.hasExternalSource) {
                                throw new Error('CantStart');
                            }
                            await editDataProcessService.startProcess(process);
                            goEdit();
                        } else {
                            throw new Error('NoPermissions');
                        }
                        break;
                    case ProcessType.RefineData:
                        if (authorization.hasRole(RoleNames.GroupB, documentData.value.archiveId)) {
                            hasSystemIdentifier();
                            if (documentData.value.hasExternalSource) {
                                result = await refineDataProcessService.hasEntitiesInCEA(process);
                                if (!result.succeeded) {
                                    throw new Error('NoDataInCEA');
                                }
                            }

                            await refineDataProcessService.startProcess(process);
                            goEdit();
                        } else {
                            throw new Error('NoPermissions');
                        }
                        break;
                    case ProcessType.DeductData: {
                        hasSystemIdentifier();
                        if (documentData.value.hasExternalSource) {
                            throw new Error('CantStart');
                        }
                        if (authorization.hasRole(RoleNames.GroupB)) {
                            if (documentData.value.isDraft == false) {
                                await deductionService.start(
                                    props.id!,
                                    props.externalIdentifier!,
                                    processEntityTypes,
                                    documentData.value.archiveId!
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
                    case ProcessType.ImportDigitalObject:
                        hasSystemIdentifier();
                        if (authorization.hasRole(RoleNames.GroupJ)) {
                            digObJProcesesPanel!.value!.starNewtProces(ProcessType.ImportDigitalObject);
                        } else {
                            throw new Error('NoPermissions');
                        }
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
                        text: t('error.noDataInCEA', { entity: t('documents.document') }),
                        display: true,
                    });
                } else if (error.message == 'NoPermissions') {
                    message.value = new Message({
                        text: t('error.noPermissions'),
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

        const breadcrumbItems = computed(() => [
            {
                title: documentData.value.archiveName,
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('funds.fund'),
                disabled: false,
                to: {
                    name: 'DisplayFund',
                    params: { id: documentData.value.fundSystemIdentifier },
                    query: {
                        hasExternalSource: documentData.value.fundHasExternalSource,
                        externalIdentifier: documentData.value.fundSystemIdentifier,
                    },
                },
            },
            {
                title: t('inventories.inventory'),
                disabled: false,
                to: {
                    name: 'DisplayInventory',
                    params: { id: documentData.value.inventorySystemIdentifier },
                    query: {
                        hasExternalSource: documentData.value.inventoryHasExternalSource,
                        externalIdentifier: documentData.value.inventoryExternalIdentifier,
                    },
                },
            },
            {
                title: t('archiveEntities.archiveEntity'),
                disabled: false,
                to: {
                    name: 'DisplayArchiveEntity',
                    params: { id: documentData.value.archivalEntitySystemIdentifier },
                    query: {
                        hasExternalSource: documentData.value.archivalEntityHasExternalSource,
                        externalIdentifier: documentData.value.archivalEntityExternalIdentifier,
                    },
                },
            },
            {
                title: t('documents.document'),
                disabled: true,
            },
        ]);

        onMounted(async () => {
            window.scrollTo(0, 0);
            await getDocumentData();
            await getActiveProcessData();
            renderComponent.value = true;
        });

        return {
            t,
            languageText,
            digObJProcesesPanel,
            redirectToEntityInIsda,
            btnStartProcessClickHandler,
            getActiveProcessData,
            goEdit,
            goBack,
            goRefresh,
            undoDeductionChanges,
            formatDate,
            panel,
            RoleNames,
            processPanel,
            editEnabled,
            addDigitalObjectEnabled,
            breadcrumbItems,
            activeProcessData,
            processEntityTypes,
            dialog,
            enableStartProcessPanel,
            showStartProcessPanel,
            showProcessInfoPanel,
            documentData,
            message,
            ProcessType,

            ProcessStep,
            isUserRelatedToActiveProcess,
            renderComponent,
            possibleEmptyFields,
            formattedBytes,
            deleteDigitalObjectEnabled,
            deleteDigitizedDigitalObjectEnabled,
            appendDigitizedDigitalObjectEnabled,
            formattedDuration,
            inventoryArray,
            isLoading,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs-doc.scss';
@import '@/assets/styles/index-1.scss';

:deep(.input-group) {
    background-color: white !important;
}
// :deep(.v-container),
// :deep(.v-expansion-panels),
// :deep(.v-expansion-panel-text) {
//     margin: 0px !important;
// }

.low,
:deep(.low div),
:deep(.low textarea) {
    height: 50px;
    margin-bottom: 25px;
}

:deep(.assign-modal button),
:deep(.confirm-dialog button) {
    min-width: 150px !important;
}

// :deep(button) {
//     min-width: fit-content !important;
// }
a {
    cursor: pointer;
}
</style>
