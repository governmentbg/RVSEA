import { appStore } from '@/store/app';
import http from '@/services/http.service';
import {
    IPackageATemplate,
    PackageATemplateCreateModel,
    PackageATemplateUpdateModel,
} from '@/models/packageATemplates';
import { IPackageAFile, IPackagesFormData } from '@/models/packages';
import { IPackageDocument } from '@/models/applications';

class PackagesService {
    private url = appStore().getters.baseUrl + '/api/Packages';

    getFileDownloadUrl(id: number, inline?: boolean): string {
        return `${this.url}/download/${id}${inline ? '?isInline=true' : ''}`;
    }

    get(id: number): Promise<IPackageATemplate[]> {
        return http.get(`${this.url}/${id}`).then((response) => response.data.data);
    }

    create(data: IPackagesFormData): Promise<number> {
        const fd = this.createImportFormData(data);
        return http.post(`${this.url}`, fd).then((response) => response.data.data);
    }

    createWithImport(data: IPackagesFormData): Promise<number> {
        const fd = this.createImportFormData(data);
        return http.post(`${this.url}/packageWithImport`, fd).then((response) => response.data.data);
    }

    private createImportFormData(data: IPackagesFormData): FormData {
        const fd = new FormData();

        const model = {
            applicationId: data.applicationId,
            packageA: data.packageA.map((x) => {
                if (x.file) {
                    fd.append('packageAFiles', x.file);
                }

                return {
                    id: x.id,
                    documentTypeId: x.documentTypeId,
                    description: x.description,
                    fileName: x.file?.name,
                    fileSize: x.file?.size,
                    _deleted: x._deleted,
                };
            }),
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
                    parentId: x.parentId,
                };
            }),
        };

        fd.append('model', JSON.stringify(model));
        return fd;
    }

    create_obsolete(data: PackageATemplateCreateModel): Promise<number> {
        const fd = new FormData();
        fd.append('procedureId', data.procedureId!.toString());
        fd.append('description', data.description || '');
        fd.append('required', data.required.toString());
        fd.append('title', data.title);
        fd.append('file', data.file!);

        return http.post(`${this.url}`, fd).then((response) => response.data.data);
    }

    update(data: PackageATemplateUpdateModel) {
        const fd = new FormData();
        fd.append('id', data.id.toString());
        fd.append('description', data.description || '');
        fd.append('required', data.required.toString());
        fd.append('title', data.title);

        if (data.file != null && data.file.size > 0) {
            fd.append('file', data.file!);
        }

        return http.put(`${this.url}`, fd);
    }

    delete(id: number) {
        return http.delete(`${this.url}/${id}`);
    }

    submit(id: number) {
        return http.post(`${this.url}/submit/${id}`, {});
    }

    getTemplate(id: number): Promise<IPackageATemplate> {
        return http.get(`${this.url}/template/${id}`).then((response) => response.data.data);
    }

    async getTemplatesBySignatureRequest(applicationId: number): Promise<IPackageATemplate[]> {
        const response = await http.get(`${this.url}/templates/bySignatureRequest/${applicationId}`);
        return response.data.data;
    }

    getByApplication(applicationId: number): Promise<IPackagesFormData> {
        return http.get(`${this.url}/byApplication/${applicationId}`).then((response) => response.data.data);
    }

    async getPackageDocumentsBySignatureRequest(applicationId: number): Promise<IPackageDocument[]> {
        const response = await http.get(`${this.url}/signatureRequest/${applicationId}`);
        return response.data.data;
    }

    async hasPackageDocumentsBySignatureRequest(applicationId: number): Promise<boolean> {
        const response = await http.get(`${this.url}/signatureRequest/has/${applicationId}`);
        return response.data.data;
    }

    async sendSignedPackageDocuments(applicationId: number, packageDocuments: IPackageAFile[]) {
        const formData = new FormData();

        const model = packageDocuments.map((doc) => {
            if (doc.file) {
                formData.append('signedFiles', doc.file);
            }

            return {
                documentTypeId: doc.documentTypeId,
                description: doc.description,
                fileName: doc.file?.name,
                fileSize: doc.file?.size,
                id: doc.id,
            };
        });

        formData.append('model', JSON.stringify(model));

        const response = await http.post(`${this.url}/signedDocuments/${applicationId}`, formData);
        return response;
    }

    async streamPackageDocumentFile(
        id: number,
        inline?: boolean
    ) {
        const url = this.getFileDownloadUrl(id, inline)
        const response = await http.get(url.toString(), undefined, undefined, { responseType: "blob" });
        return response.data;
    }
}

const packagesService = new PackagesService();
export default packagesService;
