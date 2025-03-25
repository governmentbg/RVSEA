import applications from './applications.bg';
import archivalEntity from './archivalEntity.bg';
import common from './common.bg';
import deduction from './deductionProcess.bg';
import digitalObjectBg from './digitalObject.bg';
import docsCreateProc from './docsCreatingProcess.bg';
import document from './document.bg';
import eDocsCollection from './eDocsCollection.bg';
import epkReport from './epk.bg';
import epkProtocol from './epkProtocol.bg';
import errorBg from './error.bg';
import files from './files.bg';
import filmCards from './filmCards.bg';
import filmDocuments from './filmDocuments.bg';
import filmReviews from './filmReviews.bg';
import films from './films.bg';
import footerBg from './footer.bg';
import fund from './fund.bg';
import fundReconstruction from './fundReconstruction.bg';
import globalSearch from './globalSearch.bg';
import inventory from './inventory.bg';
import navigation from './navigation.bg';
import packages from './packages';
import pasportization from './paspotization.bg';
import process from './process.bg';
import registration from './registration.bg';
import reports from './reports.bg';
import searchTemplates from './searchTemplates.bg';
import session from './session.bg';
import sessionAgenda from './sessionAgenda.bg';
import tasksTemplates from './tasksTemplates.bg';
import users from './users.bg';
import warning from './warning.bg';
import packageATemplates from './packageATemplates.bg';

