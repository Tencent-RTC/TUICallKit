/// Module:   GenerateTestUserSig
///
/// Description: generates UserSig for testing. UserSig is a security signature designed by Tencent Cloud for its cloud services.
///           It is calculated based on `SDKAppID`, `UserID`, and `EXPIRETIME` using the HMAC-SHA256 encryption algorithm.
///
/// Attention: do not use the code below in your commercial app. This is because:
///
///            The code may be able to calculate UserSig correctly, but it is only for quick testing of the SDK’s basic features, not for commercial apps.
///            `SECRETKEY` in client code can be easily decompiled and reversed, especially on web.
///             Once your key is disclosed, attackers will be able to steal your Tencent Cloud traffic.
///
///            The correct method is to deploy the `UserSig` calculation code and encryption key on your project server so that your app can request from your server a `UserSig` that is calculated whenever one is needed.
///           Given that it is more difficult to hack a server than a client app, server-end calculation can better protect your key.
///
/// Reference: https://cloud.tencent.com/document/product/647/17275#Server

// ignore_for_file: slash_for_doc_comments

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

class GenerateTestUserSig {

  /**
   * Signature validity period, which should not be set too short
   * <p>
   * Unit: second
   * Default value: 604800 (7 days)
   */
  static int expireTime = 604800;

  static genTestSig(String userId, int sdkAppId, String secretKey) {
    int currTime = _getCurrentTime();
    String sig = '';
    Map<String, dynamic> sigDoc = <String, dynamic>{};
    sigDoc.addAll({
      "TLS.ver": "2.0",
      "TLS.identifier": userId,
      "TLS.sdkappid": sdkAppId,
      "TLS.expire": expireTime,
      "TLS.time": currTime,
    });

    sig = _hmacsha256(
      identifier: userId,
      currTime: currTime,
      expire: expireTime,
      sdkAppId: sdkAppId,
      secretKey: secretKey
    );
    sigDoc['TLS.sig'] = sig;
    String jsonStr = json.encode(sigDoc);
    List<int> compress = zlib.encode(utf8.encode(jsonStr));
    return _escape(content: base64.encode(compress));
  }

  static int _getCurrentTime() {
    return (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  }

  static String _hmacsha256({
    required String identifier,
    required int currTime,
    required int expire,
    required int sdkAppId,
    required String secretKey
  }) {
    int sdkappid = sdkAppId;
    String contentToBeSigned =
        "TLS.identifier:$identifier\nTLS.sdkappid:$sdkappid\nTLS.time:$currTime\nTLS.expire:$expire\n";
    Hmac hmacSha256 = Hmac(sha256, utf8.encode(secretKey));
    Digest hmacSha256Digest = hmacSha256.convert(utf8.encode(contentToBeSigned));
    return base64.encode(hmacSha256Digest.bytes);
  }

  static String _escape({
    required String content,
  }) {
    return content.replaceAll('\+', '*').replaceAll('\/', '-').replaceAll('=', '_');
  }
}
