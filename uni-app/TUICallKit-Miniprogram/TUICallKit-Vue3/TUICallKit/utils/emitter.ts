type EventListenerFn = (...args: any[]) => void;
type EventListener = {
  fn: EventListenerFn;
  context: any;
};

export default class EventEmitter {
  private listeners: { [name: string]: EventListener[] } = {};

  // Register event listener
  on(eventName: string, fn: EventListenerFn, context?: any): void {
    if (!this.listeners[eventName]) {
      this.listeners[eventName] = [];
    }
    this.listeners[eventName].push({ fn, context });
  }

  // Remove event listener
  off(eventName: string, fn: EventListenerFn, context?: any): void {
    if (fn) {
      this.listeners[eventName] = this.listeners[eventName]?.filter((listener) => {
        const isSameFunction = listener.fn === fn;
        const isSameContext = !context || listener.context === context;
        return !(isSameFunction && isSameContext);
      });
    }
  }

  // Emit event
  emit(eventName: string, ...args: any[]): void {
    const listeners = this.listeners[eventName];
    if (listeners) {
      listeners.forEach((listener) => {
        const { fn, context = undefined } = listener;
        fn.apply(context, args);
      });
    }
  }

  once(eventName: string, fn: EventListenerFn, context: any): void {
    const wrappedListener = (...args: any[]) => {
      fn.apply(context, args);
      this.off(eventName, wrappedListener);
    };
    this.on(eventName, wrappedListener);
  }
}
