export interface IColumn {
    title: string;
    prop: string;
    type: string;
    sortable: boolean;
    filterable: boolean;
    textAlign: string;
    cellClass: string;
    titleClass: string;
    visible: boolean;
    sort: number;
    permanent: boolean;
    fieldId?: number;
    fieldType?: string;
    renderFunction?: Function;
    template?: Function;
    filterByBooleanFunction?: Function;
}

export interface IGridSettings {
    columns: Array<IColumn>,
    showRowNumber: boolean,
    showSearch: boolean
}