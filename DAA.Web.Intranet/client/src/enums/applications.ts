export enum Status {
	new = 1,
	approved = 2,
	rejected = 3,
	addPackages = 4,
	updatePackages = 5,
	rejectedByCommittee = 6,
	approvedByCommittee = 7,
	awaitingCommittee = 8,
	committeeDecisionUpdate = 9,
	registration = 10,
	registrationComplete = 11,
	packagesApproval = 12,
	rejectedByCommission = 13,
	acquisitionContract = 14,
	signatureRequest = 15,
	signedDocuments = 16,
	redirected = 17,
	modificationRequest = 18,
	modificationApplied = 19,
}

export enum ApplicationType {
	assembled = 'assembled',
	raw = 'raw',
}