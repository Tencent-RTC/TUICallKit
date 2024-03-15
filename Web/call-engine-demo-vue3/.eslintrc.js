module.exports = {
  env: {
    browser: true,
    es2021: true,
    'vue/setup-compiler-macros': true,
  },
  extends: [
    'eslint-config-tencent',
    'plugin:vue/vue3-recommended',
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    parser: '@typescript-eslint/parser',
    sourceType: 'module',
  },
  plugins: [
    'vue',
    '@typescript-eslint',
  ],
  rules: {
    'no-unused-vars': 'off',
    'no-nested-ternary': 'off',
    '@typescript-eslint/no-unused-vars': ['error'],
    'vue/max-attributes-per-line': 'off',
    'vue/html-self-closing': 'off',
    'vue/multi-word-component-names': 'off',
    'vue/singleline-html-element-content-newline': 'off',
    'comma-dangle': ['error', {
      arrays: 'always-multiline',
      objects: 'always-multiline',
      imports: 'always-multiline',
      exports: 'always-multiline',
      functions: 'always-multiline',
    }],
  },
};
