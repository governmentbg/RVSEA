import { IDropdownOption } from '@/interfaces/dropdown';
export const allFromDropdownValue = '-999';

export const returExternalCodesFromInternalCodes = (internalCodes: string[], allItems: IDropdownOption[]) => {
    const externalCodes = [] as string[];

    for (let index = 0; index < internalCodes.length; index++) {
        if (internalCodes[0] === allFromDropdownValue) {
            externalCodes.push(allFromDropdownValue);
            break;
        } else {
            const el = allItems?.find((x) => x.code == internalCodes[index]) as IDropdownOption;
            if (el.externalIdentifier) {
                externalCodes.push(el.externalIdentifier.toString());
            }
        }
    }

    return externalCodes;
};
