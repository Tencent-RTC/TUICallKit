// Uni-app global API declaration — used for cross-module event bus communication.
declare const uni: {
  $on(eventName: string, callback: (data?: any) => void): void;
  $off(eventName: string, callback?: (data?: any) => void): void;
  $emit(eventName: string, data?: any): void;
};
