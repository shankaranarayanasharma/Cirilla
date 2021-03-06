import 'package:cirilla/constants/constants.dart';
import 'package:cirilla/models/cart/cart.dart';
import 'package:cirilla/screens/auth/login_screen.dart';
import 'package:cirilla/screens/cart/widgets/cart_shipping.dart';
import 'package:cirilla/screens/checkout/checkout.dart';
import 'package:cirilla/service/constants/endpoints.dart';
import 'package:cirilla/store/store.dart';
import 'package:cirilla/utils/utils.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:cirilla/mixins/cart_mixin.dart';
import 'package:cirilla/mixins/mixins.dart';
import 'package:cirilla/types/types.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cirilla/constants/app.dart' as acf;

class CartCoupon extends StatefulWidget {
  final Function(BuildContext context, int packageId, String rateId)? selectShipping;
  final CartStore? cartStore;
  final bool? enableGuestCheckout;
  final bool? enableShipping;
  final bool? enableCoupon;

  const CartCoupon({
    Key? key,
    this.cartStore,
    this.enableGuestCheckout,
    this.selectShipping,
    this.enableShipping,
    this.enableCoupon,
  }) : super(key: key);

  @override
  _CartCouponState createState() => _CartCouponState();
}

class _CartCouponState extends State<CartCoupon> with Utility, CartMixin, SnackMixin, GeneralMixin, LoadingMixin {
  bool _loading = false;
  bool loadingRemove = false;
  bool select = false;
  int? indexSelect;
  TextEditingController myController = TextEditingController();

