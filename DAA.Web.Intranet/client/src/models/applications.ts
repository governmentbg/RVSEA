export class ApplicationCreateModel {
	constructor(obj: IApplicationCreate) {
		this.type = obj.type;
		this.userId = obj.userId;
		this.application = obj.application;
	}
	type: string = '';
	userId: string = '';
	application: File;
}

export interface IApplicationCreate {
	type: string;
	userId: string;
	application: File;
}

export interface IApplicationGrid {
	id: number;
	type: string;
	typeId: string;
	status: string,
	statusId: number,
	applicant: string;
	applicationDate: File;
}

export interface IApplicationDisplay{
	id: number;
	type: string;
	status: string,
	statusId: number,
	applicant: string;
	applicantEmail: string;
	applicationDate: Date;
	assignToId: string;
	assignToName: string;
	fileId: number;
	fileName: string;
	rejectReason: string;
	archive: string;
	archiveId: number;
	number: number;
	applicantFullName: string;
	redirectedFromArchiveName?: string;
	redirectedToArchiveName?: string;
	inventorySysId?: string;
	fundSysId?: string;
	fundNumber?: string;
}

export interface IApprove {
	id: number,
	userId: string
}

export interface IReject {
	id: number,
	reason: string
}