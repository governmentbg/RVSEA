import { PackageType } from '@/enums/packages';
import { IPackageFile } from '@/interfaces/package';
import { IInternalPackagesFormData, IPackageAAddFile, IPackageAFile, IPackageBFile } from '@/models/packages';
import http from '@/services/http.service';
import { appStore } from '@/store/app';

class PackagesService {
    private url = appStore().getters.baseUrl + '/api/Packages';

    getPackageUrl(id: number) {
        return `${this.url}/${id}`;
    }

    getPackageFileUrl(id: number, packageId: number, inline?: boolean) {
        const url = new URL(`${this.url}/files/download/${id}`);
        url.searchParams.append('packageId', packageId.toString());
        if (inline) {
            url.searchParams.append('inline', String(inline));
        }
        return url.toString();
    }

    async get(id: number, hasTemplate?: boolean): Promise<Array<IPackageAFile>> {
        const url = new URL(`${this.url}/${id}`);
        if (hasTemplate) {
            url.searchParams.append('hasTemplate', String(hasTemplate));
        }

        const response = await http.get(url.toString());
        return response.data;
        //return http.get(`${this.url}/${id}`).then((response) => response.data);
    }

    async getPackageFiles(packageId: number): Promise<Array<IPackageFile>> {
        const response = await http.get(`${this.url}/${packageId}`);
        return response.data;
    }

    removeFileFromPackage(id: number): Promise<Array<IPackageAFile>> {
        return http.delete(`${this.url}/RemoveFileFromPackage/${id}`).then((response) => response.data);
    }

    getPackageAIdByProcess(id: number): Promise<number> {
        return http.get(`${this.url}/getPackageAIdByProcess/${id}`).then((response) => response.data);
    }

    async getPackageIdByInventory(inventorySysId: string, packageType: PackageType): Promise<number> {
        const url = new URL(`${this.url}/getPackageIdByInventory/${inventorySysId}`);
        if (packageType) {
            url.searchParams.append('type', packageType);
        }

        const response = await http.get(url.toString());
        return response.data.data;
    }

    addDocumentToPAckage(data: IPackageAAddFile, inventorySysIdentifier?: string): Promise<number> {
        const fd = new FormData();
        if (data.documentTypeId) {
            fd.append('documentTypeId', data.documentTypeId.toString());
        }

        fd.append('packageId', data.packageId.toString());
        fd.append('description', data.description || '');
        fd.append('file', data.file!);
        if (data.files) {
            data.files.forEach((element) => {
                fd.append('files', element);
            });
        }
        if (data.skipValidation) {
            fd.append('skipValidation', data.skipValidation.toString());
        }
        if (data.signatureFile) {
            fd.append('signatureFile', data.signatureFile.toString());
        }
        if (inventorySysIdentifier != '') {
            fd.append('inventorySysIdentifier', inventorySysIdentifier!.toString());
        }

        return http.post(`${this.url}/AddFileToPackage`, fd).then((response) => response.data.data);
    }

    getAvailableDocsForAE(inventorySystemIdentifier: string, packageId: number): Promise<Array<IPackageBFile>> {
        return http
            .get(`${this.url}/getAvailableDocsForAE/${inventorySystemIdentifier}/${packageId}`)
            .then((response) => response.data.data);
    }

    async addPackageFiles(
        files: File[],
        packageId?: number,
        packageType?: PackageType,
        inventorySystemIdentiifer?: string
    ): Promise<void> {
        const url = new URL(`${this.url}/files/add/${packageId ?? ''}`);
        if (packageType) {
            url.searchParams.append('type', packageType);
        }
        if (inventorySystemIdentiifer) {
            url.searchParams.append('inventorySystemIdentiifer', inventorySystemIdentiifer);
        }

        const formData = new FormData();
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            formData.append('files', file);
        }

        const response = await http.post(url.toString(), formData);
        return response.data;
    }

    async deletePackageFile(id: number, packageId: number): Promise<void> {
        const url = new URL(`${this.url}/files/delete/${id}`);
        url.searchParams.append('packageId', packageId.toString());

        const response = await http.delete(url.toString());
        return response.data;
    }

    createWithImport(data: IInternalPackagesFormData): Promise<number> {
        const fd = new FormData();
        const model = {
            InventoryIdentifier: data.inventoryId,
            packageB: data.packageB.map((x) => {
                if (x.file) {
                    fd.append('packageBFiles', x.file);
                }
                return {
                    id: x.id,
                    fileName: x.file?.name,
                    fileSize: x.file?.size,
                    documentSystemIdentifier: x.documentId,
                    _deleted: x._deleted,
                    typeCode: x.typeCode,
                };
            }),
        };

        fd.append('model', JSON.stringify(model));

        return http.post(`${this.url}/packageWithImport`, fd).then((response) => response.data.data);
    }

    getPackageBById(packageId: number): Promise<Array<IPackageBFile>> {
        return http.get(`${this.url}/PackageBById/${packageId}`).then((response) => response.data.data);
    }
}

const packagesService = new PackagesService();
export default packagesService;
