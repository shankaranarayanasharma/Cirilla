import 'package:cirilla/screens/location/location_select_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'top.dart';

import 'constants/strings.dart';
import 'constants/languages.dart';
import 'mixins/mixins.dart';
import 'routes.dart';
import 'service/service.dart';
import 'store/store.dart';
import 'utils/utils.dart';

import 'package:flutter_phoenix/flutter_phoenix.dart';

late AppService appServiceInject;
String? language;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializePushNotificationService();
  SharedPreferences sharedPref = await getSharedPref();

  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  var defaultCity = sharedPreferences.getString('selectedCity');
  var citySelected = sharedPreferences.getBool('firstTime');
  var woocommerce_key = sharedPreferences.getStringList('woocommerce_key');

  if (defaultCity == null) {
    appServiceInject = await AppServiceInject.create(
      PreferenceModule(sharedPref: sharedPref),
      NetworkModule('NA', ['NA', 'NA']),
    );
  } else {
    appServiceInject = await AppServiceInject.create(
      PreferenceModule(sharedPref: sharedPref),
      NetworkModule(defaultCity, woocommerce_key!),
    );
  }

  language = await appServiceInject.providerPersistHelper.getLanguage();

  if (citySelected == null) {
    runApp(Phoenix(
      child: const FirstTimeApp(),
    ));
    //runApp(appServiceInject.getApp);
  } else {
    print("Selected City : " + defaultCity!);
    runApp(appServiceInject.getApp);
  }
}

class FirstTimeApp extends StatefulWidget {
  const FirstTimeApp({Key? key}) : super(key: key);

  @override
  _FirstTimeAppState createState() => _FirstTimeAppState();
}

class _FirstTimeAppState extends State<FirstTimeApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LocationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp extends StatelessWidget with Utility, ThemeMixin {
  final GlobalKey<NavigatorState> _rootNav = GlobalKey<NavigatorState>();

  final SettingStore _settingStore = SettingStore(
    appServiceInject.providerPersistHelper,
    appServiceInject.providerRequestHelper,
  );

  // Instance product category store
  final ProductCategoryStore _productCategoryStore = ProductCategoryStore(
    appServiceInject.providerRequestHelper,
    parent: 0,
    language: language,
  );

  // Instance auth store
  final AuthStore _authStore = AuthStore(
    appServiceInject.providerPersistHelper,
    appServiceInject.providerRequestHelper,
  );

  // Instance app store
  final AppStore _appStore = AppStore();

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider<RequestHelper>(
              create: (_) => appServiceInject.providerRequestHelper),
          Provider<AppStore>(create: (_) => _appStore),
          Provider<AuthStore>(create: (_) => _authStore),
          ProxyProvider<AuthStore, CartStore>(
            update: (_, _auth, __) => CartStore(
              appServiceInject.providerPersistHelper,
              appServiceInject.providerRequestHelper,
              _auth,
            ),
          ),
          Provider<SettingStore>(create: (_) => _settingStore),
          Provider<ProductCategoryStore>(create: (_) => _productCategoryStore),
        ],
        child: Consumer<SettingStore>(
          builder: (_, store, __) => Observer(
            builder: (_) => MaterialApp(
              navigatorKey: _rootNav,
              navigatorObservers: <NavigatorObserver>[observer],
              debugShowCheckedModeBanner: false,
              title: Strings.appName,
              initialRoute: '/',
              theme: buildTheme(store),
              routes: Routes.routes(store),
              onGenerateRoute: (settings) =>
                  Routes.onGenerateRoute(settings, store),
              locale: LANGUAGES[store.locale] ??
                  Locale.fromSubtags(languageCode: store.locale),
              supportedLocales: store.supportedLanguages
                  .map((language) =>
                      LANGUAGES[language.locale!] ??
                      Locale.fromSubtags(languageCode: language.locale!))
                  .toList(),
              localizationsDelegates: const [
                // A class which loads the translations from JSON files
                AppLocalizations.delegate,
                // Built-in localization of basic text for Material widgets
                GlobalMaterialLocalizations.delegate,
                // Built-in localization for text direction LTR/RTL
                GlobalWidgetsLocalizations.delegate,

                GlobalCupertinoLocalizations.delegate,
              ],
              // Returns a locale which will be used by the app
              localeResolutionCallback: (locale, supportedLocales) =>
                  // Check if the current device locale is supported
                  supportedLocales.firstWhere(
                      (supportedLocale) =>
                          supportedLocale.languageCode == locale?.languageCode,
                      orElse: () => supportedLocales.first),
            ),
          ),
        ),
      );
}
