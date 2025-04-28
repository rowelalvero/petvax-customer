import 'package:get/get.dart';
import 'package:pawlly/utils/library.dart';

class PetSitterController extends GetxController {
  Rx<Future<RxList<EmployeeModel>>> getPetSitterList =
      Future(() => RxList<EmployeeModel>()).obs;
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxList<EmployeeModel> petSittersList = RxList();
  RxInt page = 1.obs;

  @override
  void onInit() {
    init(showloader: false);
    super.onInit();
  }

  Future<void> init({bool showloader = true}) async {
    if (showloader) {
      isLoading(true);
    }
    await getPetSitterList(PetServiceFormApis.getPetSitters(
      role: EmployeeKeyConst.petSitter,
      petSittersList: petSittersList,
      page: page.value,
      lastPageCallBack: (p0) {
        isLastPage(p0);
      },
    )).whenComplete(() => isLoading(false));
  }
}
