/* eslint-disable @typescript-eslint/no-explicit-any */
import moment from 'moment';
import { appStore } from '@/store/app';
import { i18n } from '@/language';
import { MinutesOfMeetingStatus } from '@/enums/minutesOfMeetingStatus';
import { ApplicationUserProfileType } from '@/enums/profile';
import { ImportErrorList } from '@/models/packages';
import { SheetType } from '@/enums/importSheetTypes';

export const formatDateTime = (value: Date | string) => {
    if (value) {
        return moment(value).format(appStore().getters.dateTimeFormat);
    } else return value;
};

export const formatDate = (value: Date | string) => {
    if (value) {
        return moment(value).format(appStore().getters.dateFormat);
    } else return value;
};

export const formatTime = (value: Date | string) => {
    if (value) {
        return moment(value).format(appStore().getters.timeFormat);
    } else return value;
};

export const formatYesNo = (value: boolean) => {
    if (value == true) {
        return i18n.global.t('common.yes');
    } else return i18n.global.t('common.no');
};

export const trimText = (fullText: string | null | undefined, numberOfCharacters?: number) => {
    if (!fullText) {
        return '';
    }

    const numberOfCharactersFromTextToShow = numberOfCharacters ?? 50;
    if (fullText.length <= numberOfCharactersFromTextToShow) {
        return fullText;
    }
    const trimmedText = fullText.substring(0, numberOfCharactersFromTextToShow);
    return `${trimmedText}...`;
};

export const convertToBool = (value: string) => {
    if (value.toLowerCase() === i18n.global.t('common.yes').toLowerCase()) {
        return true;
    }
    if (value.toLowerCase() === i18n.global.t('common.no').toLowerCase()) {
        return false;
    }

    return undefined;
};

export const groupBy = (objectArray: any, property: any) => {
    return objectArray.reduce((acc: any, obj: any) => {
        const key = obj[property];
        if (!acc[key]) {
            acc[key] = [];
        }
        acc[key].push(obj);
        return acc;
    }, {});
};

export const formatBytes = (bytes: number, decimals: number = 2) => {
    if (bytes) {
        const k = 1024;
        const dm = decimals < 0 ? 0 : decimals;
        const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

        const i = Math.floor(Math.log(bytes) / Math.log(k));
        const formatted = parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
        return formatted;
    } else {
        return bytes;
    }
};

export const formatBytesToMB = (bytes: number) => {
    if (bytes) {
        const k = 1024;

        const converted = Number((bytes / k / k).toFixed(2));
        return converted;
    } else {
        return bytes == null ? 0 : bytes;
    }
};

// Идеята е да се показва винаги достатъчен брой значещи цифри. Например при малки размери да се показват повече цифи след запетаята, а при големи - по-малко.
// 29.03 - те искат винаги да са 3 знака след запетаята
export const formatBytesToMBComplex = (bytes: number) => {
    if (bytes) {
        const k = 1024;

        const converted = bytes / k / k;
        return Number(converted.toFixed(3));
    } else {
        return bytes;
    }
};

export const formatPartiteDate = (
    year: number | null | undefined,
    month: number | null | undefined,
    day: number | null | undefined
) => {
    if (year && month && day) {
        console.log(new Date(year, month, day));
        return formatDate(new Date(year, month, day));
    }

    if (!year && !month && !day) {
        return '';
    }

    if (!year) {
        return 'na';
    }

    if (!day && !month) {
        return year.toString();
    }

    if (!day && month) {
        return `${year}.${month}`;
    }
};

export const defaultGuidString = () => {
    return '00000000-0000-0000-0000-000000000000';
};

export const transformMonth = (m: string) => {
    switch (m) {
        case '1':
            return 'ян.';
        case '2':
            return 'февр.';
        case '3':
            return 'март';
        case '4':
            return 'апр.';
        case '5':
            return 'май';
        case '6':
            return 'юни';
        case '7':
            return 'юли';
        case '8':
            return 'авг.';
        case '9':
            return 'септ.';
        case '10':
            return 'окт.';
        case '11':
            return 'ноем.';
        case '12':
            return 'дек.';
        default:
            return '';
    }
};
export const returnSessionTypeName = (t: string) => {
    switch (t) {
        case '1':
            return 'ЕПК';
        case '2':
            return 'ЕОК';
        case '3':
            return 'РЕОК';
        default:
            return '';
    }
};

export const stringifyYear = (y: string) => {
    return `${y}`;
};

export const stringifyDay = (d: string) => {
    return `${d} `;
};
export const switchProtocolStatusText = (val: string) => {
    switch (val) {
        case MinutesOfMeetingStatus.New:
            return 'Нов';
        case MinutesOfMeetingStatus.SubmittedForApproval:
            return 'Изпратен за утвърждаване';
        case MinutesOfMeetingStatus.Approved:
            return 'Утвърден';
        case MinutesOfMeetingStatus.Rejected:
            return 'Върнат за корекции';
        default:
            break;
    }
};

export const validateDay = (month: number | undefined, year: number | undefined): number => {
    const short = [4, 6, 9, 11];
    if (short.some((n) => n == month)) {
        return 30;
    }
    if (month == 2) {
        if (year && year % 4 == 0) {
            return 29;
        }
        return 28;
    }
    return 31;
};

