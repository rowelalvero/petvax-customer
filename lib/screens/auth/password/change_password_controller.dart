// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import '../../../utils/local_storage.dart';
import 'package:petvax/utils/library.dart';

class ChangePassController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController oldPasswordCont = TextEditingController();
  TextEditingController newpasswordCont = TextEditingController();
  TextEditingController confirmPasswordCont = TextEditingController();

  @override
  void onInit() {
    oldPasswordCont.text =
        getValueFromLocal(SharedPreferenceConst.USER_PASSWORD);
    super.onInit();
  }

  saveForm() async {
    isLoading(true);
    if (getValueFromLocal(SharedPreferenceConst.USER_PASSWORD) !=
        oldPasswordCont.text.trim()) {
      return toast(locale.value.yourOldPasswordDoesnT);
    } else if (newpasswordCont.text.trim() != confirmPasswordCont.text.trim()) {
      return toast(locale.value.yourNewPasswordDoesnT);
    } else if ((oldPasswordCont.text.trim() == newpasswordCont.text.trim()) &&
        oldPasswordCont.text.trim() == confirmPasswordCont.text.trim()) {
      return toast(locale.value.oldAndNewPassword);
    }
    hideKeyBoardWithoutContext();

    Map<String, dynamic> req = {
      'old_password': getValueFromLocal(SharedPreferenceConst.USER_PASSWORD),
      'new_password': confirmPasswordCont.text.trim(),
    };

    await AuthServiceApis.changePasswordAPI(request: req).then((value) async {
      isLoading(false);
      setValueToLocal(
          SharedPreferenceConst.USER_PASSWORD, confirmPasswordCont.text.trim());
      loginUserData.value.apiToken = value.data.apiToken;
      Get.to(() => const PasswordSetSuccess());
    }).catchError((e) {
      isLoading(false);
      toast(e.toString(), print: true);
    });
  }
}
