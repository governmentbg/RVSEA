export class PublicUserReviewDisplayModel {
    constructor(obj?: PublicUserReviewDisplayModel) {
        Object.assign(this, obj);
    }
    userDisplayName?: string;
    userProfileType?: string;
    date?: Date;
}