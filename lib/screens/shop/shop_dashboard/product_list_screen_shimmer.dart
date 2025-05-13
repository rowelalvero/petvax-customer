import 'package:petvax/utils/library.dart';

class ProductListScreenShimmer extends StatelessWidget {
  const ProductListScreenShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScreenShimmer(
        shimmerComponent: FeaturedProductItemComponentShimmer());
  }
}
