以下 SDK 版本存在接口变更或 `Breaking Change`，升级时需要注意。

## v1.3.0 版本

1. v1.3.0 及以后版本，主动调用 `TUICallKitServer.call()` 或 `TUICallKitServer.groupCall()` 时，如果遇到报错，不会再调用 `beforeCalling` 回调。请直接使用 try catch 捕获错误。

    ```javascript
    // v1.3.0 之前版本
    await TUICallKitServer.call({ userID, type });
    // TUICallKitServer.call() 报错时会执行 beforeCalling
    function beforeCalling(type: string, error: any) {}

    // v1.3.0 及以后版本
    try {
        await TUICallKitServer.call({ userID, type });
        console.log("call success!");
    } catch (error: any) {
        // 遇到 call 内部错误，可以在此进行捕获。
        console.error("call error!", error);
    }
    // TUICallKitServer.call() 报错时不会执行 beforeCalling
    function beforeCalling(type: string, error: any) {}
    ```