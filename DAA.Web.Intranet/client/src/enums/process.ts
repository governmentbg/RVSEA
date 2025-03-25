export enum ProcessType {
	AddInventory = 1,
	AddRawInventory = 2,
	AddSystemInventory = 20,
	DocsCollectingOwnExternal = 3,

	FilmRegisterData = 4,
	FilmRegisterCard = 5,
	FilmEditData = 6,

	AddDocument = 7,
	PreparationOfADigitalObject = 8,
	ImportDigitalObject = 9,

	DeductData = 10,
	EditData = 11,
	RefineData = 12,

	EditFundData = 13,
	AddRawInventoryRaw = 14,
	AddFundAndInventory = 15,
	AddRawFundAndRawInventory = 16,
	ProcessRawFundWithRawInventory = 17,
	ReconstructFundData = 18,
	ProcessFundWithRawInventory = 19,
}

export enum ProcessStep {
	New = 0,

	Film_RegisterData = 1,
	Film_CreatePackages = 2,
	Film_SendForApproval = 3,
	Film_Approval = 4,
	Film_ReturnForEdit = 5,
	Film_EditData = 6,
	Film_Rejection = 7,

	Film_RegisterCardData = 8,
	Film_SendCardForApproval = 9,
	Film_CardApproval = 10,
	Film_ReturnCardForEdit = 11,
	Film_EditCardData = 12,
	Film_CardRejection = 13,

	Film_EditAllData = 14,
	Film_SendAllForApproval = 15,
	Film_AllApproval = 16,
	Film_ReturnAllForEdit = 17,
	Film_EditReturnAllData = 18,
	Film_AllRejection = 19,

	//процес Създаване на документ
	Document_InitiatingAProcess = 20,
	Document_ViewMetadataAndSelectAScanning = 21,
	Document_ReturnedForEditingMetadata = 22,
	//процес Създаване на диг обкет
	Document_PreparationOfADigitalObject = 23,
	Document_QualityControl = 24,
	Documentt_ViewMetadataAndSelectAScanning = 25,
	Documentt_InitiatingAProcess = 26,
	Documentt_ReturnedForEditingMetadata = 27,
	Document_ReturnedForEditingDigitalData = 28,
	//импорт дигидален обект
	Documentt_PreparationOfADigitalObject = 29,
	Documentt_QualityControl = 30,
	Documentt_ReturnedForEditingDigitalData = 31,

	Deduction_InitiationOfProcessAndPreparationEPKReport = 32,
	Deduction_SettingADateForConsiderationOfAnEPKReport = 33,
	Deduction_IntroductionOfAnOpinionByEPKMembers = 34,
	Deduction_DecisionAfterAMeetingOfTheEPK = 35,
	Deduction_ImplementationOfRecommendationsFromEPK = 36,
	Deduction_CheckingTheCorrectionsMade = 37,
	Deduction_ApprovalByDirector = 38,
	Deduction_AgreeToRequestCorrections = 39,

	EditData_ProcessInitiation = 40,
	EditData_EditData = 41,
	EditData_UndoChanges = 97,
	EditData_ProcessFinalization = 42,

	RefineData_ProcessInitiation = 43,
	RefineData_EditData = 103,
	RefineData_UndoChanges = 104,
	RefineData_CreateReport = 106,
	RefineData_SendReport = 107,
	RefineData_ChangesRequired = 237,
	RefineData_DataModifications = 240,
	RefineData_AddReportToSessionAgenda = 108,
	RefineData_SendToAddSessionAgendaStandpoint = 117,
	RefineData_SendToAddSessionAgendaStandpointComment = 118,
	RefineData_AddSessionAgendaStandpoint = 113,
	RefineData_AddSessionAgendaStandpointComment = 114,
	RefineData_SendSessionAgendaStandpointComment = 120,
	RefineData_CommissionSession = 122,
	RefineData_SessionMinutesOfMeetingForApproval = 152,
	RefineData_SessionMinutesOfMeeting = 130,
	RefineData_ReportApproval = 131,
	RefineData_ReportChangesRequired = 132,
	RefineData_ReportRejection = 133,
	RefineData_ReportModifications = 134,
	RefineData_SendForModificationsRevision = 139,
	RefineData_ModificationsRevision = 140,
	RefineData_SendForAffirmation = 135,
	RefineData_Affirmation = 136,
	RefineData_ProcessFinalization = 109,

