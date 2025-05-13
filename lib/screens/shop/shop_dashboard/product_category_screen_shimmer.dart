import 'package:petvax/utils/library.dart';

class ProductCategoryScreenShimmer extends StatelessWidget {
  const ProductCategoryScreenShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScreenShimmer(
        shimmerComponent: CategoryItemComponentsShimmer());
  }
}
