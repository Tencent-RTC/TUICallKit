import EventEmitter from './emitter';

type TCallbackFn = (params: any) => void;

class TUIStore {
  private _eventEmitter: EventEmitter | null = null;

  constructor() {
    this._eventEmitter = new EventEmitter();
  }

  subscribeEvent(eventName: string, callback: TCallbackFn, context?: any) {
    this._eventEmitter?.on(eventName, callback, context);
  }

  unSubscribeEvent(eventName: string, callback: TCallbackFn, context?: any) {
    this._eventEmitter?.off(eventName, callback, context);
  }

  emitEvent(event: string, data?: any) {
    this._eventEmitter?.emit(event, data);
  }

  getEventEmitter() {
    return this._eventEmitter;
  }

  rest() {
    this._eventEmitter = null;
  }
}

export default new TUIStore();
