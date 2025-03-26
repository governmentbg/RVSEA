export class TaskTemplateDisplayModel implements ITaskTemplate {
	constructor(obj: ITaskTemplate = {} as ITaskTemplate) {
		this.taskTemplateId = obj.taskTemplateId;
		this.title = obj.title;
		this.description = obj.description;
		this.relatedContentUrl = obj.relatedContentUrl;
	}

	taskTemplateId: number;
	title: string;
	description: string;
	relatedContentUrl: string;
}

export interface ITaskTemplate {
	taskTemplateId: number;
	title: string;
	processesStepId?: Array<number>;
	description: string;
	relatedContentUrl: string;
}

export class TaskTemplateCreateModel {
	title: string = '';
	description: string = '';
	relatedContentUrl: string = '';
	processesStepId: Array<number> = [];
}

export class TaskTemplateUpdateModel extends TaskTemplateDisplayModel {
	constructor(obj: ITaskTemplate = {} as ITaskTemplate) {
		super(obj);
		this.processesStepId = obj.processesStepId
	}
	processesStepId?: number[];
}