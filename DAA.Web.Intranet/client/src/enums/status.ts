export enum Status {
    New = "1", //Нов
    Registered ="2", //Регистриран
    Refined =  "3", //Усъвършенстван
    Deleted = "4",	//Заличен
    Restored ="5",	//Възстановен
    Reregistered = "6",	//Пререгистриран
    Modified = "7",	//Редактиран
    Rebuilt = "8",	//Пресъставен
    Recreated = "9",	//Пресъздаден
    Raw = "10",	//Необработен
    NameChanged = "11", //Променено наименование
    Deducted = "12", //Отчислен
    Processed = "13", //Обработен
    Moved = "14", //Преместен
}

export enum StatusText {
    New = "Нов", //1
    Raw = "Необработен",	//10
    NameChanged = "Променено наименование", //11
    Deducted = "Отчислен", //12
    Processed = "Обработен", //13
    Moved = "Преместен", //14
    Registered ="Регистриран", //2
    Refined =  "Усъвършенстван", //3
    Deleted = "Заличен",	//4
    Restored ="Възстановен",	//5
    Reregistered = "Пререгистриран",	//6
    Modified = "Редактиран",	//7
    Rebuilt = "Пресъставен",	//8
    Recreated = "Пресъздаден"	//9
}

export enum AvailabilityStatus {
    Enrollment = 1,
    DisposalDeduction = 2,
    RelocationDeduction = 3,
}

export enum ApprovalStatus {
    Approved = 1,
    Affirmed  = 2,
    Rejected = 3,
}