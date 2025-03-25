/* eslint-disable @typescript-eslint/no-unused-vars */
import { defineRule, configure } from "vee-validate";
import AllRules from "@vee-validate/rules";
import { setLocale, localize } from "@vee-validate/i18n";
import { bg, en } from "./messages";

configure({
  generateMessage: localize({
    bg,
    en,
  }),
});

Object.keys(AllRules).forEach((rule) => {
  defineRule(rule, AllRules[rule]);
});

//Custom rules go here ...
//Messages for them must be added in ./messages
defineRule("url", (value: string) => {
  if (!value) {
    return true;
  }

  const regex = new RegExp(
    /https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,}/
  );
  if (regex.test(value)) {
    return true;
  }

  return false;
});

defineRule("decimal", (value: string, target: Array<number>) => {
  if (!value) {
    return true;
  }

  // eslint-disable-next-line no-unused-vars
  const floatingPointNumbers = target && target[0] ? `{0,${target[0]}}` : "*";
  const regexStr = `^\\d*\\.\\d{${target[0]}}$`;
  const regex = new RegExp(regexStr);

  if (regex.test(value)) {
    return true;
  }

  return false;
});

defineRule("password", (value: string) => {
  if (!value) {
    return true;
  }

  const regex = new RegExp('(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{8,}');
  if (regex.test(value)) {
    return true;
  }
  return false;
})

defineRule("positiveNumber", (value: number) => {
  if (!value) {
    return true;
  }
  if (value < 0) {
    return false;
  }
  return true;
})

defineRule("documentsPeriod", (value: string) => {
  if(value == undefined) return false;

    if(value.length == 4 && Number.isNaN(+value) == false) return true;

    const regex = new RegExp('(\\d{4}-\\d{4})');
      if (regex.test(value)) {
        const splitedPeriod = value.split('-');
        return splitedPeriod[0] <= splitedPeriod[1];
      }

    return false;
})


//TODO: Трябва да се взема реактивно от стора когато сме готови с мултиезичността
setLocale("bg");
