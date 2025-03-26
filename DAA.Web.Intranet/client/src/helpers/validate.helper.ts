/* eslint-disable @typescript-eslint/no-explicit-any */

import { ProcessStep, ProcessType } from "@/enums/process";
import { IProcess } from "@/interfaces/process";

export const isChronologicalScopeFull = (startDay: number | undefined, startMonth: number | undefined, startYear: number | undefined, endDay: number | undefined, endMonth: number | undefined, endYear: number | undefined) : boolean => {
    if (
        (startDay && !startMonth && startYear) ||
        (startDay && !startMonth && !startYear) ||
        (startDay && startMonth && !startYear) ||
        (!startDay && startMonth && !startYear) ||
        (endDay && !endMonth && endYear) ||
        (endDay && !endMonth && !endYear) ||
        (endDay && endMonth && !endYear) ||
        (!endDay && endMonth && !endYear)
    ) return false;
    return true;
}

export const isStartDateBeforeEndDate = (startDay: number | undefined, startMonth: number | undefined, startYear: number | undefined, endDay: number | undefined, endMonth: number | undefined, endYear: number | undefined) : boolean => {
    if (
        (startYear && endYear && startYear > endYear) ||
        (startYear && endYear && startMonth && endMonth && startYear == endYear && startMonth > endMonth) ||
        (startYear && endYear && startMonth && endMonth && startDay && endDay && startYear == endYear && startMonth == endMonth && startDay > endDay)
    ) return false;
    return true;
}

export const isDateAtLeastNDaysFromStartDay = (startDay: number | undefined, startMonth: number | undefined, startYear: number | undefined, endDay: number | undefined, endMonth: number | undefined, endYear: number | undefined, daysDiff: number | undefined) : boolean => {    
    if (
        (startDay && startMonth && startYear && endDay && endMonth && endYear && daysDiff) &&
        ((startYear == endYear && (startMonth == endMonth && startDay <= endDay - daysDiff || startMonth == endMonth - 1 && (getMonthLength(startMonth, startYear) - startDay + endDay) >= daysDiff) || startMonth < endMonth - 1) ||
         (startYear < endYear) && ((startMonth != 12 || endMonth != 1) || (getMonthLength(startMonth, startYear) - startDay + endDay) >= daysDiff))
    ) return true;
    return false;
}

export const getMonthLength = (month: number, inYear: number) : number => {
    switch (month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            return 31
        case 4:
        case 6:
        case 9:
        case 11:
            return 30
        case 2:
            if(inYear / 4 == 0) return 29
            else return 28
        default: return 0
    } 
}

export const isProcessType = (process: IProcess, ...processType: ProcessType[]) : boolean => {
    if (processType.find(procType => process.processTypeId === procType)) {
        return true;
    }
    return false;
};

export const isProcessStepType = (process: IProcess, ...processStepType: ProcessStep[]) : boolean => {
    if (processStepType.find(procStepType => process.activeProcessStepTypeId === procStepType)) {
        return true;
    }
    return false;
};
