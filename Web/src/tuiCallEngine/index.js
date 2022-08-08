import TIM from 'tim-js-sdk';
import { TUICallEngine, TUICallEvent, TUICallType } from 'tuicall-engine-webrtc';
import config from '../config';

export function createTUICallEngine() {
  const tim = TIM.create({
    SDKAppID: config.SDKAppID
  })

  const tuiCallEngine = TUICallEngine.createInstance({
    SDKAppID: config.SDKAppID,
    tim: tim,
  });
  return {
    tim,
    tuiCallEngine,
    TUICallEvent,
    TUICallType,
  }
}