	EditFundData_ProcessInitiation = 55,
	EditFundData_EditData = 98,
	EditFundData_UndoChanges = 99,
	EditFundData_CreateReport = 100,
	EditFundData_SendReport = 101,
	EditFundData_ChangesRequired = 238,
	EditFundData_DataModifications = 241,
	EditFundData_AddReportToSessionAgenda = 102,
	EditFundData_SendToAddSessionAgendaStandpoint = 115,
	EditFundData_SendToAddSessionAgendaStandpointComment = 116,
	EditFundData_AddSessionAgendaStandpoint = 111,
	EditFundData_AddSessionAgendaStandpointComment = 112,
	EditFundData_SendSessionAgendaStandpointComment = 119,
	EditFundData_CommissionSession = 121,
	EditFundData_SessionMinutesOfMeetingForApproval = 154,
	EditFundData_SessionMinutesOfMeeting = 123,
	EditFundData_ReportApproval = 124,
	EditFundData_ReportChangesRequired = 125,
	EditFundData_ReportRejection = 126,
	EditFundData_ReportModifications = 127,
	EditFundData_SendForModificationsRevision = 137,
	EditFundData_ModificationsRevision = 138,
	EditFundData_SendForAffirmation = 128,
	EditFundData_Affirmation = 129,
	EditFundData_ProcessFinalization = 105,

	ReconstructFundData_ProcessInitiation = 142,
	ReconstructFundData_ProcessFinalization = 143,
	ReconstructFundData_UndoChanges = 144,
	ReconstructFundData_RequestPublicAccessSuspension = 147,
	ReconstructFundData_SuspendPublicAccess = 145,
	ReconstructFundData_EditData = 146,
	ReconstructFundData_CreateReport = 215,
	ReconstructFundData_SendReport = 216,
	ReconstructFundData_ChangesRequired = 236,
	ReconstructFundData_DataModifications = 239,
	ReconstructFundData_AddReportToSessionAgenda = 217,
	ReconstructFundData_AddSessionAgendaStandpoint = 218,
	ReconstructFundData_AddSessionAgendaStandpointComment = 219,
	ReconstructFundData_SendToAddSessionAgendaStandpoint = 220,
	ReconstructFundData_SendToAddSessionAgendaStandpointComment = 221,
	ReconstructFundData_SendSessionAgendaStandpointComment = 222,
	ReconstructFundData_CommissionSession = 223,
	ReconstructFundData_SessionMinutesOfMeetingForApproval = 213,
	ReconstructFundData_SessionMinutesOfMeeting = 214,
	ReconstructFundData_ReportApproval = 224,
	ReconstructFundData_ReportChangesRequired = 225,
	ReconstructFundData_ReportRejection = 226,
	ReconstructFundData_ReportModifications = 227,
	ReconstructFundData_SendForAffirmation = 228,
	ReconstructFundData_Affirmation = 229,
	ReconstructFundData_SendForModificationsRevision = 230,
	ReconstructFundData_ModificationsRevision = 231,
	ReconstructFundData_SendForRegistration = 232,
	ReconstructFundData_Registration = 233,

	ProcessRawFundWithRawInventory_ProcessInit = 169,
	ProcessRawFundWithRawInventory_ChooseRawInventories = 141,
	ProcessRawFundWithRawInventory_CreateInventories = 149,
	ProcessRawFundWithRawInventory_CreateReport = 168,
	ProcessRawFundWithRawInventory_SendReport = 171,
	ProcessRawFundWithRawInventory_AddReportToSessionAgenda = 172,
	ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpoint = 174,
	ProcessRawFundWithRawInventory_SendToAddSessionAgendaStandpointComment = 175,
	ProcessRawFundWithRawInventory_AddSessionAgendaStandpoint = 173,
	ProcessRawFundWithRawInventory_AddSessionAgendaStandpointComment = 176,
	ProcessRawFundWithRawInventory_SendSessionAgendaStandpointComment = 177,
	ProcessRawFundWithRawInventory_CommissionSession = 178,
	ProcessRawFundWithRawInventory_ReportApproval = 179,
	ProcessRawFundWithRawInventory_ReportChangesRequired = 180,
	ProcessRawFundWithRawInventory_ReportRejection = 181,
	ProcessRawFundWithRawInventory_ReportModifications = 182,
	ProcessRawFundWithRawInventory_SendForModificationsRevision = 183,
	ProcessRawFundWithRawInventory_ModificationsRevision = 184,
	ProcessRawFundWithRawInventory_SendForAffirmation = 185,
	ProcessRawFundWithRawInventory_Affirmation = 186,
	ProcessRawFundWithRawInventory_SendToRegistrar = 211,
	ProcessRawFundWithRawInventory_RegisterInventories = 212,
	ProcessRawFundWithRawInventory_UndoChanges = 148,
	ProcessRawFundWithRawInventory_ProcessFinalization = 170,
	ProcessRawFundWithRawInventory_ConfirmationProtocolSent = 166,
    ProcessRawFundWithRawInventory_ConfirmedProtocol = 167,
	ProcessRawFundWithRawInventory_DataModifications = 242,
	ProcessRawFundWithRawInventory_ChangesRequired = 244,


