import 'package:wesal/logic/services/app_constants.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoServices {
  /// on App's user login
  static Future<void> onUserLogin({
    required String userId,
    required String userName,
  }) async {
    /// تأكد أن القيم بالفعل String
    final String finalUserId = userId.toString();
    final String finalUserName = userName.toString();

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: AppConstants.appId,
      appSign: AppConstants.appSign,
      userID: finalUserId, // لازم String
      userName: finalUserName, // لازم String
      plugins: [ZegoUIKitSignalingPlugin()],
    );
  }

  /// on App's user logout
  static void onUserLogout() {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }

  // call
  static callWithZego({
    required bool isVideoCall,
    required String userId,
    required String userName,
  }) {
    ZegoUIKitPrebuiltCallInvitationService().send(
      resourceID: AppConstants.resourceId,
      invitees: [ZegoCallUser(userId, userName)],
      isVideoCall: isVideoCall,
    );
  }
}
