import 'package:flutter/services.dart';

class SeaBuddyCallAccess {
  const SeaBuddyCallAccess({
    required this.cameraAllowed,
    required this.microphoneAllowed,
  });

  final bool cameraAllowed;
  final bool microphoneAllowed;
}

class SeaBuddyCallPermissions {
  const SeaBuddyCallPermissions._();

  static const MethodChannel _channel = MethodChannel(
    'coastin/shore_call_permissions',
  );

  static Future<SeaBuddyCallAccess> requestAccess() async {
    try {
      final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'requestCallAccess',
      );
      return SeaBuddyCallAccess(
        cameraAllowed: response?['camera'] == true,
        microphoneAllowed: response?['microphone'] == true,
      );
    } on MissingPluginException {
      return const SeaBuddyCallAccess(
        cameraAllowed: true,
        microphoneAllowed: true,
      );
    } on PlatformException {
      return const SeaBuddyCallAccess(
        cameraAllowed: false,
        microphoneAllowed: false,
      );
    }
  }
}
