import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/ui/widget/inviteuser/invite_user_widget.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_kit_widget.dart';

class TUICallKitNavigatorObserver extends NavigatorObserver {
  static final TUICallKitNavigatorObserver _instance =
      TUICallKitNavigatorObserver();
  static bool isClose = false;
  static CallPage currentPage = CallPage.none;

  static TUICallKitNavigatorObserver getInstance() {
    return _instance;
  }

  TUICallKitNavigatorObserver() {
    _bootInit();
  }

  void enterCallingPage() async {
    currentPage = CallPage.callingPage;
    TUICallKitNavigatorObserver.getInstance()
        .navigator
        ?.push(MaterialPageRoute(builder: (widget) {
      return TUICallKitWidget(close: () {
        if (!isClose) {
          isClose = true;
          TUICallKitPlatform.instance.stopForegroundService();
          TUICallKitPlatform.instance.stopRing();
          TUICallKitNavigatorObserver.getInstance().exitCallingPage();
        }
      });
    }));
    isClose = false;
  }

  void exitCallingPage() async {
    if (currentPage == CallPage.inviteUserPage) {
      TUICallKitNavigatorObserver.getInstance().navigator?.pop();
      TUICallKitNavigatorObserver.getInstance().navigator?.pop();
    } else if (currentPage == CallPage.callingPage) {
      TUICallKitNavigatorObserver.getInstance().navigator?.pop();
    }
    currentPage = CallPage.none;
  }

  void enterInviteUserPage() {
    if (currentPage == CallPage.callingPage) {
      currentPage = CallPage.inviteUserPage;
      TUICallKitNavigatorObserver.getInstance()
          .navigator
          ?.push(MaterialPageRoute(builder: (widget) {
        return const InviteUserWidget();
      }));
    }
  }

  void exitInviteUserPage() {
    currentPage = CallPage.callingPage;
    TUICallKitNavigatorObserver.getInstance().navigator?.pop();
  }

  static void _bootInit() {
    TUICallKitPlatform.instance;
  }
}

enum CallPage { none, callingPage, inviteUserPage }
