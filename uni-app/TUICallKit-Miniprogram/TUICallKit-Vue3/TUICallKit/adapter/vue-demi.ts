// Vue compatibility layer for both Vue 2 (via @vue/composition-api) and Vue 3.
// UniApp conditional compilation (#ifdef VUE2 / #ifdef VUE3) is used to resolve
// the import source at build time.
//
// In Vue 2 projects, <script setup> is supported via `unplugin-vue2-script-setup`
// which is already included in the UniApp build toolchain (Vue2 mode).
//
// Usage: import { ref, computed, watch, ... } from '../adapter/vue-demi';

let vueVersion: number;

// #ifndef VUE3
export * from '@vue/composition-api';
vueVersion = 2;
// #endif

// #ifdef VUE3
export * from 'vue';
vueVersion = 3;
// #endif

export { vueVersion };
