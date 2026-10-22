import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MiagedApp());
}

class MiagedApp extends StatelessWidget {
  const MiagedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIAGED',
      // Le bandeau « DEBUG » masquait le bouton « Valider » des barres de titre.
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Textes des composants Material (calendrier, infobulles…) en français.
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const LoginPage(),
    );
  }
}
