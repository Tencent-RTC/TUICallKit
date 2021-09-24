package com.tencent.qcloud.tuicore;

import android.content.Context;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIObject;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;

import java.util.List;

/**
 * TUI 插件核心类，主要负责 TUI 插件间数据的传递，通知的广播，功能的扩展等
 */
public class TUICore {
    private static final String TAG = TUICore.class.getSimpleName();

    /**
     * 注册 Service 服务
     * @param serviceName 服务名
     * @param service service 服务对象
     */
    public static void registerService(String serviceName, ITUIService service) {
        ServiceManager.getInstance().registerService(serviceName, service);
    }

    /**
     *  唤起 Service 服务
     *
     *  @param serviceName 服务名
     *  @param method 方法名
     *  @param param 透传给服务方的数据
     *  @return 返回对象
     */
    public static Object callService(String serviceName, String method, Bundle param) {
        return ServiceManager.getInstance().callService(serviceName, method, param);
    }

    /**
     *  创建实例
     *
     *  @param className 类名, 该类必须实现 {@link ITUIObject} 接口
     *  @param param 透传给 "class" 的数据
     */
    public static ITUIObject createObject(String className, Bundle param) {
        return ObjectManager.getInstance().createObject(className, param);
    }

    /**
     * 启动 Activity
     * @param activityName Activity 名，例如 "TUIGroupChatActivity"
     * @param param 传给 Activity 的参数
     */
    public static void startActivity(String activityName, Bundle param) {
        startActivity(null, activityName, param, -1);
    }

    /**
     * 启动 Activity
     * @param starter 启动者，可以是 {@link Context}，也可以是 {@link Fragment}
     * @param activityName Activity 名，例如 "TUIGroupChatActivity"
     * @param param 传给 Activity 的参数
     */
    public static void startActivity(@Nullable Object starter, String activityName, Bundle param) {
        startActivity(starter, activityName, param, -1);
    }

    /**
     * 启动 Activity
     * @param starter 启动者，可以是 {@link Context}，也可以是 {@link Fragment}
     * @param activityName Activity 名，例如 "TUIGroupChatActivity"
     * @param param 传给 Activity 的参数
     * @param requestCode 传给 Activity 的请求值，用来在 Activity 结束时在启动者的 onActivityResult 方法中返回结果，大于等于 0 有效。
     */
    public static void startActivity(@Nullable Object starter, String activityName, Bundle param, int requestCode) {
        TUIRouter.Navigation navigation = TUIRouter.getInstance().setDestination(activityName).putExtras(param);
        if (starter instanceof Fragment) {
            navigation.navigate((Fragment) starter, requestCode);
        } else if (starter instanceof Context) {
            navigation.navigate((Context) starter, requestCode);
        } else {
            navigation.navigate((Context) null, requestCode);
        }
    }

    /**
     *  注册通知
     */
    public static void registerEvent(String key, String subKey, ITUINotification notification) {
        EventManager.getInstance().registerEvent(key, subKey, notification);
    }

    /**
     *  移除指定 Key 和 subKey 的所有通知
     */
    public static void removeEvent(String key, String subKey, ITUINotification notification) {
        EventManager.getInstance().removeEvent(key, subKey, notification);
    }

    /**
     *  移除指定通知对象的所有通知
     */
    public static void removeEvent(ITUINotification notification) {
        EventManager.getInstance().removeEvent(notification);
    }

    /**
     *  发起通知
     */
    public static void notifyEvent(String key, String subKey, Bundle param) {
        EventManager.getInstance().notifyEvent(key, subKey, param);
    }

    /**
     *  注册扩展
     */
    public static void registerExtension(String key, ITUIExtension extension) {
        ExtensionManager.getInstance().registerExtension(key, extension);
    }

    /**
     *  移除扩展
     */
    public static void removeExtension(String key, ITUIExtension extension) {
        ExtensionManager.getInstance().removeExtension(key, extension);
    }

    /**
     *  获取扩展
     */
    public static List<Bundle> getExtensionObjects(String key, Bundle param) {
        return ExtensionManager.getInstance().getExtensionObjects(key, param);
    }

}
