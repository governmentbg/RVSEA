 
begin transaction

INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (1, N'fund', N'Добавяне на пореден опис', N'AddInventory')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (2, N'fund', N'Регистриране на опис с необработени документи', N'AddRawInventory')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (4, N'film', N'Регистриране на копия от чужди архиви', N'FilmRegisterData')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (5, N'film', N'Научно-техническа обработка на постъпление към КМФ', N'FilmRegisterCard')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (6, N'film', N'Редакция на данни', N'FilmEditData')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (7, N'archival_entity', N'Добавяне на документ', N'AddDocument')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (8, N'archival_entity', N'Изготвяне на дигитален обект', N'PreparationOfADigitalObject')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (9, N'document', N'Импортиране на дигитален обект', N'ImporтDigitalObject')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (10, N'all levels', N'Отчисляване', N'Deduction')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (11, N'all levels', N'Редакция', N'EditData')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (12, N'all levels', N'Усъвършенстване', N'RefineData')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (13, N'fund', N'Промяна в наименованието на фонда', N'EditFundData')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (14, N'raw_fund', N'Регистриране на опис с необработени документи', N'AddRawInventoryRaw')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (15, N'archive', N'Регистрация на нов фонд с пореден опис', N'AddFundAndInventory')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (16, N'archive', N'Регистриране на нов фонд и опис с необработени документи ', N'AddRawFundAndRawInventory')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (17, N'raw_fund', N'Обработка на необработени постъпления', N'ProcessRawFundWithRawInventory')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (18, N'fund', N'Пресъставяне', N'ReconstructFundData')
GO
INSERT [N].[ProcessTypes] ([Id], [Type], [Name], [Code]) VALUES (19, N'fund', N'Обработка на необработени постъпления', N'ProcessFundWithRawInventory')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1, 4, N'RegisterData', N'Регистриране на данни')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (2, 4, N'CreatePackages', N'Изготвяне на пакети А и Б')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (3, 4, N'SendForApproval', N'Изпратено за съгласуване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (4, 4, N'Approval', N'Одобрение')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (5, 4, N'ReturnForEdit', N'Връщане за редакция')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (6, 4, N'EditData', N'Редакция на данни')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (7, 4, N'Rejection', N'Отмяна')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (8, 5, N'RegisterCardData', N'Регистриране на данни')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (9, 5, N'SendCardForApproval', N'Изпращане за съгласуване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (10, 5, N'CardApproval', N'Одобрение')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (11, 5, N'ReturnCardForEdit', N'Връщане за редакция')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (12, 5, N'EditCardData', N'Редакция на данни')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (13, 5, N'CardRejection', N'Отмяна')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (14, 6, N'EditAllData', N'Редакция на всички данни')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (15, 6, N'SendAllForApproval', N'Изпращане за съгласуване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (16, 6, N'AllApproval', N'Одобрение')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (17, 6, N'ReturnAllForEdit', N'Връщане за редакция')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (18, 6, N'EditReturnAllData', N'Редакция на данни')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (19, 6, N'AllRejection', N'Отмяна')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (20, 7, N'InitiatingAProcess', N'Иницииране на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (21, 7, N'ViewMetadataAndSelectAScanning', N'Преглед на метаданните и избор на сканиращ')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (22, 7, N'ReturnedForEditingMetadata', N'Върнато за редакция на метаданни')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (23, 8, N'PreparationOfADigitalObject', N'Изготвяне на дигитален обект')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (24, 8, N'QualityControl', N'Контрол по качеството')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (25, 8, N'ViewMetadataAndSelectAScanning', N'Преглед на метаданните и избор на сканиращ')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (26, 8, N'InitiatingAProcess', N'Иницииране на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (27, 8, N'ReturnedForEditingMetadata', N'Върнато за редакция на метаданни')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (28, 8, N'ReturnedForEditingDigitalData', N'Върнато за редакция на дигиталните обекти')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (29, 9, N'PreparationOfADigitalObject', N'Изготвяне на дигитален обект')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (30, 9, N'QualityControl', N'Контрол по качеството')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (31, 9, N'ReturnedForEditingDigitalData', N'Върнато за редакция на дигиталните обекти')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (32, 10, N'Initiation of process and preparation EPK report', N'Иницииране не процес и изготвяне на доклад към ЕПК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (33, 10, N'Setting a date for consideration of an EPK report', N'Определяне на дата за разглеждане на доклад за ЕПК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (34, 10, N'Introduction of an opinion by EPK members', N'Въвеждане на становище от членове на ЕПК ')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (35, 10, N'Decision after a meeting of the EPК', N'Решение след заседание на ЕПК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (36, 10, N'Implementation of recommendations from EPК', N'Изпълнение на препоръки от ЕПК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (37, 10, N'Checking the corrections made', N'Проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (38, 10, N'Approval by Director', N'Утвърждаване от Директор')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (39, 10, N'Agree to request corrections', N'Съгласуване за искане на корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (40, 11, N'ProcessInitiation', N'Иницииране на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (41, 11, N'EditData', N'Редакция на данни')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (42, 11, N'ProcessFinalization', N'Завършване на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (43, 12, N'ProcessInitiation', N'Иницииране на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (55, 13, N'ProcessInitiation', N'Иницииране на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (56, 7, N'ProcessFinalization', N'Завършване на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (57, 8, N'ProcessFinalization', N'Завършване на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (58, 9, N'ProcessFinalization', N'Завършване на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (59, 1, N'ProcessInitialize ', N'Инициализиране на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (60, 1, N'AddPackages', N'Добавяне на пакети А и Б')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (61, 1, N'EpkReport', N'Изготвяне на доклад към ЕПК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (62, 1, N'EpkReportEdit', N'Промяна на данни за доклад към ЕПК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (63, 1, N'PackagesEdit', N'Промяна на пакет А')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (64, 1, N'EpkReviewDate', N'Определяне на дата за разглеждане на Доклад за ЕПК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (65, 1, N'EpkOpinions', N'Въвеждане на становища от членове на ЕПК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (66, 1, N'EpkDecision', N'Решение след заседание на ЕПК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (67, 1, N'EpkCorrections', N'Изпълнение на препоръки от ЕПК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (68, 1, N'EpkCorrectionsCheck', N'Проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (69, 1, N'DirectorApproval', N'Утвърждаване от директор')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (70, 1, N'Registration', N'Регистриране')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (71, 14, N'ProcessInitialize ', N'Инициализиране на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (72, 14, N'AddPackages', N'Добавяне на пакети А и Б')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (73, 14, N'EpkReport', N'Изготвяне на доклад към ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (74, 14, N'EpkReportEdit', N'Промяна на данни за доклад към ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (75, 14, N'PackagesEdit', N'Промяна на пакет А')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (76, 14, N'EpkReviewDate', N'Определяне на дата за разглеждане на Доклад за ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (77, 14, N'EpkOpinions', N'Въвеждане на становища от членове на ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (78, 14, N'EpkDecision', N'Решение след заседание на ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (79, 14, N'EpkCorrections', N'Изпълнение на препоръки от ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (80, 14, N'EpkCorrectionsCheck', N'Проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (81, 14, N'AcquisitionContract', N'Изготвяне на договор за продобиване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (82, 14, N'DirectorApproval', N'Утвърждаване от директор')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (83, 14, N'Registration', N'Регистриране')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (84, 15, N'ProcessInitialize ', N'Инициализиране на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (85, 15, N'AddPackages', N'Добавяне на пакети А и Б')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (86, 15, N'EpkReport', N'Изготвяне на доклад към ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (87, 15, N'EpkReportEdit', N'Промяна на данни за доклад към ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (88, 15, N'PackagesEdit', N'Промяна на пакет А')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (89, 15, N'EpkReviewDate', N'Определяне на дата за разглеждане на Доклад за ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (90, 15, N'EpkOpinions', N'Въвеждане на становища от членове на ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (91, 15, N'EpkDecision', N'Решение след заседание на ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (92, 15, N'EpkCorrections', N'Изпълнение на препоръки от ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (93, 15, N'EpkCorrectionsCheck', N'Проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (94, 15, N'AcquisitionContract', N'Изготвяне на договор за продобиване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (95, 15, N'DirectorApproval', N'Утвърждаване от директор')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (96, 15, N'Registration', N'Регистриране')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (97, 11, N'UndoChanges', N'Отменяне на промените')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (98, 13, N'EditData', N'Редакция на данни')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (99, 13, N'UndoChanges', N'Отменяне на промените')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (100, 13, N'CreateReport', N'Изготвяне на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (101, 13, N'SendReport', N'Изпращане на доклад за заседание')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (102, 13, N'AddReportToSessionAgenda', N'Добавяне на доклад в дневен ред на заседание')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (103, 12, N'EditData', N'Редакция на данни')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (104, 12, N'UndoChanges', N'Отменяне на промените')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (105, 13, N'ProcessFinalization', N'Завършване на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (106, 12, N'CreateReport', N'Изготвяне на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (107, 12, N'SendReport', N'Изпращане на доклад за заседание')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (108, 12, N'AddReportToSessionAgenda', N'Добавяне на доклад в дневен ред на заседание')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (109, 12, N'ProcessFinalization', N'Завършване на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (110, 10, N'ProcessFinalization', N'Завършване на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (111, 13, N'AddSessionAgendaStandpoint', N'Изготвяне на становище по дневен ред')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (112, 13, N'AddSessionAgendaStandpointComment', N'Въвеждане на коментар по становище')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (113, 12, N'AddSessionAgendaStandpoint', N'Изготвяне на становище по дневен ред')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (114, 12, N'AddSessionAgendaStandpointComment', N'Въвеждане на коментар по становище')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (115, 13, N'SendToAddSessionAgendaStandpoint', N'Изпращане за становище по дневен ред')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (116, 13, N'SendToAddSessionAgendaStandpointComment', N'Изпращане за коментар по становище')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (117, 12, N'SendToAddSessionAgendaStandpoint', N'Изпращане за становище по дневен ред')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (118, 12, N'SendToAddSessionAgendaStandpointComment', N'Изпращане за коментар по становище')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (119, 13, N'SendSessionAgendaStandpointComment', N'Изпращане на коментари по становища')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (120, 12, N'SendSessionAgendaStandpointComment', N'Изпращане на коментари по становища')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (121, 13, N'CommissionSession', N'Заседание на комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (122, 12, N'CommissionSession', N'Заседание на комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (123, 13, N'SessionMinutesOfMeeting', N'Утвърден протокол от заседание на комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (124, 13, N'ReportApproval', N'Одобрение на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (125, 13, N'ReportChangesRequired', N'Връщане за корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (126, 13, N'ReportRejection', N'Отхвърляне на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (127, 13, N'ReportModifications', N'Изпълнение на препоръки от комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (128, 13, N'SendForAffirmation', N'Изпращане за утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (129, 13, N'Affirmation', N'Утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (130, 12, N'SessionMinutesOfMeeting', N'Утвърден протокол от заседание на комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (131, 12, N'ReportApproval', N'Одобрение на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (132, 12, N'ReportChangesRequired', N'Връщане за корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (133, 12, N'ReportRejection', N'Отхвърляне на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (134, 12, N'ReportModifications', N'Изпълнение на препоръки от комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (135, 12, N'SendForAffirmation', N'Изпращане за утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (136, 12, N'Affirmation', N'Утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (137, 13, N'SendForModificationsRevision', N'Изпращане за проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (138, 13, N'ModificationsRevision', N'Проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (139, 12, N'SendForModificationsRevision', N'Изпращане за проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (140, 12, N'ModificationsRevision', N'Проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (141, 17, N'ChooseRawInventories', N'Избор на груби описи за обработка')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (142, 18, N'ProcessInitiation', N'Иницииране на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (143, 18, N'ProcessFinalization', N'Завършване на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (144, 18, N'UndoChanges', N'Отменяне на промените')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (145, 18, N'SuspendPublicAccess', N'Прекратяване на публичен достъп')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (146, 18, N'EditData', N'Редакция на данни')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (147, 18, N'RequestPublicAccessSuspension', N'Заявка за спиране на достъп')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (148, 17, N'UndoChanges', N'Отмяна на промените')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (149, 17, N'CreateInventories', N'Създаване на инвентарни описи')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (150, 10, N'Confirmation protocol sent', N'Изпратен протокол за утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (151, 10, N'Confirmed protocol', N'Утвърден протокол')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (152, 12, N'SessionMinutesOfMeetingForApproval', N'Протокол от заседание на комисия за утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (154, 13, N'SessionMinutesOfMeetingForApproval', N'Протокол от заседание на комисия за утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (156, 15, N'Confirmation protocol sent', N'Изпратен протокол за Утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (157, 15, N'Confirmed protocol', N'Утвърден протокол')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (158, 2, N'Confirmation protocol sent', N'Изпратен протокол за Утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (159, 2, N'Confirmed protocol', N'Утвърден протокол')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (160, 14, N'Confirmation protocol sent', N'Изпратен протокол за Утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (161, 14, N'Confirmed protocol', N'Утвърден протокол')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (162, 16, N'Confirmation protocol sent', N'Изпратен протокол за Утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (163, 16, N'Confirmed protocol', N'Утвърден протокол')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (164, 1, N'Confirmation protocol sent', N'Изпратен протокол за Утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (165, 1, N'Confirmed protocol', N'Утвърден протокол')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (166, 17, N'Confirmation protocol sent', N'Изпратен протокол за Утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (167, 17, N'Confirmed protocol', N'Утвърден протокол')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (168, 17, N'CreateReport', N'Изготвяне на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (169, 17, N'ProcessInitialize', N'Инициализиране на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (170, 17, N'ProcessFinalization', N'Завършване на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (171, 17, N'SendReport', N'Изпращане на доклад за заседание')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (172, 17, N'AddReportToSessionAgenda', N'Добавяне на доклад в дневен ред на заседание')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (173, 17, N'AddSessionAgendaStandpoint', N'Изготвяне на становище по дневен ред')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (174, 17, N'SendToAddSessionAgendaStandpoint', N'Изпращане за становище по дневен ред')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (175, 17, N'SendToAddSessionAgendaStandpointComment', N'Изпращане за коментар по становище')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (176, 17, N'AddSessionAgendaStandpointComment', N'Въвеждане на коментар по становище')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (177, 17, N'SendSessionAgendaStandpointComment', N'Изпращане на коментари по становища')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (178, 17, N'CommissionSession', N'Заседание на комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (179, 17, N'ReportApproval', N'Одобрение на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (180, 17, N'ReportChangesRequired', N'Връщане за корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (181, 17, N'ReportRejection', N'Отхвърляне на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (182, 17, N'ReportModifications', N'Изпълнение на препоръки от комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (183, 17, N'SendForModificationsRevision', N'Изпращане за проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (184, 17, N'ModificationsRevision', N'Проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (185, 17, N'SendForAffirmation', N'Изпращане за утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (186, 17, N'Affirmation', N'Утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (187, 19, N'ProcessInitialize', N'Инициализиране на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (188, 19, N'ProcessFinalization', N'Завършване на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (189, 19, N'UndoChanges', N'Отмяна на промените')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (190, 19, N'ChooseRawInventories', N'Избор на груби описи за обработка')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (191, 19, N'CreateInventories', N'Създаване на инвентарни описи')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (192, 19, N'CreateReport', N'Изготвяне на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (193, 19, N'SendReport', N'Изпращане на доклад за заседание')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (194, 19, N'AddReportToSessionAgenda', N'Добавяне на доклад в дневен ред на заседание')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (195, 19, N'AddSessionAgendaStandpoint', N'Изготвяне на становище по дневен ред')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (196, 19, N'SendToAddSessionAgendaStandpoint', N'Изпращане за становище по дневен ред')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (197, 19, N'SendToAddSessionAgendaStandpointComment', N'Изпращане за коментар по становище')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (198, 19, N'AddSessionAgendaStandpointComment', N'Въвеждане на коментар по становище')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (199, 19, N'SendSessionAgendaStandpointComment', N'Изпращане на коментари по становища')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (200, 19, N'CommissionSession', N'Заседание на комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (201, 19, N'ReportApproval', N'Одобрение на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (202, 19, N'ReportChangesRequired', N'Връщане за корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (203, 19, N'ReportRejection', N'Отхвърляне на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (204, 19, N'ReportModifications', N'Изпълнение на препоръки от комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (205, 19, N'SendForModificationsRevision', N'Изпращане за проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (206, 19, N'ModificationsRevision', N'Проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (207, 19, N'SendForAffirmation', N'Изпращане за утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (208, 19, N'Affirmation', N'Утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (209, 19, N'SendToRegistrar', N'Насочване към регистратор')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (210, 19, N'RegisterInventories', N'Регистриране на инвентарни описи')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (211, 17, N'SendToRegistrar', N'Насочване към регистратор')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (212, 17, N'RegisterInventories', N'Регистриране на инвентарни описи')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (213, 18, N'SessionMinutesOfMeetingForApproval', N'Протокол от заседание на комисия за утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (214, 18, N'SessionMinutesOfMeeting', N'Утвърден протокол от заседание на комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (215, 18, N'CreateReport', N'Изготвяне на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (216, 18, N'SendReport', N'Изпращане на доклад за заседание')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (217, 18, N'AddReportToSessionAgenda', N'Добавяне на доклад в дневен ред на заседание')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (218, 18, N'AddSessionAgendaStandpoint', N'Изготвяне на становище по дневен ред')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (219, 18, N'AddSessionAgendaStandpointComment', N'Въвеждане на коментар по становище')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (220, 18, N'SendToAddSessionAgendaStandpoint', N'Изпращане за становище по дневен ред')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (221, 18, N'SendToAddSessionAgendaStandpointComment', N'Изпращане за коментар по становище')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (222, 18, N'SendSessionAgendaStandpointComment', N'Изпращане на коментари по становища')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (223, 18, N'CommissionSession', N'Заседание на комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (224, 18, N'ReportApproval', N'Одобрение на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (225, 18, N'ReportChangesRequired', N'Връщане за корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (226, 18, N'ReportRejection', N'Отхвърляне на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (227, 18, N'ReportModifications', N'Изпълнение на препоръки от комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (228, 18, N'SendForAffirmation', N'Изпращане за утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (229, 18, N'Affirmation', N'Утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (230, 18, N'SendForModificationsRevision', N'Изпращане за проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (231, 18, N'ModificationsRevision', N'Проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (232, 18, N'SendForRegistration', N'Изпращане за регистрация')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (233, 18, N'Registration', N'Регистриране')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (234, 19, N'Confirmation protocol sent', N'Протокол от заседание на комисия за утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (235, 19, N'Confirmed protocol', N'Утвърден протокол от заседание на комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (236, 18, N'ChangesRequired', N'Връщане за корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (237, 12, N'ChangesRequired', N'Връщане за корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (238, 13, N'ChangesRequired', N'Връщане за корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (239, 18, N'DataModifications', N'Извършване на корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (240, 12, N'DataModifications', N'Извършване на корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (241, 13, N'DataModifications', N'Извършване на корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (242, 17, N'DataModifications', N'Извършване на корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (243, 19, N'DataModifications', N'Извършване на корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (244, 17, N'ChangesRequired', N'Връщане за корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (245, 19, N'ChangesRequired', N'Връщане за корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1000, NULL, N'ProcessInitialization', N'Инициализиране на процес')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1001, NULL, N'AddPackages', N'Добавяне на пакети А и Б')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1002, NULL, N'CommissionReport', N'Изготвяне на доклад към комисия')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1003, NULL, N'CommissionReportEdit', N'Промяна на доклад')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1004, NULL, N'PackagesEdit', N'Промяна на пакети А и Б')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1005, NULL, N'CommissionReviewDate', N'Определяне на дата за разглеждане на Доклад за ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1006, NULL, N'CommissionOpinions', N'Въвеждане на становища от членове на ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1007, NULL, N'CommissionDecision', N'Решение след заседание на ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1008, NULL, N'ConfirmationProtocolSent', N'Изпратен протокол за Утвърждаване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1009, NULL, N'ConfirmedProtocol', N'Утвърден протокол')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1010, NULL, N'CommissionCorrections', N'Изпълнение на препоръки от ЕПК/ЕОК/РЕОК')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1011, NULL, N'PackagesEdit', N'Промяна на пакети А и Б')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1012, NULL, N'CommissionCorrectionsCheck', N'Проверка на извършените корекции')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1013, NULL, N'AcquisitionContract', N'Изготвяне на договор за продобиване')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1014, NULL, N'Registration', N'Регистриране')
GO
INSERT [N].[ProcessSteps] ([Id], [ProcessTypeId], [Code], [Text]) VALUES (1015, NULL, N'EndProcess', N'Приключен процес')
GO
SET IDENTITY_INSERT [dbo].[TaskTemplates] ON 
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (1, 3, N'Съгласуване на регистрирано копие от чужди архиви', N'<p>Възложена Ви е нова задача по съгласуване на регистрирано копие от чужди архиви с инвентарен номер #filmInventoryNumber# и КМФ номер #filmNumber#:</p>#filmDisplayUrl#', N'#filmDisplayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (2, 20, N'Преглед на метаданните и избор на сканиращ', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (3, 22, N'Преглед на метаданните след редакция', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (4, 9, N'Съгласуване на научно-техническа обработка на постъпление към КМФ', N'<p>Възложена Ви е нова задача по съгласуване на научно-техническа обработка на постъпление към КМФ с инвентарен номер #filmInventoryNumber# и КМФ номер #filmNumber#:</p>#filmDisplayUrl#', N'#filmDisplayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (5, 15, N'Съгласуване на редактирани данни на КМФ', N'<p>Възложена Ви е нова задача по съгласуване на редактирани данни на КМФ с инвентарен номер #filmInventoryNumber# и КМФ номер #filmNumber#:</p>#filmDisplayUrl#', N'#filmDisplayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (6, 21, N'Върнато за редакция на метаданните', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (7, 26, N'Преглед на метаданните и избор на сканиращ', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (8, 23, N'Преглед и одобрение на дигитални обекти', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (9, 24, N'Върнато за редакция на дигитални обекти', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (10, 101, N'Доклад за ЕПК', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (11, 107, N'Доклад за ЕПК', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (12, 32, N'Определяне на дата за разглеждане на доклад за ЕПК', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (13, 33, N'Въвеждане на становище от членове на ЕПК', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (14, 34, N'Решение след заседание на ЕПК', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (15, 35, N'Изпълнение на препоръки от ЕПК', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (16, 36, N'Проверка на извършените корекции', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (17, 37, N'Утвърждаване от Директор', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (18, 38, N'Съгласуване за искане на корекции', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (20, 115, N'Изготвяне на становище по точка от дневен ред', N'<p>Възложена Ви е задача за изготвяне на становище по точка от дневен ред на заседание на дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (22, 117, N'Изготвяне на становище по точка от дневен ред', N'<p>Възложена Ви е задача за изготвяне на становище по точка от дневен ред на заседание на дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (26, 119, N'Коментари по становища', N'<p>Въведени са коментари по Ваше становище по точка от дневен ред на заседание на дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (27, 120, N'Коментари по становища', N'<p>Въведени са коментари по Ваше становище по точка от дневен ред на заседание на дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (28, 116, N'Коментар по становище по точка от дневен ред', N'<p>Възложена Ви е задача за коментар по становище по точка от дневен ред на заседание на дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (29, 118, N'Коментар по становище по точка от дневен ред', N'<p>Възложена Ви е задача за коментар по становище по точка от дневен ред на заседание на дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (30, 121, N'Доклад е добавен към дневен ред на заседание', N'<p>Доклад #reportNumber# е добавен към дневен ред на заседание на дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (31, 122, N'Доклад е добавен към дневен ред на заседание', N'<p>Доклад #reportNumber# е добавен към дневен ред на заседание на дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (32, 124, N'Одобрение на доклад', N'<p>Взето е решение на комисия за одобрение на доклад № #reportNumber# по точка от дневен ред на заседание ot дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (33, 125, N'Връщане за корекции', N'<p>Взето е решение на комисия за връщане за корекции на доклад № #reportNumber# по точка от дневен ред на заседание ot дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (34, 126, N'Отхвърляне на доклад', N'<p>Взето е решение на комисия за отхвърляне на доклад № #reportNumber# по точка от дневен ред на заседание ot дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (35, 131, N'Одобрение на доклад', N'<p>Взето е решение на комисия за одобрение на доклад № #reportNumber# по точка от дневен ред на заседание ot дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (36, 132, N'Връщане за корекции', N'<p>Взето е решение на комисия за връщане за корекции на доклад № #reportNumber# по точка от дневен ред на заседание ot дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (37, 133, N'Отхвърляне на доклад', N'<p>Взето е решение на комисия за отхвърляне на доклад № #reportNumber# по точка от дневен ред на заседание ot дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (38, 137, N'Проверка на корекции', N'<p>Възложена Ви е задача за проверка на корекции</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (39, 139, N'Проверка на корекции', N'<p>Възложена Ви е задача за проверка на корекции</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (40, 128, N'Утвърждаване на промени', N'<p>Възложена Ви е задача за утвърждаване на промени</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (41, 135, N'Утвърждаване на промени', N'<p>Възложена Ви е задача за утвърждаване на промени</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (42, 129, N'Утвърждаване на промени', N'<p>Утвърдени са промени</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (43, 136, N'Утвърждаване на промени', N'<p>Утвърдени са промени</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (44, 147, N'Заявка за спиране на публичен достъп', N'<p>Направена е заявка за спиране на публичен достъп.</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (45, 145, N'Спрян публичен достъп', N'<p>На базата на Ваша заявка е спрян публичния достъп до фонд #number# #title# (#approximateScope#).</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (51, 150, N'Изпратен протокол за утвърждаване', N'<p>Възложена Ви е нова задача.</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (52, 151, N'Утвърден протокол', N'<p>Възложена Ви е нова задача.</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (53, NULL, N'Връщане за корекции', N'<p>Взето е решение на комисия за връщане за корекции на доклад № #reportNumber# по точка от дневен ред на заседание oт дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (54, NULL, N'Въвеждане на становище от членове на ЕПК', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (55, NULL, N'Върнато за редакция на дигитални обекти', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (56, NULL, N'Върнато за редакция на метаданните', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (57, NULL, N'Доклад е добавен към дневен ред на заседание', N'<p>Доклад #reportNumber# е добавен към дневен ред на заседание на дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (58, NULL, N'Доклад за ЕПК', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (59, NULL, N'Заявка за спиране на публичен достъп', N'<p>Направена е заявка за спиране на публичен достъп.</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (60, NULL, N'Изготвяне на становище по точка от дневен ред', N'<p>Възложена Ви е задача за изготвяне на становище по точка от дневен ред на заседание на дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (61, NULL, N'Изпратен протокол за утвърждаване', N'<p>Възложена Ви е нова задача.</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (62, NULL, N'Изпълнение на препоръки от ЕПК', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (63, NULL, N'Коментар по становище по точка от дневен ред', N'<p>Възложена Ви е задача за коментар по становище по точка от дневен ред на заседание на дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (64, NULL, N'Коментари по становища', N'<p>Въведени са коментари по Ваше становище по точка от дневен ред на заседание на дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (65, NULL, N'Одобрение на доклад', N'<p>Взето е решение на комисия за одобрение на доклад № #reportNumber# по точка от дневен ред на заседание ot дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (66, NULL, N'Определяне на дата за разглеждане на доклад за ЕПК', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (67, NULL, N'Отхвърляне на доклад', N'<p>Взето е решение на комисия за отхвърляне на доклад № #reportNumber# по точка от дневен ред на заседание ot дата #sessionDate#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (68, NULL, N'Преглед и одобрение на дигитални обекти', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (69, NULL, N'Преглед на метаданните и избор на сканиращ', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (70, NULL, N'Преглед на метаданните след редакция', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (71, NULL, N'Проверка на извършените корекции', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (72, NULL, N'Проверка на корекции', N'<p>Възложена Ви е задача за проверка на корекции</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (73, NULL, N'Решение след заседание на ЕПК', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (74, NULL, N'Спрян публичен достъп', N'<p>На базата на Ваша заявка е спрян публичния достъп до фонд #number# #title# (#approximateScope#).</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (75, NULL, N'Съгласуване за искане на корекции', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (76, NULL, N'Съгласуване на научно-техническа обработка на постъпление към КМФ', N'<p>Възложена Ви е нова задача по съгласуване на научно-техническа обработка на постъпление към КМФ с инвентарен номер #filmInventoryNumber# и КМФ номер #filmNumber#:</p>#filmDisplayUrl#', N'#filmDisplayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (77, NULL, N'Съгласуване на регистрирано копие от чужди архиви', N'<p>Възложена Ви е нова задача по съгласуване на регистрирано копие от чужди архиви с инвентарен номер #filmInventoryNumber# и КМФ номер #filmNumber#:</p>#filmDisplayUrl#', N'#filmDisplayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (78, NULL, N'Съгласуване на редактирани данни на КМФ', N'<p>Възложена Ви е нова задача по съгласуване на редактирани данни на КМФ с инвентарен номер #filmInventoryNumber# и КМФ номер #filmNumber#:</p>#filmDisplayUrl#', N'#filmDisplayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (79, NULL, N'Утвърден протокол', N'<p>Възложена Ви е нова задача.</p>#displayUrl#
', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (80, NULL, N'Утвърждаване на промени', N'<p>Възложена Ви е задача за утвърждаване на промени</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (81, NULL, N'Утвърждаване на промени', N'<p>Утвърдени са промени</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (82, NULL, N'Утвърждаване от Директор', N'<p>Възложена Ви е нова задача </p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (83, NULL, N'TEST', N'<p>Test NEW description</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (84, NULL, N'Насочване към регистратор ', N'<p>Възложена Ви е задача по регистриране на инвентарни описи. 
#displayUrl#</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (85, NULL, N'Регистриране', N'<p>Възложена ви е задача за регистриране
#displayUrl#</p>#displayUrl#', N'')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (86, NULL, N'Изискани са корекции', N'<p>Изискани са корекции в доклада или съдържанието
#displayUrl#
#processStepComment#</p>', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (87, NULL, N'Desi_Test01', N'<p>Test</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (88, NULL, N'Desi_Test02', N'<p>Test</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (89, NULL, N'Desi_test03', N'<p>Test</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (90, NULL, N'Desi_Test04', N'<p>Test</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (91, NULL, N'Desi_Test05', N'<p>Test</p>#displayUrl#', N'#displayUrl#')
GO
INSERT [dbo].[TaskTemplates] ([Id], [ProcessStepTypeId], [Title], [Description], [RelatedContentUrl]) VALUES (92, NULL, N'Desi_Test06', N'<p>Test</p>', N'#displayUrl#')
GO
SET IDENTITY_INSERT [dbo].[TaskTemplates] OFF
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (53, 125)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (53, 132)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (53, 225)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (54, 33)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (55, 24)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (56, 21)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (57, 121)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (57, 122)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (57, 178)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (57, 200)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (57, 223)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (58, 101)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (58, 107)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (58, 171)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (58, 193)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (58, 216)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (59, 147)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (60, 115)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (60, 117)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (60, 174)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (60, 196)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (60, 220)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (61, 150)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (61, 166)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (61, 234)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (62, 35)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (63, 116)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (63, 118)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (63, 175)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (63, 197)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (63, 221)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (64, 119)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (64, 120)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (64, 177)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (64, 199)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (64, 222)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (65, 124)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (65, 131)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (65, 179)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (65, 201)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (65, 224)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (66, 32)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (67, 126)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (67, 133)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (67, 181)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (67, 203)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (67, 226)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (68, 23)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (69, 20)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (69, 26)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (70, 22)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (71, 36)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (72, 137)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (72, 139)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (72, 183)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (72, 205)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (72, 230)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (73, 34)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (74, 145)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (75, 38)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (76, 9)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (77, 3)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (78, 15)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (79, 151)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (79, 167)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (79, 235)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (80, 128)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (80, 135)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (80, 185)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (80, 207)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (80, 228)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (81, 129)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (81, 136)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (81, 186)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (81, 208)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (82, 37)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (83, 125)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (84, 209)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (84, 211)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (85, 232)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (86, 180)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (86, 202)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (86, 225)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (86, 237)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (86, 238)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (86, 244)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (86, 245)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (87, 1006)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (88, 1006)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (89, 1001)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (90, 1013)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (91, 1013)
GO
INSERT [dbo].[TaskTemplatesSteps] ([TaskTemplate_Id], [ProcessStep_Id]) VALUES (92, 1006)
GO
INSERT [N].[NotificationType] ([Code], [Text]) VALUES (N'CancelledTask', N'Отменена задача')
GO
INSERT [N].[NotificationType] ([Code], [Text]) VALUES (N'CompletedTask', N'Завършена задача')
GO
INSERT [N].[NotificationType] ([Code], [Text]) VALUES (N'NewTask', N'Нова задача')
GO
SET IDENTITY_INSERT [Notification].[NotificationTemplate] ON 
GO
INSERT [Notification].[NotificationTemplate] ([Id], [NotificationTypeCode], [Subject], [Body]) VALUES (1, N'NewTask', N'Нова задача', N'<p>Има нова задача, насочена към Вас: </p>#taskUrl#')
GO
INSERT [Notification].[NotificationTemplate] ([Id], [NotificationTypeCode], [Subject], [Body]) VALUES (2, N'CompletedTask', N'Завършена задача', N'<p>Завършена е задача, която сте назначили: </p>#taskUrl#')
GO
INSERT [Notification].[NotificationTemplate] ([Id], [NotificationTypeCode], [Subject], [Body]) VALUES (3, N'CancelledTask', N'Отменена задача', N'<p>Отменена е задача, насочена към Вас: </p>#taskUrl#')
GO
SET IDENTITY_INSERT [Notification].[NotificationTemplate] OFF
GO
INSERT [N].[ArchivalEntityDescriptionLevel] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'1', N'Архивна единица', N'', 1, NULL, 0, NULL)
GO
INSERT [N].[ArchivalEntityDescriptionLevel] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'2', N'Служебна архивна единица', N'', 2, NULL, 0, NULL)
GO
INSERT [N].[AvailabilityStatus] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (1, N'Зачисляване', NULL, 1, NULL, 0, NULL)
GO
INSERT [N].[AvailabilityStatus] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (2, N'Отчисляване за унищожаване', NULL, 2, NULL, 0, NULL)
GO
INSERT [N].[AvailabilityStatus] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (3, N'Отчисляване за преместване', NULL, 3, NULL, 0, NULL)
GO
SET IDENTITY_INSERT [N].[DocsCollectingProcedureSteps] ON 
GO
INSERT [N].[DocsCollectingProcedureSteps] ([Id], [Title], [Sort], [ResponsibleUserType]) VALUES (1, N'Подготвяне на пакети', N'10        ', N'B,D')
GO
INSERT [N].[DocsCollectingProcedureSteps] ([Id], [Title], [Sort], [ResponsibleUserType]) VALUES (3, N'Одобрение от секретар/председател на комисия', N'20        ', N'V1')
GO
INSERT [N].[DocsCollectingProcedureSteps] ([Id], [Title], [Sort], [ResponsibleUserType]) VALUES (7, N'Заседание на комисия', N'30        ', N'V1')
GO
INSERT [N].[DocsCollectingProcedureSteps] ([Id], [Title], [Sort], [ResponsibleUserType]) VALUES (8, N'Утвърждаване на пакетите', N'40        ', N'G')
GO
INSERT [N].[DocsCollectingProcedureSteps] ([Id], [Title], [Sort], [ResponsibleUserType]) VALUES (9, N'Регистриране на пакетите', N'50        ', N'А')
GO
SET IDENTITY_INSERT [N].[DocsCollectingProcedureSteps] OFF
GO
SET IDENTITY_INSERT [N].[DocsCollectingProcedureTypes] ON 
GO
INSERT [N].[DocsCollectingProcedureTypes] ([Id], [Name]) VALUES (1, N'Комплектуване на ценни електронни документи')
GO
INSERT [N].[DocsCollectingProcedureTypes] ([Id], [Name]) VALUES (2, N'Комплектуване на ценни електронни документи от личен произход/Частично постъпление/Спомен/Учрежденски необработен (вътрешен)')
GO
INSERT [N].[DocsCollectingProcedureTypes] ([Id], [Name]) VALUES (3, N'Комплектуване на ценни електронни документи от личен произход/Частично постъпление/ Спомен/Учрежденски необработен (външен)')
GO
SET IDENTITY_INSERT [N].[DocsCollectingProcedureTypes] OFF
GO
INSERT [N].[DocumentDescriptionLevel] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'1', N'Документ', N'', 1, NULL, 0, NULL)
GO
SET IDENTITY_INSERT [N].[EDocsCollectingApplicationStatuses] ON 
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (1, N'Нов', N'New')
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (2, N'Одобрен', N'Approved')
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (3, N'Отказан', N'Rejected')
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (4, N'Добавяне на пакети', N'Add packages')
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (5, N'Редакция на пакети', N'Packges update')
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (6, N'Отказ от комисия', N'Rejected by committee')
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (7, N'Одобрен от комисия', N'Approved by committee')
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (8, N'Изчаква комисия', N'Awaiting committee')
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (9, N'Редакция по решение на комисия', N'Update by decision of the commission')
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (10, N'Регистрация в архив', N'Archive registry')
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (11, N'Завършена регистрация', N'Registration completed')
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (12, N'Одобрение на пакети', N'Packages approval')
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (13, N'Отказано от комисия', N'Rejected by commission')
GO
INSERT [N].[EDocsCollectingApplicationStatuses] ([Id], [Text], [TextEn]) VALUES (14, N'Договор за придобиване', N'Acquisition contract')
GO
SET IDENTITY_INSERT [N].[EDocsCollectingApplicationStatuses] OFF
GO
INSERT [N].[EDocsCollectingApplicationTypes] ([Code], [Text], [TextEn]) VALUES (N'assembled', N'Заявление за обработени документи', N'Заявление за обработени документи')
GO
INSERT [N].[EDocsCollectingApplicationTypes] ([Code], [Text], [TextEn]) VALUES (N'raw', N'Заявление за необработени документи', N'Заявление за необработени документи')
GO
INSERT [N].[FilmDocumentType] ([Id], [Code], [Text], [PackageType], [IsRequired]) VALUES (1, N'Declaration', N'Декларация', N'A', 0)
GO
INSERT [N].[FilmDocumentType] ([Id], [Code], [Text], [PackageType], [IsRequired]) VALUES (2, N'Protocol', N'Приемо-предавателен протокол', N'A', 0)
GO
INSERT [N].[FilmDocumentType] ([Id], [Code], [Text], [PackageType], [IsRequired]) VALUES (3, N'Other', N'Друго', N'A', 0)
GO
INSERT [N].[FilmDocumentType] ([Id], [Code], [Text], [PackageType], [IsRequired]) VALUES (4, N'FilmFile', N'КМФ Файл', N'B', 1)
GO
INSERT [N].[FundArray] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'', N'Без индекс', NULL, 6, NULL, 0, NULL)
GO
INSERT [N].[FundArray] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'А', N'А', NULL, 1, NULL, 0, NULL)
GO
INSERT [N].[FundArray] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'Б', N'Б', NULL, 2, NULL, 0, NULL)
GO
INSERT [N].[FundArray] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'В', N'В', NULL, 3, NULL, 0, NULL)
GO
INSERT [N].[FundArray] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'К', N'К', NULL, 4, NULL, 0, NULL)
GO
INSERT [N].[FundDescriptionLevel] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'1', N'Фонд', N'', 1, NULL, 0, NULL)
GO
INSERT [N].[FundDescriptionLevel] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'2', N'Фонд с необработени документи', N'', 2, NULL, 0, NULL)
GO
INSERT [N].[FundDescriptionLevel] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'3', N'Спомен', N'', 3, NULL, 0, NULL)
GO
INSERT [N].[FundDescriptionLevel] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'4', N'ЧП', N'', 4, NULL, 0, NULL)
GO
INSERT [N].[FundType] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'1', N'Групов', N'', 1, NULL, 0, NULL)
GO
INSERT [N].[FundType] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'2', N'Колекция', N'', 2, NULL, 0, NULL)
GO
INSERT [N].[FundType] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'3', N'Личен произход', N'', 3, NULL, 0, NULL)
GO
INSERT [N].[FundType] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'4', N'Родов', N'', 4, NULL, 0, NULL)
GO
INSERT [N].[FundType] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'5', N'Семеен', N'', 5, NULL, 0, NULL)
GO
INSERT [N].[FundType] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'6', N'Учрежденски', N'', 6, NULL, 0, NULL)
GO
INSERT [N].[InventoryArray] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'', N'Без индекс', NULL, 1, NULL, 0, NULL)
GO
INSERT [N].[InventoryArray] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'Г', N'Г', NULL, 7, NULL, 0, NULL)
GO
INSERT [N].[InventoryArray] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'К', N'К', NULL, 4, NULL, 0, NULL)
GO
INSERT [N].[InventoryArray] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'Н', N'Н', NULL, 6, NULL, 0, NULL)
GO
INSERT [N].[InventoryArray] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'П', N'П', NULL, 2, NULL, 0, NULL)
GO
INSERT [N].[InventoryArray] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'С', N'С', NULL, 5, NULL, 0, NULL)
GO
INSERT [N].[InventoryArray] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'Т', N'Т', NULL, 3, NULL, 0, NULL)
GO
INSERT [N].[InventoryDescriptionLevel] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'12', N'Служебен опис', NULL, 3, NULL, 0, NULL)
GO
INSERT [N].[InventoryDescriptionLevel] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'5', N'Инвентарен опис', NULL, 2, NULL, 0, NULL)
GO
INSERT [N].[InventoryDescriptionLevel] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'6', N'Груб опис', NULL, 1, NULL, 0, NULL)
GO
INSERT [N].[NomenclatureCode] ([Code], [Text], [Description], [SortOrder]) VALUES (N'ACQUISITION_METHOD', N'Начин на придобиване', N'', NULL)
GO
INSERT [N].[NomenclatureCode] ([Code], [Text], [Description], [SortOrder]) VALUES (N'COPY_TYPE', N'Вид на копията', NULL, NULL)
GO
INSERT [N].[NomenclatureCode] ([Code], [Text], [Description], [SortOrder]) VALUES (N'CREATION_METHOD', N'Начин на създаване', N'', NULL)
GO
INSERT [N].[NomenclatureCode] ([Code], [Text], [Description], [SortOrder]) VALUES (N'FILE_TYPE', N'Файлов формат', N'', NULL)
GO
INSERT [N].[NomenclatureCode] ([Code], [Text], [Description], [SortOrder]) VALUES (N'FILM_COUNTRY', N'Държава', NULL, NULL)
GO
INSERT [N].[NomenclatureCode] ([Code], [Text], [Description], [SortOrder]) VALUES (N'FILMING_EXTENT', N'Степен на заснемане', NULL, NULL)
GO
INSERT [N].[NomenclatureCode] ([Code], [Text], [Description], [SortOrder]) VALUES (N'INDUSTRY_TYPE', N'Индекс от отраслова схема', N'', NULL)
GO
INSERT [N].[NomenclatureCode] ([Code], [Text], [Description], [SortOrder]) VALUES (N'LANGUAGE', N'Език', N'', NULL)
GO
INSERT [N].[NomenclatureCode] ([Code], [Text], [Description], [SortOrder]) VALUES (N'ORIGINALITY', N'Оригиналност', N'', NULL)
GO
INSERT [N].[ReportResultType] ([Code], [Text]) VALUES (N'1', N'Резултати (СЕА и ИСДА)')
GO
INSERT [N].[ReportResultType] ([Code], [Text]) VALUES (N'2', N'Резултати (ИСДА)')
GO
INSERT [N].[ReportResultType] ([Code], [Text]) VALUES (N'3', N'Резултати (СЕА)')
GO
INSERT [N].[SessionTypes] ([Code], [Text]) VALUES (N'1', N'ЕПК')
GO
INSERT [N].[SessionTypes] ([Code], [Text]) VALUES (N'2', N'ЕОК')
GO
INSERT [N].[SessionTypes] ([Code], [Text]) VALUES (N'3', N'РЕОК')
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'1', N'Нов', NULL, 1, NULL, 0, NULL)
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'10', N'Необработен', NULL, 10, NULL, 0, NULL)
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'11', N'Променено наименование', NULL, 11, NULL, 0, NULL)
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'12', N'Отчислен', NULL, 12, NULL, 0, NULL)
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'13', N'Обработен', NULL, 13, NULL, 0, NULL)
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'14', N'Преместен', NULL, 14, NULL, 0, NULL)
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'2', N'Регистриран', NULL, 2, NULL, 0, NULL)
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'3', N'Усъвършенстван', NULL, 3, NULL, 0, NULL)
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'4', N'Заличен', NULL, 4, NULL, 0, NULL)
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'5', N'Възстановен', NULL, 5, NULL, 0, NULL)
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'6', N'Пререгистриран', NULL, 6, NULL, 0, NULL)
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'7', N'Редактиран', NULL, 7, NULL, 0, NULL)
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'8', N'Пресъставен', NULL, 8, NULL, 0, NULL)
GO
INSERT [N].[Status] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource], [ExternalSourceUpdatedOn]) VALUES (N'9', N'Пресъздаден', NULL, 9, NULL, 0, NULL)
GO
INSERT [N].[TaskStatus] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource]) VALUES (N'Cancelled', N'Отменена', N'Отменена задача', 3, NULL, 0)
GO
INSERT [N].[TaskStatus] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource]) VALUES (N'Complete', N'Завършена', N'Завършена задача', 2, 2178, 0)
GO
INSERT [N].[TaskStatus] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource]) VALUES (N'NotStarted', N'Нестартирана', N'Нестартирана задача', 4, 2176, 0)
GO
INSERT [N].[TaskStatus] ([Code], [Text], [Description], [SortOrder], [ExternalIdentifier], [HasExternalSource]) VALUES (N'Pending', N'Нова', N'Нова задача', 1, 2177, 0)
GO


commit
--rollback