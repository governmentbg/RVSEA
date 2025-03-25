export class ChecksumsVerifyResultModel {
    processes? = [] as ChecksumVerifyProcessModel[];
}

export class ChecksumVerifyProcessModel {
    processKind?: number;
    processName?: string;
    summary?: string;
    checksumVerifyItemModel? = [] as ChecksumVerifyItemModel[];
}

export class ChecksumVerifyItemModel {
    documentId?: string;
    fileName?: string;
    success?: boolean | null = null;
    message?: string;
}