	ProcessFundWithRawInventory_ProcessInit = 187, 								// Инициализиране на процес
	ProcessFundWithRawInventory_ChooseRawInventories = 190,						// Избор на груби описи за обработка
	ProcessFundWithRawInventory_CreateInventories = 191, 						// Създаване на инвентарни описи
	ProcessFundWithRawInventory_CreateReport = 192, 							// Изготвяне на доклад
	ProcessFundWithRawInventory_SendReport = 193,								// Изпращане на доклад за заседание
	ProcessFundWithRawInventory_AddReportToSessionAgenda = 194, 				// Добавяне на доклад в дневен ред на заседание
	ProcessFundWithRawInventory_AddSessionAgendaStandpoint = 195, 				// Изготвяне на становище по дневен ред
	ProcessFundWithRawInventory_SendToAddSessionAgendaStandpoint = 196, 		// Изпращане за становище по дневен ред
	ProcessFundWithRawInventory_SendToAddSessionAgendaStandpointComment = 197,	// Изпращане за коментар по становище
	ProcessFundWithRawInventory_AddSessionAgendaStandpointComment = 198, 		// Въвеждане на коментар по становище
	ProcessFundWithRawInventory_SendSessionAgendaStandpointComment = 199,		// Изпращане на коментари по становища
	ProcessFundWithRawInventory_CommissionSession = 200,						// Заседание на комисия
	ProcessFundWithRawInventory_ReportApproval = 201,							// Одобрение на доклад
	ProcessFundWithRawInventory_ReportChangesRequired = 202,					// Връщане за корекции след заседание
	ProcessFundWithRawInventory_ReportRejection = 203,							// Отхвърляне на доклад
	ProcessFundWithRawInventory_ReportModifications = 204,						// Изпълнение на препоръки от комисия
	ProcessFundWithRawInventory_SendForModificationsRevision = 205,				// Изпращане за проверка на извършените корекции
	ProcessFundWithRawInventory_ModificationsRevision = 206,					// Проверка на извършените корекции
	ProcessFundWithRawInventory_SendForAffirmation = 207,						// Изпращане за утвърждаване
	ProcessFundWithRawInventory_Affirmation = 208,								// Утвърждаване
	ProcessFundWithRawInventory_SendToRegistrar = 209,							// Насочване към регистратор
	ProcessFundWithRawInventory_RegisterInventories = 210,						// Регистриране на инвентарни описи
	ProcessFundWithRawInventory_UndoChanges = 189,								// Отмяна на промените
	ProcessFundWithRawInventory_ProcessFinalization = 188,						// Завършване на процес
	ProcessFundWithRawInventory_ConfirmationProtocolSent = 234,					// Протокол от заседание на комисия за утвърждаване
    ProcessFundWithRawInventory_ConfirmedProtocol = 235,						// Утвърден протокол от заседание на комисия
	ProcessFundWithRawInventory_DataModifications = 243, 						// Извършване на корекции
	ProcessFundWithRawInventory_ChangesRequired = 245, 							// Връщане за корекции преди заседание

	ProcessInitialization = 1000,
	AddPackages = 1001,
	CommissionReport = 1002,
	CommissionReportEdit = 1003,
	PackagesEdit = 1004,
	CommissionReviewDate = 1005,
	CommissionOpinions = 1006,
	CommissionSession = 1016,
	CommissionDecision = 1007,
	ConfirmationProtocolSent = 1008,
	ConfirmedProtocol = 1009,
	CommissionCorrections = 1010,
	CommissionCorrections_PackagesEdit = 1011,
	CommissionCorrectionsCheck = 1012,
	SendForRedirect = 1021,
	Redirected = 1022,
	SendForAffirmation = 1019,
	Affirmation = 1020,
	AcquisitionContract = 1013,
	RequestSignature = 1017,
	SignedDocuments = 1018,
	SendForRegistration = 1023,
	Registration = 1014,
	EndProcess = 1015,


	AddInventory_Registration = 70,
	AddInventoryRaw_Registration = 83,
	AddFundAndInventory_Registration = 96,
}
