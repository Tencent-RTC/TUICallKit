import { ref, computed } from '../adapter/vue-demi';
import {
  TUIStore,
  StoreName,
  NAME,
  FeatureButton,
  LayoutMode,
} from './TUICallService/index';
import { ICustomUIConfig } from './TUICallService/const/call';

// Reactive customUIConfig state consumed by CallView / GroupCallView.
const customUIConfig = ref<ICustomUIConfig>(
  TUIStore.getData(StoreName.CALL, NAME.CUSTOM_UI_CONFIG) || { button: {}, viewBackground: {}, layoutMode: LayoutMode.RemoteInLargeView },
);

TUIStore?.watch(StoreName.CALL, {
  [NAME.CUSTOM_UI_CONFIG]: _handleCustomUIConfigChange,
});

function _handleCustomUIConfigChange(value: ICustomUIConfig) {
  customUIConfig.value = value;
}

// Set of feature buttons whose `show` is explicitly set to false.
const hiddenButtons = computed(() => {
  const btns = customUIConfig.value?.button || {};
  const hidden = new Set<FeatureButton>();
  for (const [key, cfg] of Object.entries(btns)) {
    if (cfg && cfg.show === false) {
      hidden.add(key as FeatureButton);
    }
  }
  return hidden;
});

// Current layout mode: whether the local or remote stream is in the large view.
const layoutMode = computed(() => customUIConfig.value?.layoutMode ?? LayoutMode.RemoteInLargeView);

// View background image map: userId -> url.
const viewBackground = computed(() => customUIConfig.value?.viewBackground || {});

function useUIConfigState() {
  return {
    hiddenButtons,
    layoutMode,
    viewBackground,
  };
}

export { useUIConfigState, FeatureButton, LayoutMode };