export const parseDuration = (value: string): number | undefined => {
    const regex = new RegExp('^(\\d{1,}:\\b(00|0[1-9]|[1-5]\\d|59)\\b:\\b(00|0[1-9]|[1-5]\\d|59)\\b)$');
    if (value && regex.test(value.toString())) {
        const elements = value.toString().split(':');
        const hoursInSeconds = parseInt(elements[0]) * 3600;
        const minutesinSeconds = parseInt(elements[1]) * 60;
        const seconds = parseInt(elements[2]);
        return hoursInSeconds + minutesinSeconds + seconds;
    } else {
        return +value;
    }
};

export const formatDuration = (input: number): string => {
    if (input === undefined || input === null) {
        return '00:00:00';
    }

    let delimeter = ':';

    const hours = Math.floor(input / 3600);
    let hoursStr = hours.toString();
    if (hours === 0) {
        hoursStr = '00';
        delimeter = ':';
    }

    const minutes = Math.floor((input % 3600) / 60);
    let minutesStr = minutes.toString();
    if (minutesStr.length === 1 && hoursStr !== '') {
        minutesStr = '0' + minutesStr;
    }

    const seconds = (input % 3600) % 60;
    let secondsStr = seconds.toString();
    if (secondsStr.length === 1) {
        secondsStr = '0' + secondsStr;
    }

    const output = `${hoursStr}${delimeter}${minutesStr}:${secondsStr}`;

    return output;
};

export const formatStringDuration = (input: string): string => {
    if (input === undefined || input === null) {
        return '';
    }

    const splits = input.split('.');
    const output = splits[0];

    return output;
};

export const formatUserProfileType = (value: string) => {
    if (value == ApplicationUserProfileType.CardHolder) {
        return i18n.global.t('users.cardHolder');
    } else if (value == ApplicationUserProfileType.FundCreator) {
        return i18n.global.t('users.fundCreator');
    }
    return '';
};

export const getFilenameExtension = (value: string) => {
    const result = value.split('.').pop();
    return result;
};

export const getArchiveCityName = (value: string) => {
    const a = value.slice(5);
    const result = a;
    return result;
};

export const formatStringOnTwoLines = (value: string, all: boolean = true) => {
    if (!all) {
        return value?.toString().split(';').shift();
    }

    if (value && value.toString().includes(';') && all) {
        return value.replaceAll(';', '<br/>');
    } else return value;
};

export const formatApproximateChronologicalScope = (value: string) => {
    const firstPArt = value?.toString().split('-').shift();
    const lastPArt = value?.toString().split('-').pop();
    if (firstPArt && firstPArt!.replace(/ /g, '') === lastPArt!.replace(/ /g, '') && lastPArt) {
        return firstPArt.trim();
    } else return value;
};

export const formatImportErrors = (value: string) => {
    const resultArray = [] as ImportErrorList[];
    let sheetArr = value.split('Sheet');
    sheetArr = sheetArr.filter((x) => x != '');
    for (let i = 0; i < sheetArr.length; i++) {
        const sheetName = sheetArr[i].split(':').shift()?.trim() ?? 'Лист';
        const singleErrorArr = sheetArr[i].split(':').toString().split('\r\n');
        const index = singleErrorArr[0].toString().search('на ред');

        const rowNumber =
            singleErrorArr[0]
                .slice((index as number) + 6)
                .split(',')
                .shift()
                ?.replace('.', ' ') ?? 'Номер на ред';

        for (let i = 0; i < singleErrorArr.length; i++) {
            let firstElSplitDesc;
            if (singleErrorArr[i] == '') {
                continue;
            }
            if (i == 0) {
                firstElSplitDesc = singleErrorArr[i].split(rowNumber).pop() ?? '';
                if (firstElSplitDesc != '' && firstElSplitDesc[0] == ',') {
                    firstElSplitDesc = firstElSplitDesc.slice(1).trimStart();
                }
                if (firstElSplitDesc == '000') {
                    firstElSplitDesc = singleErrorArr[i].split(',')[2] ?? '';
                    firstElSplitDesc = firstElSplitDesc.slice(1).trimStart();
                }

                resultArray.push({
                    sheet: switchSheetName(sheetName),
                    row: Number.isNaN(Number.parseInt(rowNumber.trim())) ? '' : rowNumber.trim(),
                    col: firstElSplitDesc.includes('Поле')
                        ? firstElSplitDesc
                              .substring(firstElSplitDesc.indexOf('Поле') + 5, firstElSplitDesc.lastIndexOf('трябва'))
                              .trim()
                        : '',
                    description:
                        firstElSplitDesc != '' && firstElSplitDesc != '0' ? firstElSplitDesc : singleErrorArr[i],
                });
            } else
                resultArray.push({
                    sheet: switchSheetName(sheetName),
                    row: Number.isNaN(Number.parseInt(rowNumber.trim())) ? '' : rowNumber.trim(),
                    col: singleErrorArr[i]
                        .substring(singleErrorArr[i].indexOf('Поле') + 5, singleErrorArr[i].lastIndexOf('трябва'))
                        .trimEnd(),
                    description: singleErrorArr[i],
                });
        }
    }
    return resultArray;
};
const switchSheetName = (val: string = '') => {
    switch (val) {
        case SheetType.ArchivalEntitiesSheetName:
        case SheetType.DocumentsSheetName:
        case SheetType.InventorySheetName:
        case SheetType.PackageBSheetName:
            return val.trim();
    }
    return '';
};
