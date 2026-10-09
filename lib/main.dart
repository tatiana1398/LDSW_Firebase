import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'screens/inicio_screen.dart';

/// Inicializa Firebase antes de mostrar la app.
///
/// firebase_options.dart lo generó `flutterfire configure` con los datos
/// del proyecto ldsw-cinecatalogo para Android, iOS y web.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CineCatalogoApp());
}

/// Colores de la línea de diseño de CineCatálogo.
const Color azulCine = Color(0xFF14477E);
const Color rosaCine = Color(0xFFC0399A);

/// Raíz de la aplicación CineCatálogo.
class CineCatalogoApp extends StatelessWidget {
  const CineCatalogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineCatálogo',
      debugShowCheckedModeBanner: false,
      // Textos de Material (contadores, botones del sistema) en español.
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: azulCine),
      ),
      home: const InicioScreen(),
    );
  }
}
