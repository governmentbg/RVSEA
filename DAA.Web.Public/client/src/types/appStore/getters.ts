import { State } from "./state";

export type Getters = {
    isLoading(state: State): boolean
    language(state: State): string,
    baseUrl(state: State): string,
    uiUrl(state: State): string,
    dateTimeFormat(state: State): string,
    dateTimeLongFormat(state: State): string,
    dateFormat(state: State): string,
    timeFormat(state: State): string,
    maxPackageAFileSizeInMB(state: State): number,
    maxPackageBFileSizeInMB(state: State): number,
}