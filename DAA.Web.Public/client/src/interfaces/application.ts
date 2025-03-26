import { IPackageBFile } from '@/models/packages';

export interface ImportedStructure {
    systemIdentifier: string;
    number?: string;
    numberArray?: string;
    numberNumeric?: number;
    title: string;
    documents: ImportedDocument[];
}

export interface ImportedDocument {
    systemIdentifier: string;
    documentNumber?: number;
    title: string;
    doc: IPackageBFile;
    derivative: IPackageBFile;
}
