export interface IDropdownOption {
    id?: number;
    code?: string | number;
    label?: string;
    description?: string;
    groupName?: string;
    hasExternalSource?: boolean;
    externalIdentifier?: number;
}

export interface IDropdownTreeOption {
    id?: number;
    parentId?: number;
    code?: string;
    label: string;
    description?: string;
    groupName?: string;
}
