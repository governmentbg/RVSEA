import { IPackageAFile } from "./packages";

export class PackageATemplateDisplayModel implements IPackageATemplate {
	constructor(obj: IPackageATemplate = {} as IPackageATemplate) {
		this.id = obj.id;
		this.title = obj.title;
		this.procedureId = obj.procedureId;
		this.fileId = obj.fileId;
		this.fileName = obj.fileName;
		this.fileSize = obj.fileSize;
		this.required = obj.required || false;
		this.sort = obj.sort;
		this.description = obj.description;
		this.doc = obj.doc || {};
	}

	id: number;
	title: string;
	procedureId: number;
	required: boolean;
	description: string;
	sort: number;
	fileId: number;
	fileName: string;
	fileSize: number;
	doc: IPackageAFile
}

export class PackageATemplateCreateModel {
	title: string = '';
	description: string = '';
	procedureId: number | null = null;
	required: boolean = false;
	sort: number = 0;
	file: File | null = null;
}

export interface IPackageATemplate {
	id: number;
	title: string;
	description: string;
	procedureId: number;
	required: boolean;
	sort: number;
	fileId: number;
	fileName: string;
	fileSize: number;
	file?: File;
	fileDescription?: string,
	_deleted?: boolean;
	doc: IPackageAFile;
}

export class PackageATemplateUpdateModel extends PackageATemplateDisplayModel {
	constructor(obj: IPackageATemplate = {} as IPackageATemplate) {
		super(obj);

	}
	file: File | null = null;
}