export default {
    applications: {
        ...applications,
    },
    archives: {
        documents: 'Документи',
        kmf: 'КМФ',
        archive: 'архив',
        create: 'Нов @:archives.archive',
        display: 'Преглед на @:archives.archive',
        edit: 'Редактиране на @:archives.archive',
        select: 'Изберете от съществуващ в ИСДА @:archives.archive',
        title: 'Архиви',
        buttons: {
            backTooltip: 'Обратно към списък с Архиви',
            cancelTooltip: 'Отказ от създаване / редактиране на @:archives.archive',
            delete: 'Изтриване',
            display: 'Преглед',
            edit: 'Редакция',
            createTooltip: 'Създаване на @:archives.archive',
            editTooltip: 'Редакция на @:archives.archive',
            deleteTooltip: 'Изтриване на @:archives.archive',
            displayTooltip: 'Преглед на @:archives.archive',
            deleteConfirmation: 'Сигурни ли сте, че искате да изтриете @:archives.archive "{title}" ?',
        },
        columns: {
            actions: 'Действия',
            code: 'Код',
            createdBy: 'Създадено от',
            createdOn: 'Създадено на',
            deleted: 'Изтрито',
            deletedOn: 'Изтрито на',
            deletedBy: 'Изтрито от',
            hasExternalSource: 'Външен източник',
            externalIdentifier: 'Външен идентификатор',
            id: 'ИД',
            name: 'Име',
            sortOrder: 'Ред на подреждане',
            updatedOn: 'Променено на',
            updatedBy: 'Променено от',
        },
    },
    archiveEntities: {
        ...archivalEntity,
    },
    common: {
        ...common,
    },
    comments: {
        buttons: {
            deleteConfirmation: 'Сигурни ли сте, че искате да изтриете този коментар?',
        },
    },
    deduction: {
        ...deduction,
    },
    digitalObjects: {
        ...digitalObjectBg,
    },
    documents: {
        ...document,
    },
    docsCreateProc: {
        ...docsCreateProc,
    },
    eDocsCollection: {
        ...eDocsCollection,
    },
    epk: {
        meetingDate: 'Дата на заседание',
        opinion: 'Становище',
        sendToSession: 'Заседание на ЕПК',
        sendToComments: 'За коментари',
        sendToSessionTooltip: 'Изпращане за заседание на ЕПК',
        sendToCommentsTooltip: 'Изпращане за становища за въвеждане на коментари от експерт',
    },
    epkProtocol: {
        ...epkProtocol,
    },
    epkReport,
    error: {
        ...errorBg,
    },
    files: {
        ...files,
    },
    films: {
        ...films,
    },
    filmCards: {
        ...filmCards,
    },
    filmDocuments: {
        ...filmDocuments,
    },
    filmReviews: {
        ...filmReviews,
    },
    footer: {
        ...footerBg,
    },
    fundReconstructions: {
        ...fundReconstruction,
    },
    funds: {
        ...fund,
    },
    globalSearch: { ...globalSearch },
    grid: {
        filter: {
            apply: 'Приложи',
            clear: 'Изчисти',
            contains: 'Съдържа',
            equals: 'Равно на',
            greatThan: 'По-голямо от',
            lessThan: 'По-малко от',
            operator: 'Оператор',
            startsWith: 'Започва с',
            value: 'Стойност',
        },
        search: {
            tooltip: 'Търси',
        },
        pager: {
            first: 'Първа',
            last: 'Последна',
            next: 'Следваща',
            previous: 'Предишна',
            rowsOnPage: 'реда на страница',
        },
    },
    inventories: {
        ...inventory,
    },
    login: {
        title: 'Вход в системата',
        username: 'Потребителско име',
        email: 'E-mail',
        password: 'Парола',
        submit: 'Вход',
    },
    logout: {
        message: 'Затворете всички прозорци на браузъра, за да излезете напълно.',
    },
    navigation: {
        ...navigation,
    },
    nomenclature: {
        buttons: {
            backTooltip: 'Обратно към списък с Номенклатури',
            cancelTooltip: 'Отказ от създаване / редактиране на @:nomenclature.nomenclature',
            create: 'Нова @:nomenclature.nomenclature',
            createSuccessResult: 'Успешно създаване на @:nomenclature.nomenclature {title}',
            createTooltip: 'Създаване на @:nomenclature.nomenclature',
            createValue: 'Нова @:nomenclature.value',
            createValueSuccessResult: 'Успешно създаване на @:nomenclature.value {title}',
            createValueTooltip: 'Създаване на @:nomenclature.value към @:nomenclature.nomenclature',
            delete: 'Изтриване',
            deleteConfirmation: 'Сигурни ли сте, че искате да изтриете @:nomenclature.nomenclature {title} ?',
            deleteSuccessResult: 'Успешно изтриване на @:nomenclature.nomenclature {title}',
            deleteTooltip: 'Изтриване на @:nomenclature.nomenclature',
            deleteValueConfirmation: 'Сигурни ли сте, че искате да изтриете @:nomenclature.value {title} ?',
            deleteValueSuccessResult: 'Успешно изтриване на @:nomenclature.value {title}',
            deleteValueTooltip: 'Изтриване на @:nomenclature.value',
            displayTooltip: 'Преглед на @:nomenclature.nomenclature',
            displayValueTooltip: 'Преглед на @:nomenclature.value',
            display: 'Преглед',
            edit: 'Редакция',
            editTooltip: 'Редакция на @:nomenclature.nomenclature',
            editValueTooltip: 'Редакция на @:nomenclature.value',
            updateSuccessResult: 'Успешна промяна на @:nomenclature.nomenclature {title}',
            updateValueSuccessResult: 'Успешна промяна на @:nomenclature.value {title}',
        },
        columns: {
            actions: 'Действия',
            code: 'Код',
            createdOn: 'Създадено на',
            createdBy: 'Създадено от',
            deleted: 'Изтрито',
            deletedOn: 'Изтрито на',
            deletedBy: 'Изтрито от',
            description: 'Допълнителна информация',
            id: 'ИД',
            inactive: 'Неактивна',
            locked: 'Заключена',
            parent: 'Номенклатура',
            sortOrder: 'Подредба',
            text: 'Стойност',
            title: 'Наименование',
            unit: 'Регистратура',
            updatedOn: 'Променено на',
            updatedBy: 'Променено от',
            externalIdentifier: 'Код в ИСДА',
        },
        create: 'Създаване на @:nomenclature.nomenclature',
        display: 'Преглед на @:nomenclature.nomenclature',
        edit: 'Редакция на @:nomenclature.nomenclature',
        messages: {
            loadRelatedDocsFailed: 'Неупешно зареждане на свързани документи',
            valueCodeChange: 'Промяната на кода на стойността ще доведе до нулиране броячите за документи от тип: ',
            parentCodeChange:
                'Промяната на кода на номенклатурата ще доведе до промяна на шаблоните за генериране на системни номерана следните типове документи: ',
        },
        nomenclature: 'номенклатура',
        title: 'Номенклатури',
        value: 'стойност',
        values: {
            create: 'Създаване на @:nomenclature.values.value',
            display: 'Преглед на @:nomenclature.values.value',
            edit: 'Редакция на @:nomenclature.values.value',
            title: 'Стойности',
            value: 'стойност',
            buttons: {
                create: 'Нова @:nomenclature.values.value',
                createSuccessResult: 'Успешно създаване на @:nomenclature.values.value {title}',
                createTooltip: 'Създаване на @:nomenclature.values.value към @:nomenclature.nomenclature',
                delete: 'Изтриване',
                deleteConfirmation: 'Сигурни ли сте, че искате да изтриете @:nomenclature.values.value {title} ?',
                deleteSuccessResult: 'Успешно изтриване на @:nomenclature.values.value {title}',
                deleteTooltip: 'Изтриване на @:nomenclature.values.value',
                displayTooltip: 'Преглед на @:nomenclature.values.value',
                display: 'Преглед',
                edit: 'Редакция',
                editTooltip: 'Редакция на @:nomenclature.values.value',
                updateSuccessResult: 'Успешна промяна на @:nomenclature.values.value {title}',
            },
        },
    },
    notifications: {
        list: {
            createdOn: 'Дата',
            subject: 'Относно',
        },
        noNotificationsMessage: 'Няма съобщения',
    },
    packageATemplates: {
        ...packageATemplates,
    },
    packages,
    pasportization: {
        ...pasportization,
    },
    password: {
        title: 'Въвеждане на @:password.password',
        password: 'парола',
        buttons: {
            changePasswordSuccessResult: 'Успешно променена @:password.password',
            savePasswordSuccessResult: 'Успешно записана @:password.password',
        },
        columns: {
            currentPassword: 'Въведете текущата си @:password.password',
            password: 'Въведете @:password.password',
            passwordConfirmation: 'Повторете @:password.password',
        },
    },
    processes: {
        ...process,
    },
    profiles: {
        display: 'Преглед на @:profiles.profile',
        edit: 'Редактиране на @:profiles.profile',
        title: 'Потребителски профил',
        profile: 'потребителски профил',
        buttons: {
            editTooltip: 'Редакция на @:profiles.profile',
            displayTooltip: 'Преглед на @:profiles.profile',
        },
        columns: {
            id: 'ИД',
            clientName: 'Клиент',
            userName: 'Потребителско име',
            displayName: 'Име',
            email: 'Електронна поща',
            phoneNumber: 'Телефон',
        },
    },

    registration: {
        ...registration,
    },
    reports: {
        ...reports,
    },
    roles: {
        title: 'Потребителски роли',
        role: 'роля',
        create: 'Нова @:roles.role',
        edit: 'Редактиране на @:roles.role',
        display: 'Преглед на @:roles.role',
        manageUsers: 'Управление на потребители в @:roles.role "{title}"',
        buttons: {
            manageUsers: 'Управление на потребители',
            createTooltip: 'Създаване на @:roles.role',
            editTooltip: 'Редакция на @:roles.role',
            deleteTooltip: 'Изтриване на @:roles.role',
            displayTooltip: 'Преглед на @:roles.role',
            manageUsersTooltip: 'Управление на потребители в @:roles.role',
            deleteConfirmation: 'Сигурни ли сте, че искате да изтриете @:roles.role "{title}" ?',
        },
        columns: {
            id: 'ИД',
            name: 'Наименование',
            unit: 'Регистратура',
            client: 'Клиент',
            permissions: 'Права за достъп',
            description: 'Допълнителна информация',
            createdOn: 'Създадено на',
            createdBy: 'Създадено от',
            updatedOn: 'Променено на',
            updatedBy: 'Променено от',
            deleted: 'Изтрито',
            deletedOn: 'Изтрито на',
            deletedBy: 'Изтрито от',
            actions: 'Действия',
            sortOrder: 'Ред на сортиране',
        },
    },
    search: {
        emptyResult: 'Няма намерени резултати',
    },
    searchTemplates: {
        ...searchTemplates,
    },
    sessionAgenda: {
        ...sessionAgenda,
    },
    sessions: {
        ...session,
    },
    tasks: {
        assignToRole: 'Насочване към роля',
        display: 'Преглед на @:tasks.task',
        endDate: 'Крайна дата',
        missingAssignTo: 'Не сте посочили към кого насочвате!',
        role: 'Роля',
        send: 'Изпрати',
        task: 'задача',
        user: 'Потребител',

        buttons: {
            backTooltip: 'Обратно към списък със Задачи',
            cancel: 'Отмяна',
            cancelConfirmation: 'Сигурни ли сте, че искате да отмените задачата?',
            cancelTooltip: 'Отмяна на @:tasks.task',
            display: 'Преглед',
            displayTooltip: 'Преглед на @:tasks.task',
        },

        columns: {
            assignedTo: 'Възложена на служител',
            assignedToRole: 'Възложена на роля',
            createdBy: 'Създадена от',
            createdOn: 'Създадена на',
            description: 'Описание',
            endDate: 'Крайна дата',
            notificationTypeName: 'Тип известие',
            processType: 'Процес',
            relatedContentUrl: 'Свързано съдържание',
            status: 'Статус',
            stepTypeName: 'Стъпка',
            title: 'Заглавие',
            updatedBy: 'Променена от',
            updatedOn: 'Променена на',
        },
    },
    tasksTemplates: {
        ...tasksTemplates,
    },
    userRoles: {
        addUsers: 'Добави потребители',
        buttons: {
            addUsersTooltip: 'Добавяне на потребители',
            deleteUserTooltip: 'Изтриване на @:users.user',
            deleteUserConfirmation:
                'Сигурни ли сте, че искате да изтриете @:users.user "{user}" от @:roles.role "{role}" ?',
        },
    },
    users: {
        ...users,
    },
    userTypes: {
        EXT: 'Външни потребители',
        INT: 'Вътрешни потребители',
        SYS: 'Системни потребители',
    },
    warnings: {
        ...warning,
    },
};
