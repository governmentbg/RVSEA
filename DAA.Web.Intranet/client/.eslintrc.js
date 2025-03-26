module.exports = {
  root: true,
  env: {
    node: true,
  },
  extends: [
    "plugin:vue/vue3-essential",
    "eslint:recommended",
    "@vue/typescript/recommended",
  ],
  parserOptions: {
    ecmaVersion: 2020,
  },
  rules: {
    "no-console": process.env.NODE_ENV === "production" ? "warn" : "off",
    "no-debugger": process.env.NODE_ENV === "production" ? "error" : "off",
    "@typescript-eslint/no-non-null-assertion": "off",
    "@typescript-eslint/no-this-alias": "off",
    "vue/no-multiple-template-root": "off",
    "@typescript-eslint/no-inferrable-types": "off",
    "vue/no-mutating-props": "error",
    "vue/no-unused-components": "error",
    "no-unused-vars": "off",
    "no-extra-boolean-cast": "warn",
    "vue/multi-word-component-names": "off",
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/no-explicit-any": "error",
    "vue/no-reserved-component-names": "off"
  },
};
