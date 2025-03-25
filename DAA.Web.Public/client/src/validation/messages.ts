/* eslint-disable @typescript-eslint/no-explicit-any */
import bgMsgs from "@vee-validate/i18n/dist/locale/bg.json";
import enMsgs from "@vee-validate/i18n/dist/locale/en.json";

(bgMsgs.messages as any).url = "Невалиден URL";
(enMsgs.messages as any).url = "Invalid URL";

(bgMsgs.messages as any).password = "Паролата трябва да съдържа поне 8 символа, сред които поне една малка буква, една голяма буква и една цифра";
(enMsgs.messages as any).password = "The password must contain at least 8 characters, including at least one lowercase letter, one uppercase letter and one numberL";

(bgMsgs.messages as any).decimal =
  "Полето {field} трябва да е число с 0:{length} цифри след десетичната запетая";
(enMsgs.messages as any).decimal =
  "The {field} field must be numeric and may contain 0:{length} digits after decimal point";
(bgMsgs.messages as any).positiveNumber =
  "Полето {field} трябва да е положително число";
(enMsgs.messages as any).positiveNumber =
  "The {field} field must be a positive number";

(bgMsgs.messages as any).documentsPeriod = "Периодът трябва да бъде във формат 0000 или 0000-0000";
(enMsgs.messages as any).documentsPeriod = "The period must be in the format 0000 or 0000-0000";

export const bg = bgMsgs;
export const en = enMsgs;
export default { bg, en };
