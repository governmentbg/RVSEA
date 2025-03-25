import { ArchivalEntityDescriptionLevel } from '@/enums/archivalEntity';
import { DocumentDescriptionLevel } from '@/enums/document';
import { EntityType } from '@/enums/entity';
import { FundDescriptionLevel } from '@/enums/fund';
import { InventoryDescriptionLevel } from '@/enums/inventory';
import { BusinessObjectType } from '@/models/grid';

export const entityObjectType = (type: EntityType, descriptionLevel?: string): string => {
    let objType: string = BusinessObjectType.unknown;
    switch (type) {
        case EntityType.fund:
            switch (descriptionLevel) {
                case FundDescriptionLevel.fund:
                    objType = BusinessObjectType.fund;
                    break;
                case FundDescriptionLevel.rawFund:
                    objType = BusinessObjectType.rawFund;
                    break;
                case FundDescriptionLevel.chp:
                    objType = BusinessObjectType.chp;
                    break;
                case FundDescriptionLevel.memory:
                    objType = BusinessObjectType.memory;
                    break;
            }
            break;
        case EntityType.inventory:
            switch (descriptionLevel) {
                case InventoryDescriptionLevel.inventory:
                    objType = BusinessObjectType.inventory;
                    break;
                case InventoryDescriptionLevel.rawInventory:
                    objType = BusinessObjectType.rawInventory;
                    break;
                case InventoryDescriptionLevel.systemInventory:
                    objType = BusinessObjectType.systemInventory;
                    break;
            }
            break;
        case EntityType.archivalEntity:
            switch (descriptionLevel) {
                case ArchivalEntityDescriptionLevel.archivalEntity:
                    objType = BusinessObjectType.archivalEntity;
                    break;
                case ArchivalEntityDescriptionLevel.systemArchivalEntity:
                    objType = BusinessObjectType.systemArchivalEntity;
                    break;
            }
            break;
        case EntityType.document:
            switch (descriptionLevel) {
                case DocumentDescriptionLevel.document:
                    objType = BusinessObjectType.document;
                    break;
            }
            break;
        case EntityType.film:
            objType = BusinessObjectType.film;
            break;
        default:
            objType = BusinessObjectType.unknown;
            break;
    }

    return objType;
};
