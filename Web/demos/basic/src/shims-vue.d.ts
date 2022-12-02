/* eslint-disable */
declare module "*.vue" {
  import type { DefineComponent } from "vue";
  const component: DefineComponent<{}, {}, any>;
  export default component;
}

declare module "*.svg" {
  const src: string;
  export default src;
}

declare module "vue3-clipboard" {
  import { copyText } from "vue3-clipboard";
  export { copyText };
}
