// Type augmentation for the `uni` global object.
// The base type from the build toolchain only exposes the event-bus
// methods ($on / $off / $emit). Extend it so TS recognises common
// uni-app APIs used in this demo.

interface UniShowToastOptions {
  title: string;
  icon?: 'success' | 'loading' | 'none' | 'error';
  image?: string;
  mask?: boolean;
  duration?: number;
}

interface UniNavigateToOptions {
  url: string;
  success?: (res: any) => void;
  fail?: (err: any) => void;
  complete?: (res: any) => void;
}

interface UniNavigateBackOptions {
  delta?: number;
  success?: (res: any) => void;
  fail?: (err: any) => void;
  complete?: (res: any) => void;
}

declare const uni: {
  $on(eventName: string, callback: (data?: any) => void): void;
  $off(eventName: string, callback?: (data?: any) => void): void;
  $emit(eventName: string, data?: any): void;
  showToast(options: UniShowToastOptions): void;
  hideToast(): void;
  showModal(options: any): Promise<any>;
  navigateTo(options: UniNavigateToOptions): void;
  navigateBack(options?: UniNavigateBackOptions): void;
  redirectTo(options: UniNavigateToOptions): void;
  switchTab(options: UniNavigateToOptions): void;
  getSystemInfoSync(): any;
  [key: string]: any;
};

// wx global is declared in TUICallKit/global.d.ts
