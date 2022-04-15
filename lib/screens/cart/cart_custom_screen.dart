import 'package:cirilla/constants/constants.dart';
import 'package:cirilla/mixins/mixins.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ui/notification/notification_screen.dart';
import 'package:cirilla/types/types.dart';
import 'package:cirilla/utils/app_localization.dart';

class CartCustomScreen extends StatefulWidget {
  const CartCustomScreen({Key? key}) : super(key: key);

  @override
  CartCustomScreenState createState() => CartCustomScreenState();
}

class CartCustomScreenState extends State<CartCustomScreen> with NavigationMixin{

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TranslateType translate = AppLocalizations.of(context)!.translate;

    return Observer(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          actions: [],
          title: Text("Cart (0)", style: Theme.of(context).textTheme.subtitle1),
          shadowColor: Colors.transparent,
          centerTitle: true,
        ),
        body: Stack(
          children: [
          ],
        ),
      );
    });
  }


  Widget buildCartEmpty(BuildContext context) {
    TranslateType translate = AppLocalizations.of(context)!.translate;
    return NotificationScreen(
      title: Text(translate('cart_no_count'), style: Theme.of(context).textTheme.headline6),
      content: Text(
        translate('cart_is_currently_empty'),
        style: Theme.of(context).textTheme.bodyText2,
        textAlign: TextAlign.center,
      ),
      iconData: FeatherIcons.shoppingCart,
      textButton: Text(translate('cart_return_shop')),
      styleBtn: ElevatedButton.styleFrom(padding: paddingHorizontalLarge),
      onPressed: () => navigate(context, {
        "type": "tab",
        "router": "/",
        "args": {"key": "screens_category"}
      }),
    );
  }
}
