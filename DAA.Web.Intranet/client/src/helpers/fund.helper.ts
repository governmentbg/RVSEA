import { FundDescriptionLevel } from '@/enums/fund';
import { BusinessObjectType } from '@/models/grid';

export const fundEntityType = (descLevel: string) => {
	if (descLevel === FundDescriptionLevel.fund) {
		return BusinessObjectType.fund;
	} else if(descLevel === FundDescriptionLevel.rawFund) {
		return BusinessObjectType.rawFund;
	}
}