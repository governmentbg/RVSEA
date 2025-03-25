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
                            v-if="activeProcessData.processTypeId == ProcessType.EditData"
                            :process="activeProcessData"
                            @complete="goRefresh(true)"
                            @undochanges="goRefresh(true)"
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
                                activeProcessData.archivalEntitySystemIdentifier
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
                    :entityHasExternalSource="archivalEntityData.hasExternalSource"
                    @startProcess="btnStartProcessClickHandler"
                    :readOnly="!enableStartProcessPanel"
                />
                <timeline-panel
                    v-if="showProcessInfoPanel && isUserRelatedToActiveProcess"
                    :processId="activeProcessData.id"
                    :showExpanded="false"
                />
            </v-expansion-panels>
            <DeductionProcessPanel
                v-if="
                    activeProcessData &&
                    activeProcessData.processTypeId == ProcessType.DeductData &&
                    isUserRelatedToActiveProcess &&
                    activeProcessData.archivalEntitySystemIdentifier
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
                :process="activeProcessData"
                @approval="goRefresh"
                @affirmation="goRefresh"
            />
        </v-container>
    </v-card>
    <v-row class="mt-1 mb-1" v-if="!editEnabled && archivalEntityData.hasExternalSource">
        <v-col class="col-12 col-md-9 col-lg-9 ma-auto">
            <v-alert class="justify-content-center" type="info" variant="tonal" style="font-size: 1.1rem">
                {{ t('archiveEntities.externalSourceArchivalEntity') }}
            </v-alert>
        </v-col>
    </v-row>
    <v-card ref="archivalEntityCard" class="col-12 col-md-9 col-lg-9 ma-auto">
        <v-card-title class="v-card-title-uppercase">{{ t('archiveEntities.display') }}</v-card-title>
        <v-container>
            <v-expansion-panels v-model="panel" multiple>
                <v-expansion-panel value="generalInfo">
                    <v-expansion-panel-title>{{ t('archiveEntities.panels.generalInfo') }}</v-expansion-panel-title>
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
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldNumber"
                                    :label="t('archiveEntities.columns.number')"
                                    v-model="archivalEntityData.number"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldSystemIdentifier"
                                    :label="t('archiveEntities.columns.systemIdentifier')"
                                    v-model="archivalEntityData.systemIdentifier"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldCreatedByDisplayName"
                                    :label="t('archiveEntities.columns.author')"
                                    v-model="archivalEntityData.createdByDisplayName"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldCreatedOn"
                                    :label="t('archiveEntities.columns.creationDate')"
                                    :modelValue="formatDate(archivalEntityData.createdOn)"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row v-if="archivalEntityData.updatedOn">
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldUpdatedByDisplayName"
                                    :label="t('archiveEntities.columns.updatedBy')"
                                    v-model="archivalEntityData.updatedByDisplayName"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-lg-6">
                                <text-field
                                    name="fldUpdatedOn"
                                    :label="t('archiveEntities.columns.updatedOn')"
                                    :modelValue="formatDate(archivalEntityData.updatedOn)"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="archivalEntityInfo">
                    <v-expansion-panel-title>{{
                        t('archiveEntities.panels.archivalEntityInfo')
                    }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12 col-md-4 col-lg-4">
                                <text-field
                                    name="fldNumber"
                                    :label="t('archiveEntities.columns.number')"
                                    v-model="archivalEntityData.number"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-4 col-lg-4">
                                <text-field
                                    name="fldClassificationSchemeIndex"
                                    :label="t('archiveEntities.columns.classificationSchemeIndex')"
                                    v-model="archivalEntityData.classificationSchemeIndex"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-4 col-lg-4">
                                <text-field
                                    name="fldDescriptionLevel"
                                    :label="t('archiveEntities.columns.descriptionLevel')"
                                    v-model="archivalEntityData.descriptionLevelText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldAvailabilityStatus"
                                    :label="t('archiveEntities.columns.availabilityStatus')"
                                    v-model="archivalEntityData.availabilityStatusText"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldStatus"
                                    :label="t('archiveEntities.columns.status')"
                                    v-model="archivalEntityData.statusText"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row
                            v-if="
                                archivalEntityData.inventoryNumberArray === inventoryArray.KE ||
                                archivalEntityData.inventoryNumberArray === inventoryArray.NE ||
                                archivalEntityData.inventoryNumberArray === inventoryArray.PE ||
                                archivalEntityData.inventoryNumberArray === inventoryArray.TE
                            "
                        >
                            <v-col class="col-12">
                                <text-field
                                    name="fldCypher"
                                    :label="t('archiveEntities.columns.cypher')"
                                    v-model="archivalEntityData.cypher"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="{ low: !archivalEntityData.title }">
                                <text-area-field
                                    name="fldTitle"
                                    :label="t('archiveEntities.columns.title')"
                                    v-model="archivalEntityData.title"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                                <h6>{{ t('archiveEntities.panels.datePlaceOfCreation') }}</h6>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <Switch
                                    v-model="archivalEntityData.hasNoChronologicalScope"
                                    :label="t('archiveEntities.columns.chronologicalScope')"
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
                            <v-col class="col-12 col-md-4">
                                <text-field
                                    name="fldStartDateDay"
                                    :label="t('common.day')"
                                    v-model="archivalEntityData.startDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-4">
                                <text-field
                                    name="fldStartDateMonth"
                                    :label="t('common.month')"
                                    v-model="archivalEntityData.startDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-4">
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
                            <v-col class="col-12 col-md-4">
                                <text-field
                                    name="fldEndDateDay"
                                    :label="t('common.day')"
                                    v-model="archivalEntityData.endDateDay"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-4">
                                <text-field
                                    name="fldEndDateMonth"
                                    :label="t('common.month')"
                                    v-model="archivalEntityData.endDateMonth"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-4">
                                <text-field
                                    name="fldEndDateYear"
                                    :label="t('common.year')"
                                    v-model="archivalEntityData.endDateYear"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldApproximateChronologicalScope"
                                    :label="t('archiveEntities.columns.approximateChronologicalScope')"
                                    v-model="archivalEntityData.approximateChronologicalScope"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12" :class="possibleEmptyFields.location">
                                <text-area-field
                                    name="fldLocation"
                                    :label="t('archiveEntities.columns.placeOfCreation')"
                                    v-model="archivalEntityData.location"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                                <h6>{{ t('archiveEntities.panels.storage') }}</h6>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldBytes"
                                    :label="t('archiveEntities.columns.bytes')"
                                    v-model="formattedBytes"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldDocumentCount"
                                    :label="t('archiveEntities.columns.documentCount')"
                                    v-model="archivalEntityData.documentCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row
                            v-if="
                                archivalEntityData.inventoryNumberArray === inventoryArray.KE ||
                                archivalEntityData.inventoryNumberArray === inventoryArray.NE ||
                                archivalEntityData.inventoryNumberArray === inventoryArray.PE ||
                                archivalEntityData.inventoryNumberArray === inventoryArray.TE
                            "
                        >
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldTextDocsCount"
                                    :label="t('archiveEntities.columns.textDocsCount')"
                                    v-model="archivalEntityData.textDocsCount"
                                    :readOnly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldGraphicalDocsCount"
                                    :label="t('archiveEntities.columns.graphicalDocsCount')"
                                    v-model="archivalEntityData.graphicalDocsCount"
                                    :readOnly="true"
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
                                    :readonly="true"
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
                                    name="fldAuthor"
                                    :label="t('archiveEntities.columns.creator')"
                                    v-model="archivalEntityData.author"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldDescriptionAuthor"
                                    :label="t('archiveEntities.columns.descriptionAuthor')"
                                    v-model="archivalEntityData.descriptionAuthor"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldSizeCm"
                                    :label="t('archiveEntities.columns.sizeCm')"
                                    v-model="archivalEntityData.sizeCm"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6">
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
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldLanguage"
                                    :label="t('archiveEntities.columns.language')"
                                    v-model="languageText"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldOtherLanguage"
                                    :label="t('archiveEntities.columns.otherLanguage')"
                                    v-model="archivalEntityData.otherLanguage"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12" :class="{ low: !archivalEntityData.documentsAccessDescription }">
                                <text-area-field
                                    name="fldAccessConditions"
                                    :label="t('archiveEntities.columns.accessConditions')"
                                    v-model="archivalEntityData.documentsAccessDescription"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="possibleEmptyFields.specifics">
                                <text-area-field
                                    name="fldSpecifics"
                                    :label="t('archiveEntities.columns.specifics')"
                                    v-model="archivalEntityData.features"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <text-field
                                    name="fldPhysicalCondition"
                                    :label="t('archiveEntities.columns.physicalCondition')"
                                    v-model="archivalEntityData.condition"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                                <h6>{{ t('archiveEntities.panels.copiesEligibility') }}</h6>
                            </v-col>
                        </v-row>
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
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldNegativeFramesCount"
                                    :label="t('archiveEntities.columns.negativeFrames')"
                                    v-model="archivalEntityData.negativeFrameCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldPositiveFramesCount"
                                    :label="t('archiveEntities.columns.positiveFrames')"
                                    v-model="archivalEntityData.positiveFrameCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col>
                                <text-field
                                    name="fldOtherCopyCount"
                                    :label="t('archiveEntities.columns.other')"
                                    v-model="archivalEntityData.otherCopyCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col :class="{ low: !archivalEntityData.notes }">
                                <text-area-field
                                    name="fldNotes"
                                    :label="t('archiveEntities.columns.notes')"
                                    v-model="archivalEntityData.notes"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row
                            v-if="
                                archivalEntityData.inventoryNumberArray === inventoryArray.KE ||
                                archivalEntityData.inventoryNumberArray === inventoryArray.TE
                            "
                        >
                            <v-col class="col-12">
                                <text-field
                                    name="fldStage"
                                    :label="t('archiveEntities.columns.stage')"
                                    v-model="archivalEntityData.stage"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row v-if="archivalEntityData.inventoryNumberArray === inventoryArray.PE">
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldPhase"
                                    :label="t('archiveEntities.columns.phase')"
                                    v-model="archivalEntityData.phase"
                                    :readOnly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldPart"
                                    :label="t('archiveEntities.columns.part')"
                                    v-model="archivalEntityData.part"
                                    :readOnly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12">
                                <v-divider></v-divider>
                                <h6>{{ t('archiveEntities.panels.eligibilityChange') }}</h6>
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldEnrolledLinearMeters"
                                    :label="t('archiveEntities.columns.enrolledLinearMeters')"
                                    v-model="archivalEntityData.enrolledLinearMeters"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldDeductedLinearMeters"
                                    :label="t('archiveEntities.columns.deductedLinearMeters')"
                                    v-model="archivalEntityData.deductedLinearMeters"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldEnrolledDocumentCount"
                                    :label="t('archiveEntities.columns.enrolledDocumentsCount')"
                                    v-model="archivalEntityData.enrolledDocumentCount"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldDeductedDocumentsCount"
                                    :label="t('archiveEntities.columns.deductedDocumentsCount')"
                                    v-model="archivalEntityData.deductedDocumentCount"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldDeductedMB"
                                    :label="t('archiveEntities.columns.enrolledMB')"
                                    v-model="formattedEnrolledBytes"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldDeductedMB"
                                    :label="t('archiveEntities.columns.deductedMB')"
                                    v-model="formattedDeductedBytes"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                        <v-row>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldDeductedMB"
                                    :label="t('archiveEntities.columns.enrolledDuration')"
                                    v-model="formatedEnrolledDuration"
                                    :readonly="true"
                                />
                            </v-col>
                            <v-col class="col-12 col-md-6">
                                <text-field
                                    name="fldDeductedMB"
                                    :label="t('archiveEntities.columns.deductedDuration')"
                                    v-model="formatedDeductedDuration"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <!-- todo -->
                <!-- <v-expansion-panel value="general">
              <v-expansion-panel-title>{{  t('archiveEntities.panels.participationInAnnotatedLists') }}</v-expansion-panel-title>
              <v-expansion-panel-text>
              </v-expansion-panel-text>
          </v-expansion-panel> -->
                <!-- <v-expansion-panel value="externalSource">
                    <v-expansion-panel-title>{{ t('archiveEntities.panels.externalSource') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row>
                            <v-col class="col-12">
                                <Switch
                                    :label="t('archiveEntities.columns.hasExternalSource')"
                                    v-model="archivalEntityData.hasExternalSource"
                                    :large="false"
                                    :showLabel="true"
                                    :disabled="true"
                                />
                            </v-col>
                            <v-col class="col-12">
                                <text-field
                                    name="fldExternalIdentifier"
                                    :label="t('archiveEntities.columns.externalIdentifier')"
                                    v-model="archivalEntityData.externalIdentifier"
                                    :readonly="true"
                                />
                            </v-col>
                        </v-row>
                    </v-expansion-panel-text>
                </v-expansion-panel> -->
                <v-expansion-panel value="history">
                    <v-expansion-panel-title>{{ t('archiveEntities.panels.history') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <v-row align="center">
                            <v-col cols="6">
                                <label>{{ t('globalSearch.dateFrom') }}</label>
                                <DatePicker
                                    v-model:date="searchModel.startDate"
                                    :label="t('reports.chronologicalExtentEndDate')"
                                />
                            </v-col>
                            <v-col cols="6">
                                <label>{{ t('globalSearch.dateTo') }}</label>
                                <DatePicker
                                    v-model:date="searchModel.endDate"
                                    :label="t('reports.chronologicalExtentEndDate')"
                                />
                            </v-col>
                        </v-row>
                        <v-row align="center">
                            <v-col class="col-12 col-lg-6 d-flex justify-content-start">
                                <v-btn @click="searchDigitalObjectReviews" variant="flat"
                                    >{{ t('common.search') }}
                                    <v-tooltip activator="parent" location="bottom">
                                        {{ t('common.searchTooltip') }}
                                    </v-tooltip>
                                </v-btn>
                                <v-divider vertical></v-divider>
                                <v-btn class="cancel" @click="clearAllDigitalObjectReviewsCriteria" variant="flat"
                                    >{{ t('common.clear') }}
                                    <v-tooltip activator="parent" location="bottom">
                                        {{ t('common.clearTooltip') }}
                                    </v-tooltip>
                                </v-btn>
                            </v-col>
                        </v-row>
                        <Grid
                            ref="grid"
                            :items="digitalObjectReviewData"
                            :columns="columns"
                            mode="'remote'"
                            :paging="true"
                            :pageSize="pageSize"
                            :exportMode="'all'"
                            :exportParams="exportParams"
                            :exportOptions="exportOptions"
                            :showSearch="false"
                            :showExport="true"
                            :noDataMessage="t('common.noDataMessage')"
                            :businessObjectType="'report'"
                        />
                        <!-- <document-digital-objects-review-statistic v-model:seacrhModel="searchModel" /> -->
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel value="documents" v-if="renderComponent">
                    <v-expansion-panel-title>{{ t('archiveEntities.panels.documents') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <ArchivalEntityDocuments
                            v-if="!showReconstructionDocuments"
                            :addEnabled="addDocumentEnabled"
                            :archivalEntity="archivalEntityData"
                            :searchEnabled="true"
                            :deleteEnabled="deleteDocumentEnabled"
                        />
                        <ReconstructionDocuments
                            v-if="showReconstructionDocuments"
                            :archivalEntity="archivalEntityData"
                            :process="activeProcessData"
                            @markForDeduction="goRefresh(true)"
                            @enrollment="goRefresh(true)"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
                <v-expansion-panel class="v-expansion-panel" value="publicUsersReviews">
                    <v-expansion-panel-title>{{ t('common.reviewsHistory') }}</v-expansion-panel-title>
                    <v-expansion-panel-text>
                        <public-user-reviews
                            :systemIdentifier="archivalEntityData.systemIdentifier"
                            :type="$t('archiveEntities.archiveEntity')"
                        />
                    </v-expansion-panel-text>
                </v-expansion-panel>
            </v-expansion-panels>
            <v-row class="mt-3" v-if="editEnabled">
                <v-col class="d-flex gap-2 justify-content-center">
                    <v-btn @click="goEdit"
                        >{{ t('common.edit') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('archiveEntities.buttons.editTooltip') }}
                        </v-tooltip>
                    </v-btn>
                    <back-btn @click="goBack"
                        >{{ t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('archiveEntities.buttons.backTooltip') }}
                        </v-tooltip>
                    </back-btn>
                </v-col>
            </v-row>
            <v-row class="mt-1 mb-1" v-if="!editEnabled && archivalEntityData.hasExternalSource">
                <v-col class="col-12 ma-auto">
                    <v-alert class="justify-content-center" type="info" variant="tonal" style="font-size: 1.1rem">
                        {{ t('archiveEntities.externalSourceArchivalEntity') }}
                    </v-alert>
                </v-col>
            </v-row>
            <v-row class="mt-3" v-if="!editEnabled">
                <v-col class="d-flex gap-2 justify-content-center">
                    <back-btn @click="goBack"
                        >{{ t('common.back') }}
                        <v-tooltip activator="parent" location="bottom">
                            {{ t('archiveEntities.buttons.backTooltip') }}
                        </v-tooltip>
                    </back-btn>
                </v-col>
            </v-row>
        </v-container>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, inject, Ref, computed, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { LocationQueryRaw, useRouter } from 'vue-router';
import { validate as isValidGuid } from 'uuid';
import { useRedirect, useRedirectWithId } from '@/helpers/router.helper';
import { formatDate, formatDateTime, formatBytesToMB, trimText, formatDuration, defaultGuidString } from '@/helpers/format.helper';
import { isProcessStepType, isProcessType } from '@/helpers/validate.helper';
import { useStore as useAppStore } from '@/store/app';
import DeductionDataProcessActions from '@/components/deductionProcess/actions.vue';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { ResponseResult } from '@/models/responseResult';
import { InventoryArray } from '@/enums/inventory';
import { IArchivalEntity } from '@/interfaces/archivalEntity';
import { ArchivalEntity } from '@/models/archivalEntity';
import { PageSize, GridResponseModel, BusinessObjectType, GridRequestModel } from '@/models/grid';
import { IProcess } from '@/interfaces/process';
import { ProcessStep, ProcessType } from '@/enums/process';
import { ProcessModel } from '@/models/process';
import { DeductionProcessCreateModel } from '@/models/deductionProcess';
import { AeSearchModel } from '@/models/search';
import { DigitalObjectReviewDisplayModel, DigitalObjectReviewFilterModel } from '@/models/digitalObject';
import { ReviewType } from '@/enums/digitalObject';
import { Status, AvailabilityStatus } from '@/enums/status';
import { RoleNames } from '@/enums/roles';
import authorization from '@/helpers/authorization.helper';
import archiveEntityService from '@/services/archivalEntity.service';
import processService from '@/services/process.service';
import deductionService from '@/services/deductionProcess.service';
import editDataProcessService from '@/services/editDataProcess.service';
import refineDataProcessService from '@/services/refineDataProcess.service';
import digitalObjectService from '@/services/digitalObject.service';

import TextField from '@/components/field/text.field.vue';
import TextAreaField from '@/components/field/textarea.field.vue';
import Switch from '@/components/checkbox/switch.vue';
import ArchivalEntityDocuments from '@/components/document/archivalEntityDocuments.vue';
import StartProcessPanel from '@/components/process/startPanel.vue';
import ProcessInformationPanel from '@/components/process/processInfoPanel.vue';
import TimelinePanel from '@/components/process/timelinePanel.vue';
import EditDataProcessActions from '@/components/editDataProcess/actions.vue';
import RefineDataProcessActions from '@/components/refineDataProcess/actions.vue';
import RefineDataProcessSteps from '@/components/refineDataProcess/steps.vue';
import ReconstructFundDataProcessActions from '@/components/reconstructFundDataProcess/actions.vue';
import ReconstructFundDataProcessSteps from '@/components/reconstructFundDataProcess/steps.vue';
import ReconstructionDocuments from '@/components/reconstructFundDataProcess/documents.vue';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import DatePicker from '@/components/datetime/datepPicker.vue';
import Grid from '@/components/grid/grid.vue';
import DeductionProcessPanel from '@/components/deductionProcess/display.vue';
import PublicUserReviews from '@/components/reviews/publicUserReviews.vue';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'DisplayArchiveEntity',
    components: {
        Loader,
        TextField,
        Switch,
        TextAreaField,
        ArchivalEntityDocuments,
        DeductionProcessPanel,
        StartProcessPanel,
        ProcessInformationPanel,
        TimelinePanel,
        EditDataProcessActions,
        RefineDataProcessActions,
        RefineDataProcessSteps,
        ReconstructFundDataProcessActions,
        ReconstructFundDataProcessSteps,
        ReconstructionDocuments,
        DatePicker,
        Grid,
        Breadcrumbs,
        PublicUserReviews,
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
    setup(props, { emit }) {
        const { t } = useI18n();

        const message = inject('notificationMessage') as Ref<IMessage>;

        const panel = ref(['generalInfo', 'archivalEntityInfo', 'documents']);

        const processPanel = ref(['processInfo', 'startProcess']);
        const appStore = useAppStore();
        const showStartProcessPanel = ref(false);
        const showProcessInfoPanel = ref(false);
        const renderComponent = ref(false);
        const undoDeductionChanges = ref(false);
        const inventoryArray = InventoryArray;

        const possibleEmptyFields = {
            title: '',
            location: '',
            extendedDescription: '',
            specifics: '',
            documentsAccessDescription: '',
        };

        const lowClass = 'low';
        const isLoading = ref(false);

        const isUserRelatedToActiveProcess = ref(false);
        const searchModel = ref<AeSearchModel>(new AeSearchModel());
        const pageSize = PageSize.ten;
        const grid = ref();
        const formatedEnrolledDuration = computed(() =>
            formatDuration(archivalEntityData?.value?.enrolledDuration as number)
        );
        const formatedDeductedDuration = computed(() =>
            formatDuration(archivalEntityData?.value?.deductedDuration as number)
        );
        const editEnabled = computed(
            () =>
                (!archivalEntityData.value.hasExternalSource ||
                    (archivalEntityData.value.statusCode !== Status.Deducted &&
                        archivalEntityData.value.statusCode !== Status.Deleted)) &&
                activeProcessData.value &&
                (activeProcessData.value?.processTypeId === ProcessType.EditData ||
                    activeProcessData.value?.processTypeId === ProcessType.RefineData ||
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
                    (activeProcessData.value?.processTypeId === ProcessType.ProcessRawFundWithRawInventory &&
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
                                ProcessStep.ProcessFundWithRawInventory_DataModifications)) ||
                    (activeProcessData.value.processTypeId === ProcessType.ReconstructFundData &&
                        activeProcessData.value.activeProcessStepTypeId ===
                            ProcessStep.ReconstructFundData_Registration))
        );

        const addDocumentEnabled = computed(
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

        const deleteDocumentEnabled = computed(
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

        const showReconstructionDocuments = computed(
            () =>
                activeProcessData.value &&
                activeProcessData.value.processTypeId === ProcessType.ReconstructFundData &&
                (activeProcessData.value.activeProcessStepTypeId === ProcessStep.ReconstructFundData_EditData ||
                    activeProcessData.value.activeProcessStepTypeId ===
                        ProcessStep.ReconstructFundData_DataModifications ||
                    activeProcessData.value.activeProcessStepTypeId ===
                        ProcessStep.ReconstructFundData_ReportModifications) &&
                archivalEntityData.value &&
                archivalEntityData.value.availabilityStatusCode !== AvailabilityStatus.DisposalDeduction &&
                archivalEntityData.value.availabilityStatusCode !== AvailabilityStatus.RelocationDeduction
        );

        const enableStartProcessPanel = computed(
            () =>
                archivalEntityData.value &&
                archivalEntityData.value.statusCode !== Status.Deducted &&
                archivalEntityData.value.statusCode !== Status.Deleted
        );

        const router = useRouter();

        const goAddDocument = (processType?: number) => {
            const routeQuery: LocationQueryRaw = {
                archivalEntitySystemIdentifier: archivalEntityData.value.systemIdentifier,
                archivalEntityHasExternalSource: String(archivalEntityData.value.hasExternalSource),
                archivalEntityExternalIdentifier: archivalEntityData.value.externalIdentifier,
            };
            if (processType === ProcessType.AddDocument || processType === ProcessType.PreparationOfADigitalObject) {
                routeQuery.processType = processType;
            }

            useRedirect(router, 'CreateDocument', undefined, routeQuery);
        };

        const goEdit = () => {
            if (archivalEntityData.value.systemIdentifier && !archivalEntityData.value.hasExternalSource) {
                useRedirectWithId(router, 'EditArchiveEntity', archivalEntityData.value.systemIdentifier);
            } else {
                message.value = new Message({
                    text: t('error.operationError'),
                    display: true,
                });
            }
        };
        const languageText = computed(() => archivalEntityData?.value?.languageText);
        const goBack = () => {
            if(archivalEntityData.value.inventorySystemIdentifier != undefined || archivalEntityData.value.inventoryHasExternalSource)
            {
                useRedirect(
                    router,
                    'DisplayInventory',
                    { id: archivalEntityData.value.inventorySystemIdentifier != undefined ? archivalEntityData.value.inventorySystemIdentifier : defaultGuidString() },
                    {
                        hasExternalSource: String(archivalEntityData.value.inventoryHasExternalSource),
                        externalIdentifier: archivalEntityData.value.inventoryHasExternalSource ? archivalEntityData.value.inventoryExternalIdentifier?.toString() : "",
                    }
                );
            }
            else
            {
                useRedirect(router, "ArchiveEntities");
            }
        };

        const goRefresh = async (refreshPage?: boolean) => {
            if (refreshPage) {
                router.go(0);
            } else {
                await getActiveProcessData();
            }
        };

        const processEntityTypes = [BusinessObjectType.archivalEntity];

        const archivalEntityData = ref<IArchivalEntity>(new ArchivalEntity());
        const activeProcessData = ref<IProcess>();
        const formattedBytes = computed(() => {
            return formatBytesToMB(archivalEntityData.value.bytes || 0);
        });

        const formattedEnrolledBytes = computed(() => {
            return formatBytesToMB(archivalEntityData.value.enrolledBytes || 0);
        });
        const formattedDeductedBytes = computed(() => {
            return formatBytesToMB(archivalEntityData.value.deductedBytes || 0);
        });

        const getArchivalEntityData = async () => {
            try {
                isLoading.value = true;
                const result = await archiveEntityService.displayArchivalEntity(
                    props.id,
                    props.hasExternalSource,
                    props.externalIdentifier
                );

                if (result) {
                    archivalEntityData.value = result;
                }

                searchModel.value.archivalEntitySystemIdentifier = props.id;
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

                if (archivalEntityData.value.isExternalSourceSnapshot) {
                    message.value = new Message({
                        text: t('warnings.ISDADataCannotBeDisplayed'),
                        display: true,
                        type: 'warning',
                    });
                }

                // if (
                //     archivalEntityData.value.resultMessage &&
                //     archivalEntityData.value.resultMessage === 'ISDADataCannotBeDisplayed'
                // ) {
                //     message.value = new Message({
                //         text: t('warnings.ISDADataCannotBeDisplayed'),
                //         display: true,
                //         type: 'warning',
                //     });
                // }
            } catch (error: unknown) {
                console.log(error);
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
                        BusinessObjectType.archivalEntity,
                        props.id,
                        true,
                        props.externalIdentifier
                    );

                    if (activeProcessData.value?.id) {
                        isUserRelatedToActiveProcess.value = await processService.getIsCurrentUserInProcess(
                            activeProcessData.value.id
                        );

                        if (breadcrumbItems.value.length > 4) {
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
                    archiveId: archivalEntityData.value.archiveId,
                    archivalEntitySystemIdentifier: archivalEntityData.value.systemIdentifier,
                });

                let result = null;

                const hasSystemIdentifier = () => {
                    if (process.archivalEntitySystemIdentifier == undefined) {
                        throw new Error('CantStart');
                    }
                };

                switch (processType) {
                    case ProcessType.EditData:
                        //if (authorization.isAdmin(AdminType.Admin)) {
                        if (authorization.hasRole(RoleNames.GroupB1, archivalEntityData.value.archiveId!)) {
                            hasSystemIdentifier();
                            if (archivalEntityData.value.hasExternalSource) {
                                throw new Error('CantStart');
                            }
                            await editDataProcessService.startProcess(process);
                            goEdit();
                        } else {
                            throw new Error('NoPermissions');
                        }
                        break;
                    case ProcessType.RefineData:
                        if (authorization.hasRole(RoleNames.GroupB, archivalEntityData.value.archiveId!)) {
                            hasSystemIdentifier();
                            if (archivalEntityData.value.hasExternalSource) {
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
                        if (archivalEntityData.value.hasExternalSource) {
                            throw new Error('CantStart');
                        }
                        if (authorization.hasRole(RoleNames.GroupB)) {
                            const submitData = new DeductionProcessCreateModel();
                            submitData.archivalEntitySystemIdentifier = props.id;
                            submitData.archivalEntityExternalIdentifier = props.externalIdentifier;
                            submitData.procedureType = ProcessType.DeductData;
                            submitData.archiveId = archivalEntityData.value.archiveId;
                            if (archivalEntityData.value.isDraft == false) {
                                await deductionService.start(
                                    props.id!,
                                    props.externalIdentifier!,
                                    processEntityTypes[0],
                                    archivalEntityData.value.archiveId!
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
                    case ProcessType.AddDocument:
                    case ProcessType.PreparationOfADigitalObject:
                        hasSystemIdentifier();
                        if (authorization.hasRole(RoleNames.GroupB, archivalEntityData.value.archiveId!)) {
                            goAddDocument(processType);
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
                        text: t('error.noDataInCEA', { entity: t('archiveEntities.archiveEntity') }),
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

        const digitalObjectReviewData = ref([] as DigitalObjectReviewDisplayModel[]);
        const totalGridRowsCount = ref(0);
        const exportParams = ref();
        const exportOptions = ref();

        const getDigitalObjectReviewData = async (model: AeSearchModel) => {
            model.startDate?.setUTCHours(0);
            model.endDate?.setUTCHours(24);

            const filters = {
                ArchivalEntitySystemIdentifier: model.archivalEntitySystemIdentifier,
                StartDate: model.startDate,
                EndDate: model.endDate,
            };

            const gridInputModel = new GridRequestModel<DigitalObjectReviewFilterModel>({
                Page: model.Page,
                ItemsPerPage: model.ItemsPerPage,
                Filters: filters,
            });
            exportOptions.value = gridInputModel.Filters;
            exportParams.value = ReviewType.DigitalObjectReviewDisplayModel;

            digitalObjectService
                .getDigitalObjectReviewsUrl(gridInputModel)
                .then((result: GridResponseModel<DigitalObjectReviewDisplayModel>) => {
                    digitalObjectReviewData.value = [];
                    result.items.forEach((item) => {
                        digitalObjectReviewData.value.push(item);
                    });
                    totalGridRowsCount.value = result.totalCount;

                    //showReport.value = true
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

        const searchDigitalObjectReviews = async () => {
            searchModel.value.startDate?.setUTCHours(0, 0, 0);
            searchModel.value.endDate?.setUTCHours(23, 59, 59);
            await getDigitalObjectReviewData(searchModel.value);
            const exportButton = document.querySelector('#btnExportGrid');
            exportButton?.addEventListener('click', () => {
                const items = document.querySelectorAll('.dropdown-item');
                items.forEach((item) => {
                    item?.addEventListener('click', (e) => {
                        e.preventDefault();
                    });
                });
            });
        };

        const clearAllDigitalObjectReviewsCriteria = async () => {
            searchModel.value.startDate = null;
            searchModel.value.endDate = null;
            digitalObjectReviewData.value = [];
        };

        const columns = [
            {
                title: t('digitalObjects.columns.date'),
                prop: 'date',
                type: 'Date',
                sortable: true,
                filterable: true,
                renderFunction: formatDateTime,
            },
            {
                title: t('digitalObjects.columns.name'),
                prop: 'digitalObjectName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('digitalObjects.columns.documentNumber'),
                prop: 'documentNumber',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('users.user'),
                prop: 'userDisplayName',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('users.columns.userSystemIdentifier'),
                prop: 'userSystemIdentifier',
                type: 'string',
                sortable: true,
                filterable: true,
            },
            {
                title: t('users.columns.profileType'),
                prop: 'userType',
                type: 'string',
                sortable: true,
                filterable: true,
            },
        ];

        const redirectToEntityInIsda = () =>
            window.open(
                `${appStore.state.externalSourceDisplayEntityBaseUrl}ArchiveEntity&agid=${archivalEntityData.value.archiveCode}&flgid=${archivalEntityData.value.fundExternalIdentifier}&ilgid=${archivalEntityData.value.inventoryExternalIdentifier}&aelgid=${archivalEntityData.value.externalIdentifier}`,
                '_blank'
            );

        watch(
            () => props.id,
            async (newVal, oldVal) => {
                if (newVal && newVal !== oldVal && isValidGuid(newVal)) {
                    await getArchivalEntityData();
                    await getActiveProcessData();
                }
            }
        );

        onMounted(async () => {
            window.scrollTo(0, 0);
            await getArchivalEntityData();
            await getActiveProcessData();
            renderComponent.value = true;
        });

        return {
            t,
            formatedEnrolledDuration,
            formattedEnrolledBytes,
            languageText,
            formatedDeductedDuration,
            panel,
            undoDeductionChanges,
            processPanel,
            enableStartProcessPanel,
            showStartProcessPanel,
            showProcessInfoPanel,
            editEnabled,
            addDocumentEnabled,
            archivalEntityData,
            activeProcessData,
            processEntityTypes,

            formatDate,
            redirectToEntityInIsda,
            goEdit,
            goBack,
            goRefresh,
            goAddDocument,
            message,
            breadcrumbItems,
            trimText,
            btnStartProcessClickHandler,
            ProcessType,
            ProcessStep,
            showReconstructionDocuments,
            isUserRelatedToActiveProcess,
            searchModel,
            searchDigitalObjectReviews,
            getDigitalObjectReviewData,
            clearAllDigitalObjectReviewsCriteria,
            digitalObjectReviewData,
            grid,
            pageSize,
            columns,
            exportOptions,
            exportParams,
            renderComponent,
            possibleEmptyFields,
            formattedBytes,
            formattedDeductedBytes,
            deleteDocumentEnabled,
            inventoryArray,
            isLoading,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs-ae.scss';
@import '@/assets/styles/index-1.scss';

:deep(.input-group) {
    background-color: white !important;
}
//:deep(.v-container),
:deep(.v-expansion-panels),
:deep(.v-expansion-panel-text) {
    margin: 0px !important;
}

:deep(.text-undefined) {
    background-color: white !important;
}

:deep(.float-right button) {
    margin: 0px;
}

.v-expansion-panel--active:has(table) {
    margin-top: 20px !important;
}

.low,
:deep(.low div),
:deep(.low textarea) {
    height: 50px;
    margin-bottom: 25px;
}

:deep(.popper-btn) {
    margin-top: 0px !important;
}

:deep(.fa-filter) {
    margin-bottom: 100px !important;
}
a {
    cursor: pointer;
}
</style>
