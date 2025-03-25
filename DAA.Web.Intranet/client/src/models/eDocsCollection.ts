export interface IProcessDecision {
	processId: number;
	accepted: boolean;
	hasConditions: boolean;
	assignForRedirect: boolean;
	redirectToArchiveId?: number;
	assignToUserId?: string;
	assignToRoleId?: string;
}