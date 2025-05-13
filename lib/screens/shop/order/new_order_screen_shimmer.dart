import 'package:petvax/utils/library.dart';

class NewOrderScreenShimmer extends StatelessWidget {
  const NewOrderScreenShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScreenShimmer(shimmerComponent: NewOrderCardShimmer());
  }
}
