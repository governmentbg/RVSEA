import { ImportedStructure } from "@/interfaces/application";
import { IPackageDocument } from "@/models/applications";
import { IPackageATemplate } from "@/models/packageATemplates";

export const getFileExtension = (fileName: string) => {
    const fileExtension = fileName.replace(/^.*\./, '');
    return fileExtension.toLowerCase();
};
export const isImage = (filename: string) => {
    const imagesExtension = [
        'apng',
        'avif',
        'gif',
        'jpg',
        'jpeg',
        'jfif',
        'pjpeg',
        'pjp',
        'png',
        'svg',
        'webp',
        'bmp',
        'ico',
        'cur',
        'tif',
        'tiff',
    ];
    const fileExtension = getFileExtension(filename);

    const isImageFileType = imagesExtension.indexOf(fileExtension) !== -1;

    return isImageFileType;
};

export const isSound = (filename: string) => {
    const songsExtension = ['mp3', 'mp4', ' mpeg', 'wma', 'aac', 'wav', 'aiff'];
    const fileExtension = getFileExtension(filename);

    const isSongFileType = songsExtension.indexOf(fileExtension) !== -1;

    return isSongFileType;
};

export const isPdf = (filename: string) => {
    const imagesExtension = ['pdf'];
    const fileExtension = getFileExtension(filename);
    const isImageFileType = imagesExtension.indexOf(fileExtension) !== -1;
    return isImageFileType;
};


export const getTotalUploadPackageBFileSize = (importedStructure: ImportedStructure[]) => {
    const totalFileSizeDoc = importedStructure?.map(x =>
        x.documents.map(d => d.doc.file ? d.doc.size ?? 0 : 0).reduce((acc, curr) => acc + curr, 0)
    ).reduce((acc, curr) => acc + curr, 0) ?? 0;

    // const totalFileSizeDerivative = importedStructure?.map(x =>
    //     x.documents.map(d => d.derivative.file ? d.derivative.size ?? 0 : 0).reduce((acc, curr) => acc + curr, 0)
    // ).reduce((acc, curr) => acc + curr, 0) ?? 0;

    // const totalFileSize = totalFileSizeDoc + totalFileSizeDerivative;
    const totalFileSize = totalFileSizeDoc;
    return totalFileSize;
};


export const getTotalUploadPackageAFileSize = (templates: IPackageATemplate[]) => {
    const totalFileSize = templates?.map(d => d.doc.file ? d.doc.file.size ?? 0 : 0).reduce((acc, curr) => acc + curr, 0);
    return totalFileSize;
};

export const getTotalUploadPackageADocFileSize = (templates: IPackageDocument[]) => {
    const totalFileSize = templates?.map(d => d.content ? d.content.size ?? 0 : 0).reduce((acc, curr) => acc + curr, 0);
    return totalFileSize;
};


export const b64toBlob = (b64Data: string, contentType = 'application/pdf', sliceSize = 512) => {
    const byteCharacters = atob(b64Data);
    const byteArrays = [];

    for (let offset = 0; offset < byteCharacters.length; offset += sliceSize) {
        const slice = byteCharacters.slice(offset, offset + sliceSize);

        const byteNumbers = new Array(slice.length);
        for (let i = 0; i < slice.length; i++) {
            byteNumbers[i] = slice.charCodeAt(i);
        }
        const byteArray = new Uint8Array(byteNumbers);
        byteArrays.push(byteArray);
    }

    const blob = new Blob(byteArrays, { type: contentType });
    const url = URL.createObjectURL(blob);
    return url;
};