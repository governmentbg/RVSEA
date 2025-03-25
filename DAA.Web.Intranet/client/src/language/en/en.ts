import applications from './applications.en';
import archivalEntityEn from './archivalEntity.en';
import digitalObjectEn from './digitalObject.en';
import docsCreateProc from './docsCreatingProcess.bg';
import documentEn from './document.en';
import epkReport from './epk.en';
import files from './files.en';
import films from './films.en';
import filmCards from './filmCards.en';
import filmDocuments from './filmDocuments.en';
import globalSearch from './globalSearch.en';
import commonEn from './common.en';
import processEn from './process.en';
import searchTemplates from './searchTemplates.en';
import sessionEn from './session.en';
import sessionAgendaEn from './sessionAgenda.en';
import navigationEn from './navigation.en';
import fundEn from './fund.en';
import inventoryEn from './inventory.en';
import filmReviewsEn from './filmReviews.en';
import taskTemplatesEn from './taskTemplates.en';
import footerEn from './footer.en';
import packages from './packages';
import paspotization from './paspotization.en';
import errors from './error.en';
import usersEn from './users.en';
import packageATemplates from './packageATemplates.en';

export default {
    applications: {
        ...applications,
    },
    archives: {
        archive: 'archive',
        create: 'New @:archives.archive',
        display: 'Display @:archives.archive',
        edit: 'Edit @:archives.archive',
        select: 'Select existing @:archives.archive',
        title: 'Archives',
        buttons: {
            delete: 'Delete',
            display: 'Display',
            edit: 'Edit',
            createTooltip: 'Create @:archives.archive',
            editTooltip: 'Edit @:archives.archive',
            deleteTooltip: 'Delete @:archives.archive',
            displayTooltip: 'Display @:archives.archive',
            deleteConfirmation: 'Are you sure you want to delete @:archives.archive "{title}" ?',
        },
        columns: {
            actions: 'Actions',
            code: 'Code',
            createdOn: 'Crated on',
            createdBy: 'Created by',
            deleted: 'Deleted',
            deletedOn: 'Deleted on',
            deletedBy: 'Deleted by',
            hasExternalSource: 'Has external source',
            externalIdentifier: 'External identifier',
            id: 'Id',
            name: 'Name',
            sortOrder: 'Sort order',
            updatedBy: 'Modified by',
            updatedOn: 'Modified on',
        },
    },
    archiveEntities: {
        ...archivalEntityEn,
    },
    common: {
        ...commonEn,
    },
    comments: {
        buttons: {
            deleteConfirmation: 'Are you sure you want to delete this comment?',
        },
    },
    deduction: {
        creationDate: 'Date of preparation',
        epkNumber: 'EPK Report Number',
        fundName: 'Fund name',
        creatorName: 'Prepared the report',
        position: 'Position',
        about: 'About',
        deduction: 'Deduction',
        content: 'Content',
        attachedDocuments: 'Attached documents',
        button: {
            meetingDate: 'Send to set meeting date',
            confirmed: 'Confirm',
            noCorrectionsNeeded: 'No corrections needed',
            addComment: 'Add comment',
        },
        steps: {
            step1: 'Step  Initiate a process and prepare a report to the EPK',
            step2: 'Step  Setting a date for consideration of an EPK report',
            step3: 'Step  Introduction of an opinion by members of the EPK',
            step248: 'Step Input comments from an expert ',
            step4: 'Step Decision after EPK session',
            step5: 'Step  Implementation of EPK recommendations',
            step6: 'Step  Check the corrections made',
            step7: 'Step  Approval by Director',
            step7a: 'Step Agree to Request Corrections',
        },
    },
    digitalObjects: {
        ...digitalObjectEn,
    },
    documents: {
        ...documentEn,
    },
    docsCreateProc: {
        ...docsCreateProc,
    },
    epk: {
        meetingDate: 'Session date',
        opinion: 'Opinion',
        sendToSession: 'EPC session',
        sendToComments: 'Send for comments',
    },
    epkProtocol: {
        date: 'Protocol date',
        number: 'Protocol number',
        decision: 'Decision',
        deadline: 'Deadline for approval',
        alert: 'You cant create decision with empty data field',
    },
    epkReport,
    error: {
        ...errors,
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
        ...filmReviewsEn,
    },
    footer: {
        ...footerEn,
    },
    funds: {
        ...fundEn,
    },
    globalSearch: { ...globalSearch },
    grid: {
        filter: {
            apply: 'Apply',
            clear: 'Clear',
            contains: 'Contains',
            equals: 'Equals',
            greatThan: 'Great than',
            lessThan: 'Less than',
            operator: 'Operator',
            startsWith: 'Starts with',
            value: 'Value',
        },
        search: {
            tooltip: 'Search',
        },
        pager: {
            first: 'First',
            last: 'Last',
            next: 'Next',
            previous: 'Previous',
            rowsOnPage: 'items per page',
        },
    },
    inventories: {
        ...inventoryEn,
    },
    login: {
        title: 'Login',
        username: 'Username',
        email: 'E-mail',
        password: 'Password',
        submit: 'Submit',
    },
    logout: {
        message: 'Close all browser windows to logout completely',
    },
    navigation: {
        ...navigationEn,
    },
    nomenclature: {
        buttons: {
            create: 'Add @:nomenclature.nomenclature',
            createSuccessResult: 'Successfully created @:nomenclature.nomenclature {title}',
            createTooltip: 'Create @:nomenclature.nomenclature',
            createValue: 'Create @:nomenclature.value',
            createValueSuccessResult: 'Successfully created @:nomenclature.value {title}',
            createValueTooltip: 'Create @:nomenclature.value for @:nomenclature.nomenclature',
            delete: 'Delete',
            deleteConfirmation: 'Are you sure you want to delete @:nomenclature.nomenclature {title} ?',
            deleteSuccessResult: 'Successfully deleted @:nomenclature.nomenclature {title}',
            deleteTooltip: 'Delete @:nomenclature.nomenclature',
            deleteValueConfirmation: 'Are you sure you want to delete @:nomenclature.value {title} ?',
            deleteValueSuccessResult: 'Successfully deleted @:nomenclature.value {title}',
            deleteValueTooltip: 'Delete @:nomenclature.value',
            displayTooltip: 'Display @:nomenclature.nomenclature',
            displayValueTooltip: 'Display @:nomenclature.value',
            display: 'Display',
            edit: 'Edit',
            editTooltip: 'Edit @:nomenclature.nomenclature',
            editValueTooltip: 'Edit @:nomenclature.value',
            updateSuccessResult: 'Sucessfully modified @:nomenclature.nomenclature {title}',
            updateValueSuccessResult: 'Successfully modified @:nomenclature.value {title}',
        },
        columns: {
            actions: 'Actions',
            code: 'Code',
            createdOn: 'Crated on',
            createdBy: 'Created by',
            deleted: 'Deleted',
            deletedOn: 'Deleted on',
            deletedBy: 'Deleted by',
            description: 'Description',
            id: 'ID',
            inactive: 'Inactive',
            locked: 'Locked',
            parent: 'Nomenclature',
            sortOrder: 'Sort order',
            text: 'Text',
            title: 'Title',
            unit: 'Unit',
            updatedOn: 'Modified on',
            updatedBy: 'Modified by',
        },
        create: 'Create @:nomenclature.nomenclature',
        display: 'Display @:nomenclature.nomenclature',
        edit: 'Edit @:nomenclature.nomenclature',
        messages: {
            loadRelatedDocsFailed: 'Failed to load related documents',
            valueCodeChange: 'Changing the code of the value will reset the counters for documets of type: ',
            parentCodeChange:
                'Changing the code of the nomenclature will change the system number generation templates for the following document types: ',
        },
        nomenclature: 'nomenclature',
        title: 'Nomenclatures',
        value: 'value',
        values: {
            create: 'Create @:nomenclature.value',
            display: 'Display @:nomenclature.value',
            edit: 'Edit @:nomenclature.value',
            title: 'Values',
            value: 'value',
            buttons: {
                create: 'Create @:nomenclature.value',
                createSuccessResult: 'Successfully created @:nomenclature.value {title}',
                createTooltip: 'Create @:nomenclature.value for @:nomenclature.nomenclature',
                delete: 'Delete',
                deleteConfirmation: 'Are you sure you want to delete @:nomenclature.value {title} ?',
                deleteSuccessResult: 'Successfully deleted @:nomenclature.value {title}',
                deleteTooltip: 'Delete @:nomenclature.value',
                displayTooltip: 'Display @:nomenclature.value',
                display: 'Display',
                edit: 'Edit',
                editTooltip: 'Edit @:nomenclature.value',
                updateSuccessResult: 'Successfully modified @:nomenclature.value {title}',
            },
        },
    },
    notifications: {
        list: {
            createdOn: 'Date',
            subject: 'Subject',
        },
        noNotificationsMessage: 'No notifications',
    },
    packageATemplates: {
        ...packageATemplates,
     },
    password: {
        title: 'Enter @:password.password',
        password: 'password',
        buttons: {
            changePasswordSuccessResult: 'Successfully changed @:password.password',
            savePasswordSuccessResult: 'Successfully saved @:password.password',
        },
        columns: {
            currentPassword: 'Enter current @:password.password',
            password: 'Enter @:password.password',
            passwordConfirmation: 'Confirm @:password.password',
        },
    },
    packages,
    paspotization: {
        ...paspotization,
    },
    processes: {
        ...processEn,
    },
    profiles: {
        display: 'Display @:profiles.profile',
        edit: 'Edit @:profiles.profile',
        title: 'User Profile',
        profile: 'user proile',
        buttons: {
            editTooltip: 'Edit @:profiles.profile',
            displayTooltip: 'Display @:profiles.profile',
        },
        columns: {
            id: 'ID',
            clientName: 'Client',
            userName: 'Username',
            displayName: 'Display Name',
            email: 'Email',
            phoneNumber: 'Phone number',
        },
    },
    roles: {
        title: 'User Roles',
        role: 'role',
        create: 'Add @:roles.role',
        edit: 'Edit @:roles.role',
        display: 'Display @:roles.role',
        manageUsers: 'Manage users in role "{title}"',
        buttons: {
            manageUsers: 'Manage users',
            createTooltip: 'Crate @:roles.role',
            editTooltip: 'Edit @:roles.role',
            deleteTooltip: 'Delete @:roles.role',
            displayTooltip: 'Display @:roles.role',
            manageUsersTooltip: 'Manage users in role',
            deleteConfirmation: 'Are you sure you want to delete "{title}" ?',
        },
        columns: {
            id: 'ID',
            name: 'Name',
            unit: 'Unit',
            client: 'Client',
            permissions: 'Permissions',
            description: 'Description',
            sortOrder: 'Sort order',
            createdOn: 'Crated on',
            createdBy: 'Created by',
            updatedOn: 'Modified on',
            updatedBy: 'Modified by',
            deleted: 'Deleted',
            deletedOn: 'Deleted on',
            deletedBy: 'Deleted by',
            actions: 'Actions',
        },
    },
    search: {
        emptyResult: 'No results found',
    },
    searchTemplates: {
        ...searchTemplates,
    },
    sessionAgenda: {
        ...sessionAgendaEn,
    },
    sessions: {
        ...sessionEn,
    },
    tasks: {
        assignToRole: 'Assign to role',
        display: 'Display @:tasks.task',
        endDate: 'End date',
        missingAssignTo: 'You have not assigned to anyone!',
        role: 'Role',
        send: 'Send',
        task: 'Task',
        user: 'User',

        buttons: {
            cancel: 'Cancel',
            cancelConfirmation: 'Are you sure you want to cancel the task?',
            cancelTooltip: 'Cancel @:tasks.task',
            display: 'Display',
            displayTooltip: 'Display @:tasks.task',
        },

        columns: {
            assignedTo: 'Assigned to employee',
            assignedToRole: 'Assigned to role',
            createdBy: 'Created by',
            createdOn: 'Created on',
            description: 'Description',
            endDate: 'End date',
            notificationTypeName: 'Notification type',
            processType: 'Process',
            relatedContentUrl: 'Related content',
            status: 'Status',
            stepTypeName: 'Step',
            title: 'Title',
            updatedBy: 'Update by',
            updatedOn: 'Updated on',
        },
    },
    taskTemplates: {
        ...taskTemplatesEn,
    },
    userRoles: {
        addUsers: 'Add users',
        buttons: {
            addUsersTooltip: 'Add users',
            deleteUserTooltip: 'Delete @:users.user',
            deleteUserConfirmation:
                'Are you sure you want to delete @:users.user "{user}" from @:roles.role "{role}" ?',
        },
    },
    users: {
        ...usersEn,
    },
    userTypes: {
        EXT: 'External users',
        INT: 'Internal users',
        SYS: 'System users',
    },
};
