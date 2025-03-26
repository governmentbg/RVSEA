export interface ISearchResult {
    entityType?: string;
    systemIdentifier?: string;
    archiveName?: string;
    fundNumber?: string;
    inventoryNumber?: string;
    archivalEntityNumber?: string;
    kmfNumber?: string;
    title?: string;
    typeText?: string;
    statusText?: string;
    fundDescriptionLevelText?: string;
    inventoryDescriptionLevelText?: string;
    archivalEntityDescriptionLevelText?: string;
    hasExternalSource?: boolean;
    externalIdentifier?: number;
    fundApproximateChronologicalScope?: string;
    inventoryApproximateChronologicalScope?: string;
    archivalEntityApproximateChronologicalScope?: string;
    filmSystemIdentifier?: string;
    fundGid?: number;
    hasDigitizedDigitalObjects?: boolean;
    documentNumber?: string;
}
