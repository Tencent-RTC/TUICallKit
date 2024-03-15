import TIM from 'tim-js-sdk';

let tim: any = null;

export default function useTimInstance(sdkAppId?: number) {
  if (!tim && sdkAppId) {
    tim = TIM.create({ SDKAppID: sdkAppId });
  }

  return tim;
}
