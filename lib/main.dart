// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/app_provider.dart';
import 'utils/app_constants.dart';
import 'screens/splash_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/main_shell.dart';
import 'screens/sales/sale_screen.dart';
import 'screens/customers/add_customer_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/products/add_edit_product_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const BookBaazarApp());
}

class BookBaazarApp extends StatelessWidget {
  const BookBaazarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: Consumer<AppProvider>(
        builder: (ctx, provider, _) => MaterialApp(
          title: 'BookBaazar',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          locale: provider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ne')],
          // Always show splash first — it decides where to go
          home: const SplashScreen(),
          routes: {
            '/home':         (_) => const MainShell(),
            '/register':     (_) => const RegistrationScreen(),
            '/sale':         (_) => const SaleScreen(),
            '/add-customer': (_) => const AddCustomerScreen(),
            '/add-product':  (_) => const AddEditProductScreen(),
            '/settings':     (_) => const SettingsScreen(),
          },
        ),
      ),
    );
  }
}
