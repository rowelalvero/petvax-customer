import 'package:get/get.dart';
import '../shop_dashboard/model/product_list_response.dart';
import 'package:pawlly/utils/library.dart';

class WishListScreen extends StatelessWidget {
  WishListScreen({super.key});

  final WishlistController wishlistController = Get.put(WishlistController());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBartitleText: locale.value.myWishlist,
      isLoading: wishlistController.isLoading,
      actions: const [
        CartIconBtn(),
      ],
      body: Obx(
        () => SnapHelperWidget<List<ProductItemData>>(
          future: wishlistController.getWishList.value,
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              retryText: locale.value.reload,
              imageWidget: const ErrorStateWidget(),
              onRetry: () {
                wishlistController.page(1);
                wishlistController.isLoading(true);
                wishlistController.init();
              },
            ).paddingSymmetric(horizontal: 16);
          },
          loadingWidget: const ProductListScreenShimmer(),
          onSuccess: (wishlist) {
            if (wishlist.isEmpty) {
              return NoDataWidget(
                title: locale.value.noProductsFound,
                imageWidget: const EmptyStateWidget(),
                subTitle: locale.value.thereAreCurrentlyNoItemsInYourWishlist,
                retryText: locale.value.reload,
                onRetry: () {
                  wishlistController.page(1);
                  wishlistController.isLoading(true);
                  wishlistController.init();
                },
              ).paddingSymmetric(horizontal: 16);
            }
            return AnimatedScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              onSwipeRefresh: () async {
                wishlistController.page(1);
                wishlistController.getWishListData(isFromSwipeRefresh: true);
                return await Future.delayed(const Duration(seconds: 2));
              },
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 50),
              listAnimationType: ListAnimationType.FadeIn,
              fadeInConfiguration:
                  FadeInConfiguration(duration: const Duration(seconds: 2)),
              scaleConfiguration: ScaleConfiguration(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 50)),
              onNextPage: () {
                if (!wishlistController.isLastPage.value) {
                  wishlistController.page(wishlistController.page.value + 1);
                  wishlistController.init();
                }
              },
              children: [
                AnimatedWrap(
                  runSpacing: 16,
                  spacing: 16,
                  listAnimationType: ListAnimationType.None,
                  children: List.generate(wishlist.length, (index) {
                    return ProductItemComponents(
                        productListData: wishlist[index], isFromWishList: true);
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
