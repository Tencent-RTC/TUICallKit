import TIM from 'tim-js-sdk';
import { TUICallEngine, TUICallEvent, TUICallType } from 'tuicall-engine-webrtc';
import { SDKAPPID } from "../../public/debug/GenerateTestUserSig";

export function createTUICallEngine() {
  const tim = TIM.create({
    SDKAppID: SDKAPPID
  })

  const tuiCallEngine = TUICallEngine.createInstance({
    SDKAppID: SDKAPPID,
    tim: tim,
  });
  return {
    tim,
    tuiCallEngine,
    TUICallEvent,
    TUICallType,
  }
}
