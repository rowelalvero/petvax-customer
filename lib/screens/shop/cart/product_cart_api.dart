import '../shop_dashboard/model/product_list_response.dart';
import 'package:petvax/utils/library.dart';

class ProductCartApi {
  static Future<CartListResponse> addToCart(request) async {
    return CartListResponse.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.addToCart,
            request: request, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> updateCart(request) async {
    return BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.updateCart,
            request: request, method: HttpMethodType.POST)));
  }

  static Future<CartListResponse> removeFromCart({required int cartId}) async {
    return CartListResponse.fromJson(await handleResponse(
        await buildHttpResponse(
            '${APIEndPoints.removeFromCart}?cart_id=$cartId',
            method: HttpMethodType.GET)));
  }

  static Future<(List<CartListData>, CartListResponse)> getCartList({
    int page = 1,
    int perPage = Constants.perPageItem,
    required (List<CartListData>, CartListResponse) cartList,
    Function(bool)? lastPageCallBack,
  }) async {
    var res = CartListResponse.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.getCartList,
            method: HttpMethodType.GET)));

    if (page == 1) cartList.$1.clear();
    cartList.$1.addAll(res.data.validate());
    cartList.$2.cartPriceData = res.cartPriceData;

    lastPageCallBack?.call(res.data.validate().length != perPage);

    return cartList;
  }

  static Future<List<ProductItemData>> getWishList({
    int page = 1,
    int perPage = 10,
    required List<ProductItemData> wishlist,
    Function(bool)? lastPageCallBack,
  }) async {
    if (isLoggedIn.value) {
      final wishlistRes = ProductWishlistRes.fromJson(await handleResponse(
          await buildHttpResponse(
              "${APIEndPoints.getWishList}?per_page=$perPage&page=$page&user_id=${loginUserData.value.id}",
              method: HttpMethodType.GET)));
      if (page == 1) wishlist.clear();
      wishlist.addAll(wishlistRes.data);
      lastPageCallBack?.call(wishlistRes.data.length != perPage);
      return wishlist;
    } else {
      return [];
    }
  }
}
