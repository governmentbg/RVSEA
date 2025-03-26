/* eslint-disable @typescript-eslint/no-explicit-any */
import bgMsgs from "@vee-validate/i18n/dist/locale/bg.json";
import enMsgs from "@vee-validate/i18n/dist/locale/en.json";

(bgMsgs.messages as any).url = "Невалиден URL";
(enMsgs.messages as any).url = "Invalid URL";
(bgMsgs.messages as any).decimal =
  "Полето {field} трябва да е число с 0:{length} цифри след десетичната запетая";
(enMsgs.messages as any).decimal =
  "The {field} field must be numeric and may contain 0:{length} digits after decimal point";
(bgMsgs.messages as any).float = "Полето {field} трябва да е число";
(enMsgs.messages as any).float = "The {field} must be numeric";
(bgMsgs.messages as any).duration = "Полето {field} трябва да е цяло число или във формат 00:00:00";
(enMsgs.messages as any).duration = "The {field} must be an integer or in the format 00:00:00";
export const bg = bgMsgs;
export const en = enMsgs;
export default { bg, en };
