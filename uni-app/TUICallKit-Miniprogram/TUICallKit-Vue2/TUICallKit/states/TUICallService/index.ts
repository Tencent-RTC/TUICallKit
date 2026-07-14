import TUICallService, { TUIStore, uiDesign } from './CallService/index';
import {
  StoreName,
  NAME,
  CallRole,
  CallStatus,
  FeatureButton,
  LayoutMode,
} from './const/index';
import { t } from './locales/index';

// 实例化
const TUICallKitAPI = TUICallService.getInstance();
// 输出产物
export {
  TUIStore,
  StoreName,
  TUICallKitAPI,
  NAME,
  CallStatus,
  CallRole,
  t,
  FeatureButton,
  LayoutMode,
  uiDesign,
};
