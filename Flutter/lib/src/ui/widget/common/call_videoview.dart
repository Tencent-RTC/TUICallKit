import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

class CallVideoView extends StatefulWidget {
  ///
  /// This event is triggered when a platform view is created.
  ///
  final PlatformViewCreatedCallback? onPlatformViewCreated;

  /// Constructs the [CallVideoView].
  const CallVideoView({
    Key? key,
    this.onPlatformViewCreated,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CallVideoViewState();
  }
}

class CallVideoViewState extends State<CallVideoView> {
  int? _id;
  MethodChannel? _channel;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Text('Web is not yet supported by the plugin');
    }
    const viewType = 'TUICallKitVideoView';
    final creationParams = {};

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      if (_id != null) {
        return Texture(textureId: _id!);
      }
      return Container();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: UiKitView(
          viewType: viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: AndroidView(
          viewType: viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else {
      return Text('$defaultTargetPlatform is not yet supported by the plugin');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(CallVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _channel?.invokeMethod("destroyVideoView", {});
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _id = id;
    _channel = MethodChannel('tuicall_kit/video_view_$id');
    widget.onPlatformViewCreated?.call(id);
  }
}