  late String _selectedLocation;

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _name = prefs.getString('selectedCity');
    setState(() {
      _selectedLocation = _name!;
    });
  }



  @override
  void initState() {
    super.initState();
    _selectedLocation = "";
    getSharedPrefs();
  }

  Future<void> _removeCoupon(BuildContext context, int index) async {
    TranslateType translate = AppLocalizations.of(context)!.translate;
    try {
      setState(() {
        loadingRemove = true;
      });
      await widget.cartStore!.removeCoupon(code: widget.cartStore!.cartData!.coupons!.elementAt(index)['code']);
      setState(() {
        loadingRemove = false;
      });
      showSuccess(context, translate('cart_coupon_remove'));
    } catch (e) {
      setState(() {
        loadingRemove = false;
      });
      showError(context, e);
    }
  }

  Future<void> _applyCoupon() async {
    TranslateType translate = AppLocalizations.of(context)!.translate;
    try {
      setState(() {
        _loading = true;
      });
      await widget.cartStore!.applyCoupon(code: myController.text);
      setState(() {
        _loading = false;
      });
      showSuccess(context, translate('cart_successfully'));
      myController.clear();
    } catch (e) {
      myController.clear();
      setState(() {
        widget.cartStore!.loading;
        _loading = false;
      });
      showError(context, e);
    }
  }

  void _checkout(BuildContext context) {
    AuthStore authStore = Provider.of<AuthStore>(context, listen: false);
    SettingStore settingStore = Provider.of<SettingStore>(context, listen: false);

    if (getConfig(settingStore, ['forceLoginCheckout'], false) && !authStore.isLogin) {
      Navigator.of(context).pushNamed(
        LoginScreen.routeName,
        arguments: {
          'showMessage': ({String? message}) {
            avoidPrint('Login Success');
          }
        },
      );
    } else {
      if (isWeb) {
        _checkoutLaunch(context);
      } else {
        Navigator.of(context).pushNamed(Checkout.routeName);
      }
    }
  }

  void _checkoutLaunch(BuildContext context) {
    AuthStore authStore = Provider.of<AuthStore>(context, listen: false);
    SettingStore settingStore = Provider.of<SettingStore>(context, listen: false);
    Map<String, String?> queryParams = {
      'cart_key_restore': widget.cartStore!.cartKey!,
      'app-builder-checkout-body-class': 'app-builder-checkout'
    };

    if (authStore.isLogin) {
      queryParams.putIfAbsent('app-builder-decode', () => 'true');
      queryParams.putIfAbsent('app-builder-token', () => authStore.token);
    }

    if (settingStore.isCurrencyChanged) {
      queryParams.putIfAbsent('currency', () => settingStore.currency);
    }

    if (settingStore.languageKey != "text") {
      queryParams.putIfAbsent(authStore.isLogin ? '_lang' : 'lang', () => settingStore.locale);
    }

    String baseUrl         = acf.baseUrl+_selectedLocation.toLowerCase()+'/wp-json';

    String url = authStore.isLogin ? baseUrl + Endpoints.loginToken : settingStore.checkoutUrl!;

    String checkoutUrl = url + "?" + Uri(queryParameters: queryParams).query;
    launch(checkoutUrl, forceWebView: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CartData cartData = widget.cartStore!.cartData!;

    String? subTotal = get(cartData.totals, ['total_items'], '0');

    String? subTax = get(cartData.totals, ['total_tax'], '0');

    String? totalPrice = get(cartData.totals, ['total_price'], '0');

    int? unit = get(cartData.totals, ['currency_minor_unit'], 0);

    String? currencyCode = get(cartData.totals, ['currency_code'], null);

    TranslateType translate = AppLocalizations.of(context)!.translate;

    ThemeData theme = Theme.of(context);

    TextTheme textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.enableCoupon == true) ...[
          Text(translate('cart_coupon'), style: textTheme.subtitle2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Padding(
                      padding:
                          const EdgeInsetsDirectional.only(end: itemPadding, top: itemPadding, bottom: itemPadding),
                      child: TextField(
                        style: textTheme.bodyText2!.copyWith(color: theme.textTheme.subtitle1!.color),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsetsDirectional.only(start: itemPaddingMedium),
                          hintText: translate('cart_coupon_discount'),
                          hintStyle: textTheme.bodyText2,
                          border: const OutlineInputBorder(
                            borderRadius: borderRadius,
                          ),
                        ),
                        controller: myController,
                      ))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(89, 48)),
                onPressed: () {
                  setState(() {
                    _loading = true;
                  });
                  if (!widget.cartStore!.loading) _applyCoupon();
                },
                child: widget.cartStore!.loading && _loading
                    ? entryLoading(context, color: theme.colorScheme.onPrimary)
                    : Text(translate('cart_apply')),
              )
            ],
          ),
          Stack(
            children: [
              Column(
                children: List.generate(cartData.coupons!.length, (index) {
                  String couponTitle = get(cartData.coupons!.elementAt(index), ['code'], '');
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(couponTitle, style: textTheme.bodyText2!.copyWith(color: theme.primaryColor)),
                      InkResponse(
                        onTap: () async {
                          setState(() {
                            loadingRemove = true;
                          });
                          if (!widget.cartStore!.loading) _removeCoupon(context, index);
                        },
                        child: const Icon(FeatherIcons.x, size: itemPaddingMedium),
                      )
                    ],
                  );
                }),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: widget.cartStore!.loading && loadingRemove
                    ? Align(
                        alignment: Alignment.center,
                        child: entryLoading(context, color: theme.colorScheme.primary),
                      )
                    : Container(),
              )
            ],
          ),
          const Divider(height: 32, thickness: 1),
        ],
        if (widget.enableShipping == true) ...[
          Text(translate('cart_shipping'), style: textTheme.subtitle2),
          const SizedBox(height: 4),
          CartShipping(
            cartData: cartData,
            cartStore: widget.cartStore,
            selectShipping: widget.selectShipping,
          ),
          const SizedBox(height: itemPaddingLarge),
        ],
        buildCoupon(
            title: translate('cart_sub_total'),
            price: convertCurrency(context, unit: unit, currency: currencyCode, price: subTotal)!,
            style: textTheme.subtitle2),
        ...List.generate(cartData.coupons!.length, (index) {
          String? coupon = get(cartData.coupons!.elementAt(index), ['totals', 'total_discount'], '0');
          String? couponTitle = get(cartData.coupons!.elementAt(index), ['code'], '');
          return Column(
            children: [
              const SizedBox(height: 4),
              buildCoupon(
                title: translate('cart_code_coupon', {'code': couponTitle!}),
                price: '- ${convertCurrency(context, unit: unit, currency: currencyCode, price: coupon)}',
                style: textTheme.bodyText2,
              ),
            ],
          );
        }),
        const SizedBox(height: 4),
        ...List.generate(cartData.shippingRate!.length, (index) {
          ShippingRate shippingRate = cartData.shippingRate!.elementAt(index);

          List data = shippingRate.shipItem!;
          return Column(
            children: List.generate(data.length, (index) {
              ShipItem dataShipInfo = data.elementAt(index);

              String name = get(dataShipInfo.name, [], '');

              String? price = get(dataShipInfo.price, [], '');

              bool selected = get(dataShipInfo.selected, [], '');

              String? currencyCode = get(dataShipInfo.currencyCode, [], '');

              return selected
                  ? buildCoupon(
                      title: translate(name),
                      price: convertCurrency(context, unit: unit, currency: currencyCode, price: price)!,
                      style: textTheme.bodyText2,
                    )
                  : Container();
            }),
          );
        }),
        const SizedBox(height: 31),
        buildCoupon(
            title: translate('cart_tax'),
            price: convertCurrency(context, unit: unit, currency: currencyCode, price: subTax)!,
            style: textTheme.subtitle2),
        const SizedBox(height: 4),
        buildCoupon(
          title: translate('cart_total'),
          price: convertCurrency(context, unit: unit, currency: currencyCode, price: totalPrice)!,
          style: textTheme.subtitle1,
        ),
        const SizedBox(height: itemPaddingExtraLarge),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
          child: Text(translate('cart_proceed_to_checkout')),
          onPressed: () => _checkout(context),
        ),
      ],
    );
  }
}

Widget buildCoupon({BuildContext? context, required String title, required String price, TextStyle? style}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [Text(title, style: style), Text(price, style: style)],
  );
}
