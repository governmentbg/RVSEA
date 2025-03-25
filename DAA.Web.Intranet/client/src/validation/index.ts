import { defineRule, configure } from "vee-validate";
import AllRules, { numeric } from "@vee-validate/rules";
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

  //const floatingPointNumbers = target && target[0] ? `{0,${target[0]}}` : "*";

  const regexStr = `^\\d*\\.\\d{${target[0]}}$`;
  const regex = new RegExp(regexStr);

  if (regex.test(value)) {
    return true;
  }

  return false;
});

defineRule("float", (value: string) => {
  if (!value) {
    return true;
  }

  //const floatingPointNumbers = target && target[0] ? `{0,${target[0]}}` : "*";

  const regexStr = `^(\\d+.\\d*)$`;
  const regex = new RegExp(regexStr);

  if (regex.test(value)) {
    return true;
  }

  return false;
});

defineRule("duration", (value: string) => {

  const regex = new RegExp('^(\\d{1,}:(00|0[1-9]|[1-5]\\d|59):(00|0[1-9]|[1-5]\\d|59))$');
  
  if (regex.test(value)) {
    return true;
  }

  if(numeric(value)) {
    return true;
  }
  
  return false;
})

//TODO: Трябва да се взема реактивно от стора когато сме готови с мултиезичността
setLocale("bg");
