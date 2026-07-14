import { ButtonState, FeatureButton, LayoutMode, NAME, StoreName } from '../const/index';
import { deepClone } from '../utils/common-utils';

export interface IUIDesign {
  updateViewBackgroundUserId: (viewType: 'local' | 'remote') => void;
  hideFeatureButton: (buttonName: FeatureButton) => void;
  setLocalViewBackgroundImage: (url: string) => void;
  setRemoteViewBackgroundImage: (userId: string, url: string) => void;
  setLayoutMode: (layoutMode: LayoutMode) => void;
  setCameraDefaultState: (isOpen: boolean) => void;
  setEngineInstance: (engineInstance: any) => void;
  setTUIStore: (tuiStore: any) => void;
}

const DEFAULT_LOCAL_USER_ID = '_local_user_id';

// Minimal empty check: covers undefined / null / empty string, which is all
// the view-background bookkeeping below relies on.
function isEmpty(value: any): boolean {
  return value === undefined || value === null || value === '';
}

/**
 * UIDesign centralizes the TUICallKit UI-customization interfaces
 * (hideFeatureButton / setLayoutMode / view background images /
 * setCameraDefaultState). It only writes to the CALL store's
 * `customUIConfig`; the call views read that config to render.
 */
export class UIDesign implements IUIDesign {
  static instance: IUIDesign;
  static getInstance() {
    if (!UIDesign.instance) {
      UIDesign.instance = new UIDesign();
    }
    return UIDesign.instance;
  }

  private _viewConfig = {
    viewBackground: {
      local: {},
      remote: {},
    },
  };
  private _isSetViewBackgroundConfig = { remote: false, local: false };
  private _tuiCallEngine: any = null;
  private _tuiStore: any = null;

  private _updateViewBackground() {
    const customUIConfig = this._tuiStore?.getData(StoreName.CALL, NAME.CUSTOM_UI_CONFIG);
    const { userId } = this._tuiStore?.getData(StoreName.CALL, NAME.LOCAL_USER_INFO);

    if (Object.keys(this._viewConfig.viewBackground.remote).includes(userId)) {
      delete this._viewConfig.viewBackground.remote[userId];
    }

    this._tuiStore?.update(
      StoreName.CALL,
      NAME.CUSTOM_UI_CONFIG,
      {
        ...customUIConfig,
        viewBackground: {
          ...this._viewConfig.viewBackground.remote,
          ...this._viewConfig.viewBackground.local,
        },
      },
    );
  }

  setEngineInstance(engineInstance: any) {
    this._tuiCallEngine = engineInstance;
  }
  setTUIStore(tuiStore: any) {
    this._tuiStore = tuiStore;
  }

  public updateViewBackgroundUserId(name: 'local' | 'remote') {
    if (name === 'local') {
      const { userId } = this._tuiStore?.getData(StoreName.CALL, NAME.LOCAL_USER_INFO);

      if (Object.keys(this._viewConfig.viewBackground.remote).includes(userId)) {
        delete this._viewConfig.viewBackground.remote[userId];
        this._updateViewBackground();
      }

      if (!this._isSetViewBackgroundConfig.local) {
        return;
      }

      const localViewBackgroundConfig = this._viewConfig.viewBackground.local;
      const url = localViewBackgroundConfig[userId] || localViewBackgroundConfig[DEFAULT_LOCAL_USER_ID];
      localViewBackgroundConfig[userId] = localViewBackgroundConfig[DEFAULT_LOCAL_USER_ID];
      this._viewConfig.viewBackground.local = { [userId]: url };

      this._updateViewBackground();
    } else {
      const remoteViewBackgroundConfig = this._viewConfig.viewBackground.remote;

      if (this._isSetViewBackgroundConfig.remote && Object.keys(remoteViewBackgroundConfig).includes('*')) {
        const remoteUserInfoList = this._tuiStore?.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST);
        const remoteUserIdList = remoteUserInfoList.map((item: any) => item.userId);
        remoteUserIdList.forEach((userId: string) => {
          if (!Object.keys(remoteViewBackgroundConfig).includes(userId)) {
            remoteViewBackgroundConfig[userId] = remoteViewBackgroundConfig['*'];
          }
        });

        this._viewConfig.viewBackground.remote = remoteViewBackgroundConfig;
        this._updateViewBackground();
      }
    }
  }

  public hideFeatureButton(buttonName: FeatureButton) {
    this._tuiCallEngine?.reportLog?.({
      name: 'TUICallKit.hideFeatureButton.start',
      data: { buttonName },
    });
    const customUIConfig = this._tuiStore?.getData(StoreName.CALL, NAME.CUSTOM_UI_CONFIG);
    this._tuiStore?.update(
      StoreName.CALL,
      NAME.CUSTOM_UI_CONFIG,
      {
        ...customUIConfig,
        button: {
          ...customUIConfig.button,
          [buttonName]: { ...(customUIConfig.button?.[buttonName] || {}), show: false },
        },
      },
    );
  }

  public setLocalViewBackgroundImage(url: string) {
    this._tuiCallEngine?.reportLog?.({
      name: 'TUICallKit.setLocalViewBackgroundImage.start',
      data: { url },
    });
    this._isSetViewBackgroundConfig.local = true;
    let { userId } = this._tuiStore?.getData(StoreName.CALL, NAME.LOCAL_USER_INFO);

    if (isEmpty(userId)) {
      userId = DEFAULT_LOCAL_USER_ID;
    }

    this._viewConfig.viewBackground.local = { [userId]: url };
    this._updateViewBackground();
  }

  public setRemoteViewBackgroundImage(userId: string, url: string) {
    this._tuiCallEngine?.reportLog?.({
      name: 'TUICallKit.setRemoteViewBackgroundImage.start',
      data: { userId, url },
    });
    this._isSetViewBackgroundConfig.remote = true;
    if (userId === '*') {
      this._viewConfig.viewBackground.remote = {};
    }

    this._viewConfig.viewBackground.remote[userId] = url;
    this._updateViewBackground();
  }

  public setLayoutMode(layoutMode: LayoutMode) {
    this._tuiCallEngine?.reportLog?.({
      name: 'TUICallKit.setLayoutMode.start',
      data: { layoutMode },
    });
    const customUIConfig = this._tuiStore?.getData(StoreName.CALL, NAME.CUSTOM_UI_CONFIG);
    this._tuiStore?.update(
      StoreName.CALL,
      NAME.CUSTOM_UI_CONFIG,
      {
        ...customUIConfig,
        layoutMode,
      },
    );
  }

  public setCameraDefaultState(isOpen: boolean) {
    this._tuiCallEngine?.reportLog?.({
      name: 'TUICallKit.setCameraDefaultState.start',
      data: { isOpen },
    });
    const customUIConfig = deepClone(this._tuiStore?.getData(StoreName.CALL, NAME.CUSTOM_UI_CONFIG));

    if (!Object.keys(customUIConfig.button).includes(FeatureButton.Camera)) {
      customUIConfig.button[FeatureButton.Camera] = {};
    }
    customUIConfig.button[FeatureButton.Camera].state = isOpen ? ButtonState.Open : ButtonState.Close;
    this._tuiStore?.update(StoreName.CALL, NAME.CUSTOM_UI_CONFIG, customUIConfig);
  }
}
