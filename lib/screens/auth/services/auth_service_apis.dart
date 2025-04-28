import 'package:http/http.dart';
import '../../../utils/local_storage.dart';
import '../model/change_password_res.dart';
import 'package:pawlly/utils/library.dart';

class AuthServiceApis {
  static Future<RegUserResp> createUser({required Map request}) async {
    return RegUserResp.fromJson(await handleResponse(await buildHttpResponse(
        APIEndPoints.register,
        request: request,
        method: HttpMethodType.POST)));
  }

  static Future<LoginResponse> loginUser(
      {required Map request, bool isSocialLogin = false}) async {
    return LoginResponse.fromJson(await handleResponse(await buildHttpResponse(
        isSocialLogin ? APIEndPoints.socialLogin : APIEndPoints.login,
        request: request,
        method: HttpMethodType.POST)));
  }

  static Future<ChangePassRes> changePasswordAPI({required Map request}) async {
    return ChangePassRes.fromJson(await handleResponse(await buildHttpResponse(
        APIEndPoints.changePassword,
        request: request,
        method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> forgotPasswordAPI(
      {required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.forgotPassword,
            request: request, method: HttpMethodType.POST)));
  }

  static Future<List<NotificationData>> getNotificationDetail({
    int page = 1,
    int perPage = 10,
    required List<NotificationData> notifications,
    Function(bool)? lastPageCallBack,
  }) async {
    if (isLoggedIn.value) {
      final notificationRes = NotificationRes.fromJson(await handleResponse(
          await buildHttpResponse(
              "${APIEndPoints.getNotification}?per_page=$perPage&page=$page",
              method: HttpMethodType.GET)));
      if (page == 1) notifications.clear();
      notifications.addAll(notificationRes.notificationData);
      lastPageCallBack
          ?.call(notificationRes.notificationData.length != perPage);
      return notifications;
    } else {
      return [];
    }
  }

  static Future<NotificationData> clearAllNotification() async {
    return NotificationData.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.clearAllNotification,
            method: HttpMethodType.GET)));
  }

  static Future<NotificationData> removeNotification(
      {required String notificationId}) async {
    return NotificationData.fromJson(await handleResponse(
        await buildHttpResponse(
            '${APIEndPoints.removeNotification}?id=$notificationId',
            method: HttpMethodType.GET)));
  }

  static Future<void> clearData({bool isFromDeleteAcc = false}) async {
    GoogleSignIn().signOut();
    PushNotificationService().unsubscribeFirebaseTopic();

    if (isFromDeleteAcc) {
      localStorage.erase();
      isLoggedIn(false);
      loginUserData(UserData());
    } else {
      final tempEmail = loginUserData.value.email;
      final tempPASSWORD =
          getValueFromLocal(SharedPreferenceConst.USER_PASSWORD);
      final tempIsRememberMe =
          getValueFromLocal(SharedPreferenceConst.IS_REMEMBER_ME);
      final tempUserName = loginUserData.value.userName;

      localStorage.erase();
      isLoggedIn(false);
      loginUserData(UserData());

      setValueToLocal(SharedPreferenceConst.FIRST_TIME, true);
      setValueToLocal(SharedPreferenceConst.USER_EMAIL, tempEmail);
      setValueToLocal(SharedPreferenceConst.USER_NAME, tempUserName);

      if (tempPASSWORD is String) {
        setValueToLocal(SharedPreferenceConst.USER_PASSWORD, tempPASSWORD);
      }
      if (tempIsRememberMe is bool) {
        setValueToLocal(SharedPreferenceConst.IS_REMEMBER_ME, tempIsRememberMe);
      }
    }
  }

  static Future<BaseResponseModel> logoutApi() async {
    return BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.logout,
            method: HttpMethodType.GET)));
  }

  static Future<BaseResponseModel> deleteAccountCompletely() async {
    return BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.deleteUserAccount,
            request: {}, method: HttpMethodType.POST)));
  }

  static Future<void> getAppConfigurations(
      {bool forceConfigSync = false, bool isFromDashboard = false}) async {
    DateTime currentTimeStamp = DateTime.timestamp();
    DateTime lastSyncedTimeStamp = DateTime.fromMillisecondsSinceEpoch(
        getValueFromLocal(
                SharedPreferenceConst.LAST_APP_CONFIGURATION_CALL_TIME) ??
            0);
    DateTime fiveMinutesLater =
        lastSyncedTimeStamp.add(const Duration(minutes: 5));

    if (forceConfigSync || currentTimeStamp.isAfter(fiveMinutesLater)) {
      try {
        ConfigurationResponse configData = ConfigurationResponse.fromJson(
          await handleResponse(
            await buildHttpResponse(
              '${APIEndPoints.appConfiguration}?is_authenticated=${(getValueFromLocal(SharedPreferenceConst.IS_LOGGED_IN) == true).getIntBool()}',
              request: {},
              method: HttpMethodType.GET,
            ),
          ),
        );

        appCurrency(configData.currency);
        appConfigs(configData);

        /// Place ChatGPT Key Here
        chatGPTAPIkey = configData.chatgptKey;

        if (getValueFromLocal(SharedPreferenceConst.IS_LOGGED_IN) == true &&
            appConfigs.value.isUserPushNotification &&
            isFromDashboard) {
          await Future.delayed(const Duration(seconds: 1));
        }

        setValueToLocal(SharedPreferenceConst.LAST_APP_CONFIGURATION_CALL_TIME,
            DateTime.timestamp().millisecondsSinceEpoch);
        setValueToLocal(
            APICacheConst.APP_CONFIGURATION_RESPONSE, configData.toJson());
      } catch (e) {
        rethrow;
      }
    } else {
      log('App Configurations was synced recently');
    }
  }

  static Future<GetUserProfileResponse> viewProfile({int? id}) async {
    var res = GetUserProfileResponse.fromJson(await handleResponse(
        await buildHttpResponse(
            '${APIEndPoints.userDetail}?id=${id ?? loginUserData.value.id}',
            method: HttpMethodType.GET)));
    return res;
  }

  static Future<dynamic> updateProfile({
    File? imageFile,
    String firstName = '',
    String lastName = '',
    String mobile = '',
    String address = '',
    Function(dynamic)? onSuccess,
  }) async {
    if (isLoggedIn.value) {
      MultipartRequest multiPartRequest =
          await getMultiPartRequest(APIEndPoints.updateProfile);
      if (firstName.isNotEmpty)
        multiPartRequest.fields[UserKeys.firstName] = firstName;
      if (lastName.isNotEmpty)
        multiPartRequest.fields[UserKeys.lastName] = lastName;
      if (mobile.isNotEmpty) multiPartRequest.fields[UserKeys.mobile] = mobile;
      if (address.isNotEmpty)
        multiPartRequest.fields[UserKeys.address] = address;

      if (imageFile != null) {
        multiPartRequest.files.add(await MultipartFile.fromPath(
            UserKeys.profileImage, imageFile.path));
      }

      multiPartRequest.headers.addAll(buildHeaderTokens());

      await sendMultiPartRequest(
        multiPartRequest,
        onSuccess: (data) async {
          onSuccess?.call(data);
        },
        onError: (error) {
          throw error;
        },
      ).catchError((error) {
        throw error;
      });
    }
  }
}
