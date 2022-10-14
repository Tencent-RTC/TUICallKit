/* eslint-disable */
declare module "*.vue" {
  import type { DefineComponent } from "vue";
  const component: DefineComponent<{}, {}, any>;
  export default component;
}

declare module "tim-js-sdk" {
  import TIM from "tim-js-sdk";
  export default TIM;
}

declare module "*.svg" {
  const src: string;
  export default src;
}

declare module "vue3-clipboard" {
  import { copyText } from "vue3-clipboard";
  export { copyText };
}
